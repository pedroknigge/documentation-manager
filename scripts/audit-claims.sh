#!/usr/bin/env bash
# audit-claims.sh — local/air-gapped structural gate for living claims / audit matrix (v0)
#
# Parses docs/audit/claims-matrix.md (or --matrix PATH). Fails only on
# **critical** + **Contradicted**. No network. Graceful when matrix absent.
#
# Change-set helpers (audit/reconcile reads — not the CI gate):
#   --list-changed [--base REF]   print git-changed paths (one per line)
#   --list-claims  [--base REF]   parse @claim breadcrumbs in that set only
#
# Usage:
#   audit-claims.sh [PROJECT_ROOT]
#   audit-claims.sh --matrix PATH
#   audit-claims.sh --list-changed [--base REF] [PROJECT_ROOT]
#   audit-claims.sh --list-claims [--base REF] [--matrix PATH] [PROJECT_ROOT]
#   audit-claims.sh --help
#
# Exit codes:
#   0 — pass, or no matrix (skip/warn), or --list-changed printed (even if empty),
#       or --list-claims printed with no malformed lines (missing-from-matrix is a note)
#   1 — one or more critical Contradicted claims (gate), or malformed @claim (HITL)
#   2 — usage / unreadable matrix path when explicitly required / not a git repo
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage:
  $SCRIPT_NAME [PROJECT_ROOT]
  $SCRIPT_NAME --matrix PATH
  $SCRIPT_NAME --list-changed [--base REF] [PROJECT_ROOT]
  $SCRIPT_NAME --list-claims [--base REF] [--matrix PATH] [PROJECT_ROOT]
  $SCRIPT_NAME -h | --help

Air-gapped structural audit of a claims matrix (Markdown table).
Fails (exit 1) only when a row is Verdict=Contradicted AND Severity=critical.
Missing matrix → warn and exit 0. Matrix without Severity column → treat all as normal.

--list-changed prints the git change set (one path per line) for diff-first
audit/reconcile reads. Default: dirty tree vs HEAD + untracked. With --base:
git diff --name-only <base>...HEAD. Empty set is exit 0 (agent HITL — do not
full-tree). Does not change the matrix gate.

--list-claims parses @claim breadcrumbs in the same change set only (never a
full-tree grep). Stdout: one line per valid breadcrumb
  <path>:<line>  id=<id>  parent=<id|->  plane=<P3|P2|P1|P0>  status=<changed|adjusted>
parent=- when the comment omits parent=. Malformed line → HITL on stderr and
exit 1; never invents id/parent/plane/status. If a matrix is present, ids in
comments that are missing from the matrix are noted on stderr (read-only; exit
0 unless a line is malformed). Not the CI gate.
EOF
}

