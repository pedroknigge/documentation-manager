#!/usr/bin/env bash
# detect-packages.sh — list package roots for Documentation Manager monorepo hubs (v2.2)
# Usage: detect-packages.sh [consumer-repo-root]
# Prints one relative package path per line (sorted, unique).
# Empty stdout + exit 0 when not a monorepo / no packages found.
# Cargo [workspace] with no resolvable members: empty stdout + stderr gap.
# Exit 2 if root is not a directory.
set -euo pipefail

ROOT="${1:-.}"
if [[ ! -d "$ROOT" ]]; then
  echo "detect-packages: not a directory: $ROOT" >&2
  exit 2
fi

ROOT="$(cd -P "$ROOT" && pwd)"
declare -a found=()

add_pkg() {
  local rel="$1"
  [[ -z "$rel" || "$rel" == "." ]] && return 0
  # Must contain a package-like manifest
  if [[ -f "$ROOT/$rel/package.json" ]] \
    || [[ -f "$ROOT/$rel/pyproject.toml" ]] \
    || [[ -f "$ROOT/$rel/go.mod" ]] \
    || [[ -f "$ROOT/$rel/Cargo.toml" ]]; then
    found+=("$rel")
  fi
}

# Expand a workspace glob or concrete dir (pnpm / Cargo members).
add_from_glob() {
  local glob="$1"
  [[ -z "$glob" ]] && return 0
  if [[ "$glob" == */\* ]]; then
    local base="${glob%/\*}"
    if [[ -d "$ROOT/$base" ]]; then
      shopt -s nullglob
      local d
      for d in "$ROOT/$base"/*; do
        [[ -d "$d" ]] || continue
        add_pkg "${d#"$ROOT"/}"
      done
      shopt -u nullglob
    fi
  elif [[ -d "$ROOT/$glob" ]]; then
    add_pkg "$glob"
  fi
}

# Quoted strings from a Cargo.toml [workspace] members = [ ... ] block.
extract_cargo_members() {
  local toml="$1"
  local in_ws=0 in_mem=0
  local line
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^\[workspace\] ]]; then
      in_ws=1
      in_mem=0
      continue
    fi
    if [[ "$line" =~ ^\[ ]]; then
      in_ws=0
      in_mem=0
      continue
    fi
    [[ "$in_ws" -eq 1 ]] || continue
    if [[ "$line" =~ members[[:space:]]*= ]]; then
      in_mem=1
    fi
    [[ "$in_mem" -eq 1 ]] || continue
    # TOML strings in the members array (skip unquoted keys).
    if echo "$line" | grep -q '"'; then
      echo "$line" | grep -oE '"[^"]+"' | tr -d '"'
    elif echo "$line" | grep -q "'"; then
      echo "$line" | grep -oE "'[^']+'" | tr -d "'"
    fi
    if [[ "$line" == *"]"* ]]; then
      in_mem=0
    fi
  done < "$toml"
}

# --- pnpm-workspace.yaml: packages: globs ---
if [[ -f "$ROOT/pnpm-workspace.yaml" ]]; then
  while IFS= read -r line; do
    # match "  - 'packages/*'" or '  - "packages/*"' or "  - packages/*"
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*[\'\"]?([^\'\"#]+)[\'\"]?[[:space:]]*$ ]]; then
      glob="${BASH_REMATCH[1]}"
      glob="${glob// /}"
      [[ -z "$glob" || "$glob" == "packages:" ]] && continue
      add_from_glob "$glob"
    fi
  done < "$ROOT/pnpm-workspace.yaml"
fi

# --- package.json workspaces ---
if [[ -f "$ROOT/package.json" ]]; then
  # Prefer node if available for correct JSON; fallback: grep-ish for packages/*
  if command -v node >/dev/null 2>&1; then
    while IFS= read -r p; do
      [[ -n "$p" ]] || continue
      if [[ "$p" == */\* ]]; then
        base="${p%/\*}"
        if [[ -d "$ROOT/$base" ]]; then
          shopt -s nullglob
          for d in "$ROOT/$base"/*; do
            [[ -d "$d" ]] || continue
            add_pkg "${d#"$ROOT"/}"
          done
          shopt -u nullglob
        fi
      elif [[ -d "$ROOT/$p" ]]; then
        add_pkg "$p"
      fi
    done < <(node -e '
const fs=require("fs");
const j=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));
let w=j.workspaces;
if(!w) process.exit(0);
const list=Array.isArray(w)?w:(w.packages||[]);
for (const x of list) console.log(String(x));
' "$ROOT/package.json" 2>/dev/null || true)
  else
    # Fallback: common packages/* apps/* libs/*
    for base in packages apps libs; do
      if [[ -d "$ROOT/$base" ]]; then
        shopt -s nullglob
        for d in "$ROOT/$base"/*; do
          [[ -d "$d" ]] || continue
          add_pkg "${d#"$ROOT"/}"
        done
        shopt -u nullglob
      fi
    done
  fi
fi

# --- go.work: use ./path lines ---
if [[ -f "$ROOT/go.work" ]]; then
  while IFS= read -r line; do
    if [[ "$line" =~ ^use[[:space:]]+(.+)$ ]]; then
      rest="${BASH_REMATCH[1]}"
      # strip comments
      rest="${rest%%//*}"
      rest="${rest// /}"
      rest="${rest#./}"
      if [[ "$rest" == "(" ]]; then
        continue
      fi
      # multi-line use ( is handled loosely: lines with ./path
      :
    fi
    if [[ "$line" =~ ^[[:space:]]*\./([^[:space:]]+) ]]; then
      add_pkg "${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^use[[:space:]]+\./([^[:space:]]+) ]]; then
      add_pkg "${BASH_REMATCH[1]}"
    fi
  done < "$ROOT/go.work"
fi

# --- Cargo.toml [workspace] members (same glob/concrete shape as pnpm) ---
if [[ -f "$ROOT/Cargo.toml" ]] && grep -q '^\[workspace\]' "$ROOT/Cargo.toml"; then
  cargo_before=${#found[@]}
  while IFS= read -r memb; do
    [[ -n "$memb" ]] || continue
    [[ "$memb" == "." ]] && continue
    add_from_glob "$memb"
  done < <(extract_cargo_members "$ROOT/Cargo.toml")
  # Honest gap: workspace table present but no member roots resolved.
  if [[ ${#found[@]} -eq "$cargo_before" ]]; then
    echo "detect-packages: gap: Cargo workspace present; members unresolved" >&2
  fi
fi

# --- Convention: packages/* apps/* libs/* with manifests (if nothing else found) ---
if [[ ${#found[@]} -eq 0 ]]; then
  for base in packages apps libs; do
    if [[ -d "$ROOT/$base" ]]; then
      shopt -s nullglob
      for d in "$ROOT/$base"/*; do
        [[ -d "$d" ]] || continue
        add_pkg "${d#"$ROOT"/}"
      done
      shopt -u nullglob
    fi
  done
fi

# Dedup + sort
if [[ ${#found[@]} -eq 0 ]]; then
  exit 0
fi

printf '%s\n' "${found[@]}" | sort -u
exit 0
