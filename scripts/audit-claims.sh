#!/usr/bin/env bash
# audit-claims.sh — local/air-gapped structural gate for living claims / audit matrix (v0)
#
# Parses docs/audit/claims-matrix.md (or --matrix PATH). Fails only on
# **critical** + **Contradicted**. No network. Graceful when matrix absent.
#
# Change-set helpers (audit/reconcile — not the CI gate):
#   --list-changed [--base REF]   print git-changed paths (one per line)
#   --list-claims  [--base REF]   parse @claim breadcrumbs in that set only
#   --upsert-claims [--base REF]  write-back touched ids into the matrix (SSOT)
#   --record-haken [--base REF]   record §6.7 Haken verdicts for touched claims
#
# Usage:
#   audit-claims.sh [PROJECT_ROOT]
#   audit-claims.sh --matrix PATH
#   audit-claims.sh --list-changed [--base REF] [PROJECT_ROOT]
#   audit-claims.sh --list-claims [--base REF] [--matrix PATH] [PROJECT_ROOT]
#   audit-claims.sh --upsert-claims [--base REF] [--matrix PATH] [PROJECT_ROOT]
#   audit-claims.sh --record-haken [--base REF] [--matrix PATH] [PROJECT_ROOT]
#   audit-claims.sh --help
#
# Exit codes:
#   0 — pass, or no matrix (skip/warn), or --list-changed printed (even if empty),
#       or --list-claims printed with no malformed lines (missing-from-matrix is a note),
#       or --upsert-claims / --record-haken wrote / no-op with no HITL
#   1 — one or more critical Contradicted claims (gate), or malformed @claim (HITL),
#       or --upsert-claims / --record-haken refused a supersede or invent (captain)
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
  $SCRIPT_NAME --upsert-claims [--base REF] [--matrix PATH] [PROJECT_ROOT]
  $SCRIPT_NAME --record-haken [--base REF] [--matrix PATH] [PROJECT_ROOT]
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

--upsert-claims reuses the --list-claims parse (same change set; never a
full-tree grep; never invents ids). Writes/updates rows for touched id=
values in the matrix (SSOT of ids). New id → append a row with safe defaults
(Verdict=Unverifiable, Severity=normal) and a captain note. Existing id →
update Action touch/status only; never overwrite Claim / Verdict / Severity /
Anchor; never write Haken tokens into Verdict. Conflicting breadcrumbs for
the same id, or breadcrumb path ≠ existing Anchor → HITL, refuse overwrite
(captain decides supersede; latest-by-date does not auto-win). Not the CI gate.

--record-haken reuses the --list-claims parse (same change set; never a
full-tree grep; never a graph walker). Applies modes.md §6.7 on touched
claims that name parent= (children not in the set are not searched).
Writes a captain-visible trace: matrix Action note
  haken=<hold|for-review> parent=<id> evidence=<path:line>
or a Haken column if that header already exists. Never writes Haken tokens
into Verdict (§6.3 SSOT). hold when status=adjusted and the parent is not
released in the set; for-review when the parent is in the set with
status=changed. escalate vs break, or unclear s≈f(q) → HITL, refuse invent.
Existing Action/Haken token that disagrees → HITL (captain supersedes; not
date-wins). Not the CI gate.
EOF
}

ROOT=""
MATRIX=""
EXPLICIT_MATRIX=0
LIST_CHANGED=0
LIST_CLAIMS=0
UPSERT_CLAIMS=0
RECORD_HAKEN=0
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
    --upsert-claims)
      UPSERT_CLAIMS=1
      shift
      ;;
    --record-haken)
      RECORD_HAKEN=1
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

if [[ -n "$BASE" && "$LIST_CHANGED" -eq 0 && "$LIST_CLAIMS" -eq 0 && "$UPSERT_CLAIMS" -eq 0 && "$RECORD_HAKEN" -eq 0 ]]; then
  echo "$SCRIPT_NAME: --base requires --list-changed, --list-claims, --upsert-claims, or --record-haken" >&2
  exit 2
fi
if [[ "$((LIST_CHANGED + LIST_CLAIMS + UPSERT_CLAIMS + RECORD_HAKEN))" -gt 1 ]]; then
  echo "$SCRIPT_NAME: --list-changed, --list-claims, --upsert-claims, and --record-haken are mutually exclusive" >&2
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

