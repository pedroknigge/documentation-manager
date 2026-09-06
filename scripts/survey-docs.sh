#!/usr/bin/env bash
# survey-docs.sh — cold-start survey heuristics (README / ADR / claim-scope)
# Usage: survey-docs.sh [--readme|--adrs|--claim-scope|--include-examples] [consumer-repo-root]
# Default (no mode flag): print labeled sections README / ADR / CLAIM-SCOPE.
# Exit 0 when root is readable (empty lists are valid). Exit 2 if root is not a directory.
set -euo pipefail

ROOT=""
WANT_README=0
WANT_ADRS=0
WANT_SCOPE=0
INCLUDE_EXAMPLES=0

usage() {
  echo "Usage: survey-docs.sh [--readme|--adrs|--claim-scope|--include-examples] [ROOT]" >&2
}

is_markdown() {
  local base_lc
  base_lc=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$base_lc" in
    *.md|*.markdown|*.mdx) return 0 ;;
    *) return 1 ;;
  esac
}

rel_from() {
  local abs="$1"
  printf '%s\n' "${abs#"$ROOT"/}"
}

in_examples() {
  local rel="$1"
  case "$rel" in
    examples|examples/*|*/examples|*/examples/*) return 0 ;;
    *) return 1 ;;
  esac
}

is_adr_home() {
  local dir_lc="/$1/"
  case "$dir_lc" in
    */adr/*|*/adrs/*|*/.adr/*|*/decisions/*|*/architecture-decisions/*)
      return 0 ;;
  esac
  return 1
}

is_adr() {
  local rel="$1"
  local base="${rel##*/}"
  local dir="."
  [[ "$rel" == */* ]] && dir="${rel%/*}"
  local base_lc dir_lc
  base_lc=$(printf '%s' "$base" | tr '[:upper:]' '[:lower:]')
  dir_lc=$(printf '%s' "$dir" | tr '[:upper:]' '[:lower:]')

  is_markdown "$base" || return 1

  # Filename ADR-001… / adr_0001… / ADR001… (not substring *adr*)
  if [[ "$base_lc" =~ ^adr[-_]?[0-9]+ ]]; then
    return 0
  fi

  # Numbered NNN-title.md only inside a real ADR home
  if is_adr_home "$dir_lc" && [[ "$base_lc" =~ ^[0-9]{3,4}- ]]; then
    return 0
  fi

  return 1
}

list_readme() {
  local f
  # Root only. Case-insensitive readme.md / readme.markdown.
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    rel_from "$f"
  done < <(find "$ROOT" -maxdepth 1 -type f \( -iname 'readme.md' -o -iname 'readme.markdown' \) | sort)
}

list_adrs() {
  local -a roots=()
  local d f rel
  for d in \
    adr adrs .adr doc/adr \
    docs/adr docs/adrs docs/decisions \
    docs/architecture/decisions docs/architecture-decisions
  do
    [[ -d "$ROOT/$d" ]] && roots+=("$ROOT/$d")
  done

  {
    # Root ADR-<n>-*.md only (not *adr* over the tree)
    find "$ROOT" -maxdepth 1 -type f \( -iname '*.md' -o -iname '*.markdown' -o -iname '*.mdx' \)
    if [[ ${#roots[@]} -gt 0 ]]; then
      find "${roots[@]}" -type f \( -iname '*.md' -o -iname '*.markdown' -o -iname '*.mdx' \)
    fi
  } | sort -u | while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    rel=$(rel_from "$f")
    if is_adr "$rel"; then
      printf '%s\n' "$rel"
    fi
  done
}

list_claim_scope() {
  local f rel
  {
    find "$ROOT" -maxdepth 1 -type f \( -iname '*.md' -o -iname '*.markdown' \)
    if [[ -d "$ROOT/docs" ]]; then
      find "$ROOT/docs" -type f \( -iname '*.md' -o -iname '*.markdown' \)
    fi
    if [[ -d "$ROOT/.github" ]]; then
      find "$ROOT/.github" -type f \( -iname '*.md' -o -iname '*.markdown' \)
    fi
    if [[ "$INCLUDE_EXAMPLES" -eq 1 && -d "$ROOT/examples" ]]; then
      find "$ROOT/examples" -type f \( -iname '*.md' -o -iname '*.markdown' \)
    fi
  } | sort -u | while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    rel=$(rel_from "$f")
    if [[ "$INCLUDE_EXAMPLES" -eq 0 ]] && in_examples "$rel"; then
      continue
    fi
    printf '%s\n' "$rel"
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --readme) WANT_README=1; shift ;;
    --adrs) WANT_ADRS=1; shift ;;
    --claim-scope) WANT_SCOPE=1; shift ;;
    --include-examples) INCLUDE_EXAMPLES=1; shift ;;
    --help|-h) usage; exit 0 ;;
    --) shift; break ;;
    -*)
      echo "survey-docs: unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -n "$ROOT" ]]; then
        echo "survey-docs: unexpected argument: $1" >&2
        usage
        exit 2
      fi
      ROOT="$1"
      shift
      ;;
  esac
done

ROOT="${ROOT:-.}"
if [[ ! -d "$ROOT" ]]; then
  echo "survey-docs: not a directory: $ROOT" >&2
  exit 2
fi
ROOT="$(cd -P "$ROOT" && pwd)"

if [[ "$WANT_README" -eq 0 && "$WANT_ADRS" -eq 0 && "$WANT_SCOPE" -eq 0 ]]; then
  WANT_README=1
  WANT_ADRS=1
  WANT_SCOPE=1
  echo "# README"
  list_readme
  echo "# ADR"
  list_adrs
  echo "# CLAIM-SCOPE"
  list_claim_scope
  exit 0
fi

[[ "$WANT_README" -eq 1 ]] && list_readme
[[ "$WANT_ADRS" -eq 1 ]] && list_adrs
[[ "$WANT_SCOPE" -eq 1 ]] && list_claim_scope
exit 0
