#!/usr/bin/env bash
# audit-claims.sh — local/air-gapped structural gate for living claims / audit matrix (v0)
#
# Parses docs/audit/claims-matrix.md (or --matrix PATH). Fails only on
# **critical** + **Contradicted**. No network. Graceful when matrix absent.
#
# Usage:
#   audit-claims.sh [PROJECT_ROOT]
#   audit-claims.sh --matrix PATH
#   audit-claims.sh --help
#
# Exit codes:
#   0 — pass, or no matrix (skip/warn)
#   1 — one or more critical Contradicted claims
#   2 — usage / unreadable matrix path when explicitly required
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage:
  $SCRIPT_NAME [PROJECT_ROOT]
  $SCRIPT_NAME --matrix PATH
  $SCRIPT_NAME -h | --help

Air-gapped structural audit of a claims matrix (Markdown table).
Fails (exit 1) only when a row is Verdict=Contradicted AND Severity=critical.
Missing matrix → warn and exit 0. Matrix without Severity column → treat all as normal.
EOF
}

ROOT=""
MATRIX=""
EXPLICIT_MATRIX=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --matrix)
      [[ $# -ge 2 ]] || { echo "$SCRIPT_NAME: --matrix requires a path" >&2; exit 2; }
      MATRIX="$2"
      EXPLICIT_MATRIX=1
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "$SCRIPT_NAME: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [[ -z "$ROOT" ]]; then
        ROOT="$1"
        shift
      else
        echo "$SCRIPT_NAME: unexpected argument: $1" >&2
        exit 2
      fi
      ;;
  esac
done

if [[ -z "$ROOT" ]]; then
  ROOT="$(pwd)"
fi
ROOT="$(cd -P "$ROOT" 2>/dev/null && pwd || echo "$ROOT")"

if [[ -z "$MATRIX" ]]; then
  MATRIX="$ROOT/docs/audit/claims-matrix.md"
fi

if [[ ! -f "$MATRIX" ]]; then
  if [[ "$EXPLICIT_MATRIX" -eq 1 ]]; then
    echo "$SCRIPT_NAME: matrix not found: $MATRIX" >&2
    exit 2
  fi
  echo "$SCRIPT_NAME: warn: no claims matrix at $MATRIX — skip (exit 0)" >&2
  exit 0
fi

# Parse Markdown pipe tables. Locate header with Verdict; optional Severity.
# Rows without Severity (or empty) → normal. Gate: critical + Contradicted.
FAILS=0
FAIL_IDS=()

# shellcheck disable=SC2016
parse_result="$(
  awk -v OFS='\t' '
  function trim(s) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
    gsub(/^\*\*|\*\*$/, "", s)
    return s
  }
  function split_cells(line, cells,   n, i, raw) {
    sub(/^\|/, "", line)
    sub(/\|$/, "", line)
    n = split(line, raw, "|")
    for (i = 1; i <= n; i++) cells[i] = trim(raw[i])
    return n
  }
  function is_sep_row(line) {
    # Separator rows look like |---|:---| or | --- | --- |
    return (line ~ /^\|[-:|[:space:]]+\|$/)
  }
  BEGIN {
    verdict_col = 0
    severity_col = 0
    id_col = 0
    in_table = 0
  }
  /^[[:space:]]*\|/ {
    if (is_sep_row($0)) next
    n = split_cells($0, cells)
    # Detect header
    if (!in_table) {
      verdict_col = 0
      severity_col = 0
      id_col = 0
      for (i = 1; i <= n; i++) {
        low = tolower(cells[i])
        if (low == "verdict") verdict_col = i
        if (low == "severity") severity_col = i
        if (low == "id" || low == "claim id") id_col = i
      }
      if (verdict_col > 0) {
        in_table = 1
        next
      }
      next
    }
    # Data row
    if (verdict_col == 0 || verdict_col > n) next
    verdict = cells[verdict_col]
    # Strip optional markdown emphasis / trailing notes
    gsub(/`/, "", verdict)
    # Take first token that looks like a known verdict
    vnorm = ""
    ntok = split(verdict, toks, /[[:space:]\/|,;()]+/)
    for (t = 1; t <= ntok; t++) {
      if (toks[t] ~ /^(OK|Partial|Missing|Contradicted|Unverifiable)$/) {
        vnorm = toks[t]
        break
      }
    }
    if (vnorm == "") next

    sev = "normal"
    if (severity_col > 0 && severity_col <= n && cells[severity_col] != "") {
      sraw = tolower(cells[severity_col])
      gsub(/`/, "", sraw)
      if (sraw ~ /critical/) sev = "critical"
      else if (sraw ~ /normal/) sev = "normal"
    }

    cid = (id_col > 0 && id_col <= n) ? cells[id_col] : ("row")
    if (vnorm == "Contradicted" && sev == "critical") {
      print "FAIL", cid, vnorm, sev
    } else {
      print "OK", cid, vnorm, sev
    }
    next
  }
  # Non-table line ends current table
  {
    in_table = 0
    verdict_col = 0
    severity_col = 0
    id_col = 0
  }
  ' "$MATRIX"
)"

while IFS=$'\t' read -r status cid verdict sev; do
  [[ -z "${status:-}" ]] && continue
  if [[ "$status" == "FAIL" ]]; then
    FAILS=$((FAILS + 1))
    FAIL_IDS+=("$cid")
    echo "$SCRIPT_NAME: critical Contradicted: $cid" >&2
  fi
done <<< "$parse_result"

ROWS=$(printf '%s\n' "$parse_result" | grep -c . || true)
echo "$SCRIPT_NAME: matrix=$MATRIX rows_scanned=${ROWS:-0} critical_contradicted=$FAILS"

if [[ "$FAILS" -gt 0 ]]; then
  echo "$SCRIPT_NAME: FAIL ($FAILS critical Contradicted: ${FAIL_IDS[*]})" >&2
  exit 1
fi

echo "$SCRIPT_NAME: PASS"
exit 0