# Hits in the §6.0 change set only (never a full-tree grep).
# Prints path<TAB>lineno<TAB>line for lines containing @claim.
collect_change_set_hits() {
  local changed_files
  changed_files=$(list_changed_files "$ROOT" "$BASE") || exit $?
  while IFS= read -r rel; do
    [[ -z "${rel:-}" ]] && continue
    if [[ ! -f "$ROOT/$rel" ]]; then
      continue
    fi
    awk -v rel="$rel" '
      { gsub(/\r/, "") }
      index($0, "@claim") { print rel "\t" NR "\t" $0 }
    ' "$ROOT/$rel"
  done < <(printf '%s\n' "$changed_files" | sort -u)
}

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

  parse_in="$(collect_change_set_hits)" || exit $?

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
    done < <(printf '%s\n' "$parse_in" | parse_claim_lines)
  fi

  if [[ "$FAILS" -gt 0 ]]; then
    echo "$SCRIPT_NAME: HITL ($FAILS malformed @claim; do not invent fields)" >&2
    exit 1
  fi
  exit 0
fi

# Normalized Anchor path for one matrix id (empty if absent / no row).
get_matrix_anchor() {
  local matrix="$1" want="$2"
  awk -v want="$want" '
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
  function norm_anchor(s) {
    sub(/^anchor\.path=/, "", s)
    return s
  }
  BEGIN { id_col = 0; anchor_col = 0; in_table = 0 }
  /^[[:space:]]*\|/ {
    if (is_sep_row($0)) next
    n = split_cells($0, cells)
    if (!in_table) {
      id_col = 0
      anchor_col = 0
      for (i = 1; i <= n; i++) {
        low = tolower(cells[i])
        if (low == "id" || low == "claim id") id_col = i
        if (low == "anchor" || low == "anchor path") anchor_col = i
      }
      if (id_col > 0) { in_table = 1; next }
      next
    }
    if (id_col > 0 && id_col <= n && cells[id_col] == want) {
      if (anchor_col > 0 && anchor_col <= n) print norm_anchor(cells[anchor_col])
      else print ""
      exit
    }
    next
  }
  { in_table = 0; id_col = 0; anchor_col = 0 }
  ' "$matrix"
}

# Existing captain Haken token from a Haken column or Action note (empty if none).
get_matrix_haken() {
  local matrix="$1" want="$2"
  awk -v want="$want" '
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
  function token_in(s,   n, i, t) {
    n = split(s, t, /[^A-Za-z-]+/)
    for (i = 1; i <= n; i++) {
      if (t[i] ~ /^(hold|escalate|break|for-review)$/) return t[i]
    }
    return ""
  }
  BEGIN { id_col = 0; haken_col = 0; action_col = 0; in_table = 0 }
  /^[[:space:]]*\|/ {
    if (is_sep_row($0)) next
    n = split_cells($0, cells)
    if (!in_table) {
      id_col = 0; haken_col = 0; action_col = 0
      for (i = 1; i <= n; i++) {
        low = tolower(cells[i])
        if (low == "id" || low == "claim id") id_col = i
        if (low == "haken") haken_col = i
        if (low == "action") action_col = i
      }
      if (id_col > 0) { in_table = 1; next }
      next
    }
    if (id_col > 0 && id_col <= n && cells[id_col] == want) {
      if (haken_col > 0 && haken_col <= n) {
        tok = token_in(cells[haken_col])
        if (tok != "") { print tok; exit }
      }
      if (action_col > 0 && action_col <= n && cells[action_col] ~ /haken=/) {
        if (match(cells[action_col], /haken=(hold|escalate|break|for-review)/)) {
          print substr(cells[action_col], RSTART + 6, RLENGTH - 6)
          exit
        }
      }
      print ""
      exit
    }
    next
  }
  { in_table = 0; id_col = 0; haken_col = 0; action_col = 0 }
  ' "$matrix"
}

