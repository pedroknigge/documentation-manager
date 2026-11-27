#!/usr/bin/env bash
# detect-packages.sh — list package roots for Documentation Manager monorepo hubs (v2.2)
# Usage: detect-packages.sh [consumer-repo-root]
# Prints one relative package path per line (sorted, unique).
# Empty stdout + exit 0 when not a monorepo / no packages found.
# Cargo [workspace] with no resolvable members: empty stdout + stderr gap.
# Gradle settings include and Maven <modules> list module dirs that exist.
# :b:c maps to b/c. Exit 2 if root is not a directory.
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/nested-manifest-probe.sh
source "$SCRIPT_DIR/lib/nested-manifest-probe.sh"

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

# Directory a JVM build declared. No package.json / go.mod required.
add_existing_dir() {
  local rel="$1"
  rel="${rel#"${rel%%[![:space:]]*}"}"
  rel="${rel%"${rel##*[![:space:]]}"}"
  rel="${rel#./}"
  while [[ "$rel" == */ ]]; do
    rel="${rel%/}"
  done
  [[ -z "$rel" || "$rel" == "." ]] && return 0
  case "$rel" in
    /*|*..*) return 0 ;;
  esac
  [[ -d "$ROOT/$rel" ]] || return 0
  found+=("$rel")
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

add_convention_globs() {
  local base
  for base in packages apps libs; do
    add_from_glob "$base/*"
  done
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

# Print quoted strings from an include argument region.
gradle_emit_quoted() {
  local s="$1"
  local i=0 n=${#s} c q="" mode=""
  while [[ "$i" -lt "$n" ]]; do
    c="${s:i:1}"
    if [[ -z "$mode" ]]; then
      if [[ "$c" == "'" || "$c" == '"' ]]; then
        mode="$c"
        q=""
      fi
    elif [[ "$c" == "$mode" ]]; then
      printf '%s\n' "$q"
      mode=""
      q=""
    else
      q+="$c"
    fi
    i=$((i + 1))
  done
  return 0
}

# include 'a', ':b:c' and include("a"), including a multi-line include(...).
# includeBuild is not an include. One raw token per line.
extract_gradle_includes() {
  local file="$1"
  local line code trimmed rest args in_inc=0 buf=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    code="${line%%//*}"
    trimmed="${code#"${code%%[![:space:]]*}"}"
    if [[ -z "$trimmed" ]]; then
      if [[ "$in_inc" -eq 0 ]]; then
        continue
      fi
    fi
    if [[ "$in_inc" -eq 0 ]]; then
      if [[ "$trimmed" == \** || "$trimmed" == /\** ]]; then
        continue
      fi
      if [[ "$code" =~ (^|[^[:alnum:]_])include([^[:alnum:]_]|$) ]]; then
        rest="${code#*include}"
        if [[ "$rest" == *"("* ]]; then
          args="${rest#*(}"
          if [[ "$args" == *")"* ]]; then
            gradle_emit_quoted "${args%%)*}"
          else
            in_inc=1
            buf="$args"
          fi
        else
          gradle_emit_quoted "$rest"
        fi
      fi
    elif [[ "$code" == *")"* ]]; then
      buf="${buf}
${code%%)*}"
      gradle_emit_quoted "$buf"
      in_inc=0
      buf=""
    else
      buf="${buf}
$code"
    fi
  done < "$file"
  return 0
}

# Gradle project path :b:c → relative directory b/c.
gradle_include_to_rel() {
  local raw="$1"
  raw="${raw#"${raw%%[![:space:]]*}"}"
  raw="${raw%"${raw##*[![:space:]]}"}"
  while [[ "$raw" == :* ]]; do
    raw="${raw#:}"
  done
  raw="${raw//:/\/}"
  printf '%s\n' "$raw"
}

# <module> text inside a <modules> element. One path per line.
extract_maven_modules() {
  local pom="$1"
  local line prev in_mods=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    prev=""
    while [[ "$line" == *"<!--"* && "$line" == *"-->"* && "$line" != "$prev" ]]; do
      prev="$line"
      line="${line%%<!--*}${line#*-->}"
    done
    if [[ "$line" == *"<modules>"* || "$line" == *"<modules "* ]]; then
      in_mods=1
    fi
    if [[ "$in_mods" -eq 1 && "$line" =~ "<module>"([^<]+)"</module>" ]]; then
      printf '%s\n' "${BASH_REMATCH[1]}"
    fi
    if [[ "$line" == *"</modules>"* ]]; then
      in_mods=0
    fi
  done < "$pom"
  return 0
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
      add_from_glob "$p"
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
    add_convention_globs
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

# --- Gradle settings include (both quote forms; :b:c → b/c) ---
for _gf in settings.gradle settings.gradle.kts; do
  [[ -f "$ROOT/$_gf" ]] || continue
  while IFS= read -r inc || [[ -n "${inc:-}" ]]; do
    [[ -n "${inc:-}" ]] || continue
    add_existing_dir "$(gradle_include_to_rel "$inc")"
  done < <(extract_gradle_includes "$ROOT/$_gf")
done

# --- Maven <modules>/<module> (existing directories only) ---
if [[ -f "$ROOT/pom.xml" ]]; then
  while IFS= read -r mod || [[ -n "${mod:-}" ]]; do
    [[ -n "${mod:-}" ]] || continue
    add_existing_dir "$mod"
  done < <(extract_maven_modules "$ROOT/pom.xml")
fi

# --- Convention: packages/* apps/* libs/* with manifests (if nothing else found) ---
if [[ ${#found[@]} -eq 0 ]]; then
  add_convention_globs
fi

# --- Bounded nested probe (no root manifest/workspace, #56) ---
if [[ ${#found[@]} -eq 0 ]] && ! nested_probe_root_has_manifest "$ROOT"; then
  nested_probe_collect "$ROOT"
  local_rel=""
  for local_rel in "${NESTED_PROBE_PATHS[@]}"; do
    add_pkg "$local_rel"
  done
fi

# Dedup + sort
if [[ ${#found[@]} -eq 0 ]]; then
  exit 0
fi

printf '%s\n' "${found[@]}" | sort -u
exit 0
