#!/usr/bin/env bash
# detect-stack.sh — filesystem stack signals for Documentation Manager polyglot MVP (v2.1)
# Usage: detect-stack.sh [consumer-repo-root]
# Prints space-separated primary tokens: node-ts python go
# If none match: unknown
# Exit 0 always when root is readable (unknown is valid).
set -euo pipefail

ROOT="${1:-.}"
if [[ ! -d "$ROOT" ]]; then
  echo "detect-stack: not a directory: $ROOT" >&2
  exit 2
fi

# Resolve to absolute for stable tests
ROOT="$(cd -P "$ROOT" && pwd)"

tokens=()

has_node=0
has_python=0
has_go=0

if [[ -f "$ROOT/package.json" ]] \
  || [[ -f "$ROOT/tsconfig.json" ]] \
  || [[ -f "$ROOT/pnpm-workspace.yaml" ]]; then
  has_node=1
fi

if [[ -f "$ROOT/pyproject.toml" ]] \
  || [[ -f "$ROOT/setup.py" ]] \
  || [[ -f "$ROOT/setup.cfg" ]] \
  || [[ -f "$ROOT/requirements.txt" ]] \
  || [[ -f "$ROOT/Pipfile" ]] \
  || [[ -f "$ROOT/poetry.lock" ]]; then
  has_python=1
fi

# Python package under src/*/ with __init__.py (common src layout)
if [[ "$has_python" -eq 0 ]] && [[ -d "$ROOT/src" ]]; then
  shopt -s nullglob
  for init in "$ROOT"/src/*/__init__.py; do
    has_python=1
    break
  done
  shopt -u nullglob
fi

# Go: go.mod is authoritative. Do not treat orphan go.sum or generic
# cmd/+internal/ dirs alone (common layout names outside Go).
if [[ -f "$ROOT/go.mod" ]]; then
  has_go=1
fi

[[ "$has_node" -eq 1 ]] && tokens+=("node-ts")
[[ "$has_python" -eq 1 ]] && tokens+=("python")
[[ "$has_go" -eq 1 ]] && tokens+=("go")

if [[ ${#tokens[@]} -eq 0 ]]; then
  echo "unknown"
  exit 0
fi

# Multi-stack: emit primary tokens space-separated (announce as Stack: mixed).
# Do not invent a separate "mixed" token that would break single-stack greps.
printf '%s\n' "${tokens[*]}"
exit 0