# Ops TSV: mode<TAB>id<TAB>path<TAB>lineno<TAB>status
# update → Action touch/status only (never Claim / Verdict / Severity / Anchor).
# insert → safe defaults + captain note. Does not invent ids.
apply_matrix_ops() {
  local matrix="$1" ops="$2"
  local tmp
  tmp="$(mktemp)"
  awk -v OPS="$ops" '
  function trim(s) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
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
  function join_row(cells, n,   i, out) {
    out = "|"
    for (i = 1; i <= n; i++) out = out " " cells[i] " |"
    return out
  }
  function apply_touch(action, path, lineno, status,   touch) {
    touch = "touched " path ":" lineno " status=" status
    sub(/[[:space:]]*[·][[:space:]]*touched[[:space:]].*$/, "", action)
    sub(/[[:space:]]+touched[[:space:]].*$/, "", action)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", action)
    if (action == "") return touch
    return action " · " touch
  }
  function insert_row(id, path, lineno, status,   cells, i, n) {
    n = ncol
    for (i = 1; i <= n; i++) cells[i] = ""
    if (id_col) cells[id_col] = id
    if (claim_col) cells[claim_col] = "Touched via @claim — captain to fill"
    if (source_col) cells[source_col] = path
    if (evidence_col) cells[evidence_col] = "`" path ":" lineno "`"
    if (anchor_col) cells[anchor_col] = "`anchor.path=" path "`"
    if (severity_col) cells[severity_col] = "normal"
    if (verdict_col) cells[verdict_col] = "Unverifiable"
    if (action_col) cells[action_col] = "captain: new id from breadcrumb; fill claim · touched " path ":" lineno " status=" status
    return join_row(cells, n)
  }
  BEGIN {
    nops = 0
    while ((getline line < OPS) > 0) {
      if (line == "") continue
      n = split(line, f, "\t")
      if (n < 5) continue
      nops++
      op_mode[nops] = f[1]
      op_id[nops] = f[2]
      op_path[nops] = f[3]
      op_line[nops] = f[4]
      op_status[nops] = f[5]
      op_of[f[2]] = nops
    }
    close(OPS)
    id_col = 0; claim_col = 0; source_col = 0; evidence_col = 0
    anchor_col = 0; severity_col = 0; verdict_col = 0; action_col = 0
    in_table = 0
    flushed = 0
    ncol = 0
  }
  function flush_inserts(   i) {
    if (flushed) return
    flushed = 1
    for (i = 1; i <= nops; i++) {
      if (op_mode[i] == "insert") print insert_row(op_id[i], op_path[i], op_line[i], op_status[i])
    }
  }
  /^[[:space:]]*\|/ {
    if (is_sep_row($0)) { print; next }
    n = split_cells($0, cells)
    if (!in_table) {
      id_col = 0; claim_col = 0; source_col = 0; evidence_col = 0
      anchor_col = 0; severity_col = 0; verdict_col = 0; action_col = 0
      for (i = 1; i <= n; i++) {
        low = tolower(cells[i])
        if (low == "id" || low == "claim id") id_col = i
        else if (low == "claim" || low == "claim (quote or paraphrase)") claim_col = i
        else if (low == "source doc" || low == "source") source_col = i
        else if (low == "code evidence" || low == "evidence") evidence_col = i
        else if (low == "anchor" || low == "anchor path") anchor_col = i
        else if (low == "severity") severity_col = i
        else if (low == "verdict") verdict_col = i
        else if (low == "action") action_col = i
      }
      if (id_col > 0) {
        in_table = 1
        ncol = n
        print
        next
      }
      print
      next
    }
    cid = (id_col > 0 && id_col <= n) ? cells[id_col] : ""
    if (cid != "" && (cid in op_of) && op_mode[op_of[cid]] == "update") {
      i = op_of[cid]
      if (action_col > 0) {
        if (action_col > n) {
          for (j = n + 1; j <= action_col; j++) cells[j] = ""
          n = action_col
        }
        cells[action_col] = apply_touch(cells[action_col], op_path[i], op_line[i], op_status[i])
      }
      # Fill empty evidence only — never overwrite captain/audit evidence.
      if (evidence_col > 0 && evidence_col <= n && cells[evidence_col] == "") {
        cells[evidence_col] = "`" op_path[i] ":" op_line[i] "`"
      }
      print join_row(cells, n)
      next
    }
    print
    next
  }
  {
    if (in_table) {
      flush_inserts()
      in_table = 0
      id_col = 0
    }
    print
  }
  END { if (in_table) flush_inserts() }
  ' "$matrix" > "$tmp"
  mv "$tmp" "$matrix"
}