ROOT=""
MATRIX=""
EXPLICIT_MATRIX=0
LIST_CHANGED=0
LIST_CLAIMS=0
BASE=""

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
    --list-changed)
      LIST_CHANGED=1
      shift
      ;;
    --list-claims)
      LIST_CLAIMS=1
      shift
      ;;
    --base)
      [[ $# -ge 2 ]] || { echo "$SCRIPT_NAME: --base requires a ref" >&2; exit 2; }
      BASE="$2"
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

if [[ -n "$BASE" && "$LIST_CHANGED" -eq 0 && "$LIST_CLAIMS" -eq 0 ]]; then
  echo "$SCRIPT_NAME: --base requires --list-changed or --list-claims" >&2
  exit 2
fi
if [[ "$LIST_CHANGED" -eq 1 && "$LIST_CLAIMS" -eq 1 ]]; then
  echo "$SCRIPT_NAME: --list-changed and --list-claims are mutually exclusive" >&2
  exit 2
fi
if [[ "$LIST_CHANGED" -eq 1 && "$EXPLICIT_MATRIX" -eq 1 ]]; then
  echo "$SCRIPT_NAME: --list-changed and --matrix are mutually exclusive" >&2
  exit 2
fi

list_changed_files() {
  local root="$1"
  local base="${2:-}"
  if ! git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "$SCRIPT_NAME: not a git repository: $root" >&2
    exit 2
  fi
  if [[ -n "$base" ]]; then
    git -C "$root" diff --name-only "${base}...HEAD"
  else
    git -C "$root" diff --name-only HEAD
    git -C "$root" ls-files --others --exclude-standard
  fi
}

if [[ "$LIST_CHANGED" -eq 1 ]]; then
  list_changed_files "$ROOT" "$BASE"
  exit 0
fi

# Matrix IDs only (read-only). Empty / missing id cells are skipped — never invented.
list_matrix_ids() {
  local matrix="$1"
  awk '
  function trim(s) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
    gsub(/^\*\*|\*\*$/, "", s)
    gsub(/`/, "", s)
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
    return (line ~ /^\|[-:|[:space:]]+\|$/)
  }
  BEGIN { id_col = 0; in_table = 0 }
  /^[[:space:]]*\|/ {
    if (is_sep_row($0)) next
    n = split_cells($0, cells)
    if (!in_table) {
      id_col = 0
      for (i = 1; i <= n; i++) {
        low = tolower(cells[i])
        if (low == "id" || low == "claim id") id_col = i
      }
      if (id_col > 0) { in_table = 1; next }
      next
    }
    if (id_col > 0 && id_col <= n && cells[id_col] != "") print cells[id_col]
    next
  }
  { in_table = 0; id_col = 0 }
  ' "$matrix"
}

# stdin: path<TAB>lineno<TAB>line  →  OK|HITL rows (tab-separated)
parse_claim_lines() {
  awk -v OFS='\t' '
  function trim(s) {
    gsub(/\r/, "", s)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
    return s
  }
  {
    path = $1
    lineno = $2
    line = $3
    for (i = 4; i <= NF; i++) line = line "\t" $i
    line = trim(line)
    idx = index(line, "@claim")
    if (idx == 0) next
    if (idx > 1) {
      prev = substr(line, idx - 1, 1)
      if (prev ~ /[[:alnum:]_]/) next
    }
    rest = substr(line, idx + 6)
    sub(/^[[:space:]]+/, "", rest)
    sub(/[[:space:]]*\*\/[[:space:]]*$/, "", rest)
    rest = trim(rest)
    id = ""; parent = ""; plane = ""; status = ""
    parent_seen = 0
    malformed = ""
    ntok = split(rest, toks, /[[:space:]]+/)
    if (rest == "" || ntok == 0) malformed = "missing required field id"
    for (t = 1; t <= ntok && malformed == ""; t++) {
      tok = toks[t]
      if (tok == "") continue
      if (tok !~ /^[a-z]+=/) {
        malformed = "token not key=value: " tok
        break
      }
      eq = index(tok, "=")
      k = substr(tok, 1, eq - 1)
      v = substr(tok, eq + 1)
      if (k == "id") {
        if (id != "") { malformed = "duplicate id="; break }
        id = v
      } else if (k == "parent") {
        if (parent_seen) { malformed = "two parent= keys"; break }
        parent_seen = 1
        parent = v
        if (parent == "") { malformed = "empty parent="; break }
      } else if (k == "plane") {
        if (plane != "") { malformed = "duplicate plane="; break }
        plane = v
      } else if (k == "status") {
        if (status != "") { malformed = "duplicate status="; break }
        status = v
      } else {
        malformed = "unknown key: " k
        break
      }
    }
    if (malformed == "") {
      if (id == "") malformed = "missing required field id"
      else if (plane == "") malformed = "missing required field plane"
      else if (status == "") malformed = "missing required field status"
      else if (plane !~ /^P[0123]$/) malformed = "invalid plane=" plane
      else if (status !~ /^(changed|adjusted)$/) malformed = "invalid status=" status
    }
    if (malformed != "") {
      print "HITL", path, lineno, malformed
    } else {
      p = parent_seen ? parent : "-"
      print "OK", path, lineno, id, p, plane, status
    }
  }
  '
}

if [[ "$LIST_CLAIMS" -eq 1 ]]; then
  if [[ -z "$MATRIX" ]]; then
    MATRIX="$ROOT/docs/audit/claims-matrix.md"
  fi
  if [[ ! -f "$MATRIX" ]]; then
    if [[ "$EXPLICIT_MATRIX" -eq 1 ]]; then
      echo "$SCRIPT_NAME: matrix not found: $MATRIX" >&2
      exit 2
    fi
    MATRIX=""
  fi

  MATRIX_IDS=""
  if [[ -n "$MATRIX" ]]; then
    MATRIX_IDS=$'\n'"$(list_matrix_ids "$MATRIX")"$'\n'
  fi

  changed_files=$(list_changed_files "$ROOT" "$BASE") || exit $?

  parse_in=""
  while IFS= read -r rel; do
    [[ -z "${rel:-}" ]] && continue
    if [[ ! -f "$ROOT/$rel" ]]; then
      continue
    fi
    # Scan this change-set file only (NR = line). Never grep the tree.
    while IFS= read -r hit; do
      [[ -z "${hit:-}" ]] && continue
      parse_in+="${hit}"$'\n'
    done < <(awk -v rel="$rel" '
      { gsub(/\r/, "") }
      index($0, "@claim") { print rel "\t" NR "\t" $0 }
    ' "$ROOT/$rel")
  done < <(printf '%s\n' "$changed_files" | sort -u)

  FAILS=0
  if [[ -n "$parse_in" ]]; then
    while IFS=$'\t' read -r kind path lineno a b c d; do
      [[ -z "${kind:-}" ]] && continue
      if [[ "$kind" == "HITL" ]]; then
        FAILS=$((FAILS + 1))
        echo "$SCRIPT_NAME: HITL: malformed @claim in ${path}:${lineno} — ${a}" >&2
        continue
      fi
      echo "${path}:${lineno}"$'\t'"id=${a}"$'\t'"parent=${b}"$'\t'"plane=${c}"$'\t'"status=${d}"
      if [[ -n "$MATRIX_IDS" ]]; then
        if [[ "$MATRIX_IDS" != *$'\n'"$a"$'\n'* ]]; then
          echo "$SCRIPT_NAME: note: breadcrumb id=${a} in ${path}:${lineno} not in matrix (read-only)" >&2
        fi
        if [[ "$b" != "-" && "$MATRIX_IDS" != *$'\n'"$b"$'\n'* ]]; then
          echo "$SCRIPT_NAME: note: breadcrumb parent=${b} in ${path}:${lineno} not in matrix (read-only)" >&2
        fi
      fi
    done < <(printf '%s' "$parse_in" | parse_claim_lines)
  fi

  if [[ "$FAILS" -gt 0 ]]; then
    echo "$SCRIPT_NAME: HITL ($FAILS malformed @claim; do not invent fields)" >&2
    exit 1
  fi
  exit 0
fi

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
