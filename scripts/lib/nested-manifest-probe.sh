# nested-manifest-probe.sh — bounded depth-2 manifest discovery (Approach A, #56)
# Sourced by detect-stack.sh and detect-packages.sh. Not installed to consumers alone.
# Sets: NESTED_PROBE_PATHS[] (relative dirs, sorted) when probe runs.
# Returns via functions; no standalone CLI.

# Basenames we never descend into during the bounded walk.
nested_probe_skip_dir() {
  case "$1" in
    node_modules|vendor|dist|build|coverage|fixtures|templates|template|.git|__pycache__|.venv|venv)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# True (exit 0) when root already has a manifest/workspace — do not nested-probe.
nested_probe_root_has_manifest() {
  local r="$1"
  [[ -f "$r/package.json" ]] && return 0
  [[ -f "$r/pnpm-workspace.yaml" ]] && return 0
  [[ -f "$r/tsconfig.json" ]] && return 0
  [[ -f "$r/go.mod" ]] && return 0
  [[ -f "$r/go.work" ]] && return 0
  [[ -f "$r/Cargo.toml" ]] && return 0
  [[ -f "$r/rust-toolchain" ]] && return 0
  [[ -f "$r/rust-toolchain.toml" ]] && return 0
  [[ -f "$r/pyproject.toml" ]] && return 0
  [[ -f "$r/setup.py" ]] && return 0
  [[ -f "$r/setup.cfg" ]] && return 0
  [[ -f "$r/requirements.txt" ]] && return 0
  [[ -f "$r/Pipfile" ]] && return 0
  return 1
}

# True when $dir contains a stack/package manifest for probe purposes.
nested_probe_dir_has_manifest() {
  local d="$1"
  [[ -f "$d/package.json" ]] && return 0
  [[ -f "$d/pyproject.toml" ]] && return 0
  [[ -f "$d/setup.py" ]] && return 0
  [[ -f "$d/setup.cfg" ]] && return 0
  [[ -f "$d/requirements.txt" ]] && return 0
  [[ -f "$d/Pipfile" ]] && return 0
  [[ -f "$d/go.mod" ]] && return 0
  return 1
}

# Populate NESTED_PROBE_PATHS with relative package dirs (depth <= 2, sorted).
nested_probe_collect() {
  local r="$1"
  NESTED_PROBE_PATHS=()
  nested_probe_root_has_manifest "$r" && return 0

  shopt -s nullglob
  local d1 d2 name rel1 rel2
  for d1 in "$r"/*; do
    [[ -d "$d1" ]] || continue
    name="$(basename "$d1")"
    nested_probe_skip_dir "$name" && continue
    rel1="${d1#"$r"/}"
    if nested_probe_dir_has_manifest "$d1"; then
      NESTED_PROBE_PATHS+=("$rel1")
    fi
    for d2 in "$d1"/*; do
      [[ -d "$d2" ]] || continue
      name="$(basename "$d2")"
      nested_probe_skip_dir "$name" && continue
      rel2="${d2#"$r"/}"
      if nested_probe_dir_has_manifest "$d2"; then
        NESTED_PROBE_PATHS+=("$rel2")
      fi
    done
  done
  shopt -u nullglob

  if [[ ${#NESTED_PROBE_PATHS[@]} -eq 0 ]]; then
    return 0
  fi
  local sorted
  sorted=$(printf '%s\n' "${NESTED_PROBE_PATHS[@]}" | LC_ALL=C sort -u)
  NESTED_PROBE_PATHS=()
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    NESTED_PROBE_PATHS+=("$line")
  done <<< "$sorted"
}