# Ops TSV: mode<TAB>id<TAB>path<TAB>lineno<TAB>haken<TAB>parent
# update → Action (and Haken column if present) only. Never Verdict.
# insert → safe defaults + haken note. Does not invent ids.
apply_haken_ops() {
  local matrix="$1" ops="$2"
  local tmp
  tmp="$(mktemp)"
  awk -v OPS="$ops" '
  function trim(s) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
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
  function join_row(cells, n,   i, out) {
    out = "|"
    for (i = 1; i <= n; i++) out = out " " cells[i] " |"
    return out
  }
  function apply_haken_note(action, token, parent, path, lineno,   note) {
    note = "haken=" token " parent=" parent " evidence=" path ":" lineno
    gsub(/[[:space:]]*[·][[:space:]]*haken=(hold|escalate|break|for-review)([[:space:]]+parent=[^[:space:]]+)?([[:space:]]+evidence=[^[:space:]]+)?/, "", action)
    gsub(/^haken=(hold|escalate|break|for-review)([[:space:]]+parent=[^[:space:]]+)?([[:space:]]+evidence=[^[:space:]]+)?[[:space:]]*[·]?[[:space:]]*/, "", action)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", action)
    if (action == "") return note
    return action " · " note
  }
  function insert_row(id, path, lineno, token, parent,   cells, i, n) {
    n = ncol
    for (i = 1; i <= n; i++) cells[i] = ""
    if (id_col) cells[id_col] = id
    if (claim_col) cells[claim_col] = "Touched via @claim — captain to fill"
    if (source_col) cells[source_col] = path
    if (evidence_col) cells[evidence_col] = "`" path ":" lineno "`"
    if (anchor_col) cells[anchor_col] = "`anchor.path=" path "`"
    if (severity_col) cells[severity_col] = "normal"
    if (verdict_col) cells[verdict_col] = "Unverifiable"
    if (haken_col) cells[haken_col] = token
    if (action_col) cells[action_col] = "captain: new id from breadcrumb; fill claim · haken=" token " parent=" parent " evidence=" path ":" lineno
    return join_row(cells, n)
  }
  BEGIN {
    nops = 0
    while ((getline line < OPS) > 0) {
      if (line == "") continue
      n = split(line, f, "\t")
      if (n < 6) continue
      nops++
      op_mode[nops] = f[1]
      op_id[nops] = f[2]
      op_path[nops] = f[3]
      op_line[nops] = f[4]
      op_haken[nops] = f[5]
      op_parent[nops] = f[6]
      op_of[f[2]] = nops
    }
    close(OPS)
    id_col = 0; claim_col = 0; source_col = 0; evidence_col = 0
    anchor_col = 0; severity_col = 0; verdict_col = 0; action_col = 0
    haken_col = 0
    in_table = 0
    flushed = 0
    ncol = 0
  }
  function flush_inserts(   i) {
    if (flushed) return
    flushed = 1
    for (i = 1; i <= nops; i++) {
      if (op_mode[i] == "insert") print insert_row(op_id[i], op_path[i], op_line[i], op_haken[i], op_parent[i])
    }
  }
  /^[[:space:]]*\|/ {
    if (is_sep_row($0)) { print; next }
    n = split_cells($0, cells)
    if (!in_table) {
      id_col = 0; claim_col = 0; source_col = 0; evidence_col = 0
      anchor_col = 0; severity_col = 0; verdict_col = 0; action_col = 0
      haken_col = 0
      for (i = 1; i <= n; i++) {
        low = tolower(cells[i])
        if (low == "id" || low == "claim id") id_col = i
        else if (low == "claim" || low == "claim (quote or paraphrase)") claim_col = i
        else if (low == "source doc" || low == "source") source_col = i
        else if (low == "code evidence" || low == "evidence") evidence_col = i
        else if (low == "anchor" || low == "anchor path") anchor_col = i
        else if (low == "severity") severity_col = i
        else if (low == "verdict") verdict_col = i
        else if (low == "haken") haken_col = i
        else if (low == "action") action_col = i
      }
      if (id_col > 0) {
        in_table = 1
        ncol = n
        print
        next
      }
      print
      next
    }
    cid = (id_col > 0 && id_col <= n) ? cells[id_col] : ""
    if (cid != "" && (cid in op_of) && op_mode[op_of[cid]] == "update") {
      i = op_of[cid]
      if (haken_col > 0) {
        if (haken_col > n) {
          for (j = n + 1; j <= haken_col; j++) cells[j] = ""
          n = haken_col
        }
        cells[haken_col] = op_haken[i]
      }
      if (action_col > 0) {
        if (action_col > n) {
          for (j = n + 1; j <= action_col; j++) cells[j] = ""
          n = action_col
        }
        cells[action_col] = apply_haken_note(cells[action_col], op_haken[i], op_parent[i], op_path[i], op_line[i])
      }
      if (evidence_col > 0 && evidence_col <= n && cells[evidence_col] == "") {
        cells[evidence_col] = "`" op_path[i] ":" op_line[i] "`"
      }
      print join_row(cells, n)
      next
    }
    print
    next
  }
  {
    if (in_table) {
      flush_inserts()
      in_table = 0
      id_col = 0
    }
    print
  }
  END { if (in_table) flush_inserts() }
  ' "$matrix" > "$tmp"
  mv "$tmp" "$matrix"
}

if [[ "$UPSERT_CLAIMS" -eq 1 ]]; then
  if [[ -z "$MATRIX" ]]; then
    MATRIX="$ROOT/docs/audit/claims-matrix.md"
  fi

  parse_in="$(collect_change_set_hits)" || exit $?

  FAILS=0
  parsed=""
  if [[ -n "$parse_in" ]]; then
    while IFS=$'\t' read -r kind path lineno a b c d; do
      [[ -z "${kind:-}" ]] && continue
      if [[ "$kind" == "HITL" ]]; then
        FAILS=$((FAILS + 1))
        echo "$SCRIPT_NAME: HITL: malformed @claim in ${path}:${lineno} — ${a}" >&2
        continue
      fi
      parsed+="${path}"$'\t'"${lineno}"$'\t'"${a}"$'\t'"${b}"$'\t'"${c}"$'\t'"${d}"$'\n'
    done < <(printf '%s\n' "$parse_in" | parse_claim_lines)
  fi

  if [[ "$FAILS" -gt 0 ]]; then
    echo "$SCRIPT_NAME: HITL ($FAILS malformed @claim; do not invent fields; matrix not written)" >&2
    exit 1
  fi

  if [[ -z "$parsed" ]]; then
    exit 0
  fi

  if [[ ! -f "$MATRIX" ]]; then
    mkdir -p "$(dirname "$MATRIX")"
    cat > "$MATRIX" <<'EOF'
# Claims matrix

| ID | Claim | Source doc | Code evidence | Anchor | Severity | Verdict | Action |
|----|-------|------------|---------------|--------|----------|---------|--------|
EOF
    echo "$SCRIPT_NAME: note: created matrix $MATRIX (captain: new SSOT of ids)" >&2
  fi

  declare -A id_parent=() id_plane=() id_status=() id_path=() id_line=() id_conflict=()
  ids_ordered=()

  while IFS=$'\t' read -r path lineno cid parent plane status; do
    [[ -z "${cid:-}" ]] && continue
    if [[ -v id_parent[$cid] ]]; then
      if [[ "${id_parent[$cid]}|${id_plane[$cid]}|${id_status[$cid]}" != "${parent}|${plane}|${status}" ]]; then
        id_conflict[$cid]=1
      elif [[ "${id_path[$cid]}" != "$path" ]]; then
        # Same wire fields, second path — still a location supersede unless one matches Anchor.
        id_conflict[$cid]=1
      fi
      continue
    fi
    ids_ordered+=("$cid")
    id_parent[$cid]="$parent"
    id_plane[$cid]="$plane"
    id_status[$cid]="$status"
    id_path[$cid]="$path"
    id_line[$cid]="$lineno"
  done <<< "$parsed"

  MATRIX_IDS=$'\n'"$(list_matrix_ids "$MATRIX")"$'\n'
  HITL_REFUSE=0
  ops="$(mktemp)"
  : > "$ops"

  for cid in "${ids_ordered[@]}"; do
    if [[ -v id_conflict[$cid] ]]; then
      HITL_REFUSE=$((HITL_REFUSE + 1))
      echo "$SCRIPT_NAME: HITL: refuse overwrite id=${cid} — conflicting breadcrumbs (captain decides supersede; not date-wins)" >&2
      continue
    fi
    path="${id_path[$cid]}"
    lineno="${id_line[$cid]}"
    status="${id_status[$cid]}"
    if [[ "$MATRIX_IDS" == *$'\n'"$cid"$'\n'* ]]; then
      existing_anchor="$(get_matrix_anchor "$MATRIX" "$cid")"
      if [[ -n "$existing_anchor" && "$existing_anchor" != "$path" ]]; then
        HITL_REFUSE=$((HITL_REFUSE + 1))
        echo "$SCRIPT_NAME: HITL: refuse overwrite id=${cid} — existing anchor=${existing_anchor} breadcrumb=${path} (captain decides supersede; not date-wins)" >&2
        continue
      fi
      printf 'update\t%s\t%s\t%s\t%s\n' "$cid" "$path" "$lineno" "$status" >> "$ops"
      echo "upsert"$'\t'"update"$'\t'"id=${cid}"$'\t'"${path}:${lineno}"$'\t'"status=${status}"
    else
      printf 'insert\t%s\t%s\t%s\t%s\n' "$cid" "$path" "$lineno" "$status" >> "$ops"
      echo "upsert"$'\t'"insert"$'\t'"id=${cid}"$'\t'"${path}:${lineno}"$'\t'"status=${status}"
    fi
  done

  if [[ -s "$ops" ]]; then
    apply_matrix_ops "$MATRIX" "$ops"
  fi
  rm -f "$ops"

  if [[ "$HITL_REFUSE" -gt 0 ]]; then
    echo "$SCRIPT_NAME: HITL ($HITL_REFUSE id(s) not written; captain decides supersede)" >&2
    exit 1
  fi
  exit 0
fi

if [[ "$RECORD_HAKEN" -eq 1 ]]; then
  if [[ -z "$MATRIX" ]]; then
    MATRIX="$ROOT/docs/audit/claims-matrix.md"
  fi

  parse_in="$(collect_change_set_hits)" || exit $?

  FAILS=0
  parsed=""
  if [[ -n "$parse_in" ]]; then
    while IFS=$'\t' read -r kind path lineno a b c d; do
      [[ -z "${kind:-}" ]] && continue
      if [[ "$kind" == "HITL" ]]; then
        FAILS=$((FAILS + 1))
        echo "$SCRIPT_NAME: HITL: malformed @claim in ${path}:${lineno} — ${a}" >&2
        continue
      fi
      parsed+="${path}"$'\t'"${lineno}"$'\t'"${a}"$'\t'"${b}"$'\t'"${c}"$'\t'"${d}"$'\n'
    done < <(printf '%s\n' "$parse_in" | parse_claim_lines)
  fi

  if [[ "$FAILS" -gt 0 ]]; then
    echo "$SCRIPT_NAME: HITL ($FAILS malformed @claim; do not invent fields; matrix not written)" >&2
    exit 1
  fi

  if [[ -z "$parsed" ]]; then
    exit 0
  fi

  declare -A id_parent=() id_plane=() id_status=() id_path=() id_line=() id_conflict=()
  ids_ordered=()

  while IFS=$'\t' read -r path lineno cid parent plane status; do
    [[ -z "${cid:-}" ]] && continue
    if [[ -v id_parent[$cid] ]]; then
      if [[ "${id_parent[$cid]}|${id_plane[$cid]}|${id_status[$cid]}" != "${parent}|${plane}|${status}" ]]; then
        id_conflict[$cid]=1
      elif [[ "${id_path[$cid]}" != "$path" ]]; then
        id_conflict[$cid]=1
      fi
      continue
    fi
    ids_ordered+=("$cid")
    id_parent[$cid]="$parent"
    id_plane[$cid]="$plane"
    id_status[$cid]="$status"
    id_path[$cid]="$path"
    id_line[$cid]="$lineno"
  done <<< "$parsed"

  MATRIX_IDS=$'\n\n'
  if [[ -f "$MATRIX" ]]; then
    MATRIX_IDS=$'\n'"$(list_matrix_ids "$MATRIX")"$'\n'
  fi
  HITL_REFUSE=0
  ops="$(mktemp)"
  : > "$ops"

  for cid in "${ids_ordered[@]}"; do
    parent="${id_parent[$cid]}"
    # §6.7 trigger: a changed breadcrumb with parent=. Do not search for children.
    if [[ "$parent" == "-" ]]; then
      continue
    fi
    if [[ -v id_conflict[$cid] ]]; then
      HITL_REFUSE=$((HITL_REFUSE + 1))
      echo "$SCRIPT_NAME: HITL: refuse overwrite id=${cid} — conflicting breadcrumbs (captain decides supersede; not date-wins)" >&2
      continue
    fi
    if [[ -v id_conflict[$parent] ]]; then
      HITL_REFUSE=$((HITL_REFUSE + 1))
      echo "$SCRIPT_NAME: HITL: refuse invent id=${cid} — parent=${parent} has conflicting breadcrumbs (captain decides supersede; not date-wins)" >&2
      continue
    fi
    path="${id_path[$cid]}"
    lineno="${id_line[$cid]}"
    status="${id_status[$cid]}"
    if [[ -f "$MATRIX" && "$MATRIX_IDS" == *$'\n'"$cid"$'\n'* ]]; then
      existing_anchor="$(get_matrix_anchor "$MATRIX" "$cid")"
      if [[ -n "$existing_anchor" && "$existing_anchor" != "$path" ]]; then
        HITL_REFUSE=$((HITL_REFUSE + 1))
        echo "$SCRIPT_NAME: HITL: refuse overwrite id=${cid} — existing anchor=${existing_anchor} breadcrumb=${path} (captain decides supersede; not date-wins)" >&2
        continue
      fi
    fi

    token=""
    parent_released=0
    if [[ -v id_status[$parent] && "${id_status[$parent]}" == "changed" ]]; then
      parent_released=1
    fi
    if [[ "$parent_released" -eq 1 ]]; then
      token="for-review"
    elif [[ "$status" == "adjusted" ]]; then
      token="hold"
    else
      HITL_REFUSE=$((HITL_REFUSE + 1))
      echo "$SCRIPT_NAME: HITL: refuse invent id=${cid} — ambiguous s≈f(q) (escalate vs break; captain decides; not date-wins) evidence=${path}:${lineno} parent=${parent}" >&2
      continue
    fi

    existing_haken=""
    if [[ -f "$MATRIX" ]]; then
      existing_haken="$(get_matrix_haken "$MATRIX" "$cid")"
    fi
    if [[ -n "$existing_haken" && "$existing_haken" != "$token" ]]; then
      HITL_REFUSE=$((HITL_REFUSE + 1))
      echo "$SCRIPT_NAME: HITL: refuse overwrite id=${cid} — existing haken=${existing_haken} proposed=${token} (captain decides supersede; not date-wins)" >&2
      continue
    fi

    if [[ "$MATRIX_IDS" == *$'\n'"$cid"$'\n'* ]]; then
      printf 'update\t%s\t%s\t%s\t%s\t%s\n' "$cid" "$path" "$lineno" "$token" "$parent" >> "$ops"
      echo "haken"$'\t'"record"$'\t'"id=${cid}"$'\t'"${path}:${lineno}"$'\t'"parent=${parent}"$'\t'"${token}"
    else
      printf 'insert\t%s\t%s\t%s\t%s\t%s\n' "$cid" "$path" "$lineno" "$token" "$parent" >> "$ops"
      echo "haken"$'\t'"insert"$'\t'"id=${cid}"$'\t'"${path}:${lineno}"$'\t'"parent=${parent}"$'\t'"${token}"
    fi
  done

  if [[ -s "$ops" ]]; then
    if [[ ! -f "$MATRIX" ]]; then
      mkdir -p "$(dirname "$MATRIX")"
      cat > "$MATRIX" <<'EOF'
# Claims matrix

| ID | Claim | Source doc | Code evidence | Anchor | Severity | Verdict | Action |
|----|-------|------------|---------------|--------|----------|---------|--------|
EOF
      echo "$SCRIPT_NAME: note: created matrix $MATRIX (captain: new SSOT of ids)" >&2
    fi
    apply_haken_ops "$MATRIX" "$ops"
  fi
  rm -f "$ops"

  if [[ "$HITL_REFUSE" -gt 0 ]]; then
    echo "$SCRIPT_NAME: HITL ($HITL_REFUSE id(s) not written; captain decides; do not invent)" >&2
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
