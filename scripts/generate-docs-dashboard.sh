#!/usr/bin/env bash
# generate-docs-dashboard.sh — static HTML view of project knowledge under docs/
# Markdown remains SSOT. HTML is a generated view (prefer gitignore of output).
#
# Usage:
#   ./scripts/generate-docs-dashboard.sh [project-root] [output-path]
# Defaults:
#   project-root = cwd
#   output-path  = docs/audit/generated/dashboard.html (relative to root)
#
# Zero runtime dependencies (bash + standard Unix tools). Offline; no CDN.
set -euo pipefail

ROOT="$(cd -P "${1:-.}" && pwd)"
OUT_REL="${2:-docs/audit/generated/dashboard.html}"
if [[ "$OUT_REL" = /* ]]; then
  OUT="$OUT_REL"
else
  OUT="$ROOT/$OUT_REL"
fi
OUT_DIR="$(dirname "$OUT")"

html_escape() {
  printf '%s' "$1" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g'
}

meta_field() {
  local f="$1" key="$2" line
  line=$(grep -E "^\*\*${key}:\*\*" "$f" 2>/dev/null | head -1 || true)
  if [[ -z "$line" ]]; then
    printf ''
    return
  fi
  printf '%s' "$line" \
    | sed -E "s/^\*\*${key}:\*\*[[:space:]]*//" \
    | sed -E 's/[[:space:]]+$//' \
    | sed -E "s/^\`//" | sed -E "s/\`$//" | tr -d '`'
}

first_heading() {
  local f="$1" h
  h=$(grep -E '^# ' "$f" 2>/dev/null | head -1 | sed 's/^# //' || true)
  printf '%s' "$h"
}

# Relative path from OUT_DIR to an absolute target under ROOT (pure bash).
rel_from_out() {
  local target="$1"
  local r="${target#"$ROOT"/}"
  # OUT is typically ROOT/docs/audit/generated/dashboard.html → 3 levels up to ROOT
  # General: count depth of OUT_DIR under ROOT
  local rel_out="${OUT_DIR#"$ROOT"/}"
  if [[ "$rel_out" == "$OUT_DIR" ]]; then
    # OUT outside ROOT — use file path as-is under root guess
    printf '%s' "$r"
    return
  fi
  local depth=0 part
  IFS='/' read -ra parts <<<"$rel_out"
  for part in "${parts[@]}"; do
    [[ -n "$part" ]] && depth=$((depth + 1))
  done
  local prefix="" i
  for ((i = 0; i < depth; i++)); do
    prefix+="../"
  done
  printf '%s%s' "$prefix" "$r"
}

status_class() {
  local s
  s=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$s" in
    *shipped*|*real*) printf 'ok' ;;
    *progress*|*partial*|*dual*|*demo*|*local*) printf 'warn' ;;
    *planned*|*unknown*) printf 'muted' ;;
    *deprecated*|*cancel*) printf 'bad' ;;
    *) printf 'muted' ;;
  esac
}

collect_packs() {
  local kind="$1"
  local dir="$ROOT/docs/$kind"
  [[ -d "$dir" ]] || return 0
  local readme slug status title rel
  # Portable find (no -print0 required for shallow tree)
  find "$dir" -mindepth 2 -maxdepth 2 -type f -name 'README.md' 2>/dev/null | sort | while read -r readme; do
    slug=$(meta_field "$readme" "Slug")
    [[ -z "$slug" ]] && slug=$(basename "$(dirname "$readme")")
    status=$(meta_field "$readme" "Status")
    [[ -z "$status" ]] && status="Unknown"
    title=$(first_heading "$readme")
    [[ -z "$title" ]] && title="$slug"
    # Strip pipes from fields so row format stays stable
    slug=${slug//|/\/}
    status=${status//|/\/}
    title=${title//|/\/}
    rel=$(rel_from_out "$readme")
    printf '%s|%s|%s|%s\n' "$slug" "$status" "$title" "$rel"
  done
}

count_verdict() {
  local matrix="$1" token="$2"
  if [[ ! -f "$matrix" ]]; then
    printf '0'
    return
  fi
  local n
  n=$(grep -cE "\\|\\s*\\*\\*${token}\\*\\*|\\|\\s*${token}\\s*\\|" "$matrix" 2>/dev/null || true)
  printf '%s' "${n:-0}"
}

row_html() {
  local line="$1"
  local slug status title rel cls
  slug=${line%%|*}
  local rest=${line#*|}
  status=${rest%%|*}
  rest=${rest#*|}
  title=${rest%%|*}
  rel=${rest#*|}
  cls=$(status_class "$status")
  printf '<tr><td><code>%s</code></td><td>%s</td><td><span class="pill %s">%s</span></td><td><a href="%s">source</a></td></tr>\n' \
    "$(html_escape "$slug")" \
    "$(html_escape "$title")" \
    "$cls" \
    "$(html_escape "$status")" \
    "$(html_escape "$rel")"
}

FEATURES=$(collect_packs features || true)
PLANS=$(collect_packs plans || true)

FEAT_N=0
PLAN_N=0
[[ -n "$FEATURES" ]] && FEAT_N=$(printf '%s\n' "$FEATURES" | grep -c . || true)
[[ -n "$PLANS" ]] && PLAN_N=$(printf '%s\n' "$PLANS" | grep -c . || true)
FEAT_N=${FEAT_N:-0}
PLAN_N=${PLAN_N:-0}

HUB_REL=""
if [[ -f "$ROOT/AGENTS.md" ]]; then
  HUB_REL=$(rel_from_out "$ROOT/AGENTS.md")
elif [[ -f "$ROOT/agents.md" ]]; then
  HUB_REL=$(rel_from_out "$ROOT/agents.md")
fi
ROADMAP_REL=""
[[ -f "$ROOT/docs/roadmap.md" ]] && ROADMAP_REL=$(rel_from_out "$ROOT/docs/roadmap.md")
MATRIX="$ROOT/docs/audit/claims-matrix.md"
MATRIX_REL=""
[[ -f "$MATRIX" ]] && MATRIX_REL=$(rel_from_out "$MATRIX")

OK_N=0; PARTIAL_N=0; MISSING_N=0; CONTR_N=0; UNVER_N=0
HAS_MATRIX=0
if [[ -f "$MATRIX" ]]; then
  HAS_MATRIX=1
  OK_N=$(count_verdict "$MATRIX" "OK")
  PARTIAL_N=$(count_verdict "$MATRIX" "Partial")
  MISSING_N=$(count_verdict "$MATRIX" "Missing")
  CONTR_N=$(count_verdict "$MATRIX" "Contradicted")
  UNVER_N=$(count_verdict "$MATRIX" "Unverifiable")
fi

TOTAL_V=$((OK_N + PARTIAL_N + MISSING_N + CONTR_N + UNVER_N))
SCORE=0
if [[ "$TOTAL_V" -gt 0 ]]; then
  SCORE=$(( (OK_N * 100 + PARTIAL_N * 50) / TOTAL_V ))
fi

FEATURE_ROWS=""
if [[ -n "$FEATURES" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    FEATURE_ROWS+=$(row_html "$line")
  done <<<"$FEATURES"
fi

PLAN_ROWS=""
if [[ -n "$PLANS" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    PLAN_ROWS+=$(row_html "$line")
  done <<<"$PLANS"
fi

GENERATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ROOT_NAME=$(basename "$ROOT")

NAV_HTML=""
[[ -n "$HUB_REL" ]] && NAV_HTML+="<a href=\"$(html_escape "$HUB_REL")\">Hub</a> "
[[ -n "$ROADMAP_REL" ]] && NAV_HTML+="<a href=\"$(html_escape "$ROADMAP_REL")\">Roadmap</a> "
[[ -n "$MATRIX_REL" ]] && NAV_HTML+="<a href=\"$(html_escape "$MATRIX_REL")\">Claims matrix</a> "

if [[ "$FEAT_N" -eq 0 ]]; then
  FEATURE_TABLE='<p class="empty">No docs/features/*/README.md found.</p>'
else
  FEATURE_TABLE="<table><thead><tr><th>Slug</th><th>Title</th><th>Status</th><th>Source</th></tr></thead><tbody>
${FEATURE_ROWS}
</tbody></table>"
fi

if [[ "$PLAN_N" -eq 0 ]]; then
  PLAN_TABLE='<p class="empty">No docs/plans/*/README.md found.</p>'
else
  PLAN_TABLE="<table><thead><tr><th>Slug</th><th>Title</th><th>Status</th><th>Source</th></tr></thead><tbody>
${PLAN_ROWS}
</tbody></table>"
fi

if [[ "$HAS_MATRIX" -eq 1 ]]; then
  MATRIX_LINK=""
  [[ -n "$MATRIX_REL" ]] && MATRIX_LINK="<p><a href=\"$(html_escape "$MATRIX_REL")\">Open claims matrix</a></p>"
  TRUTH_BLOCK="<section>
  <h2>Claims matrix (view only)</h2>
  <p class=\"note\">Counts derived from existing <code>docs/audit/claims-matrix.md</code>. Not invented. Markdown is SSOT.</p>
  <div class=\"score\"><span class=\"score-num\">${SCORE}</span><span class=\"score-label\">truth score (heuristic)</span></div>
  <div class=\"stats\">
    <div class=\"stat ok\"><b>${OK_N}</b> OK</div>
    <div class=\"stat warn\"><b>${PARTIAL_N}</b> Partial</div>
    <div class=\"stat bad\"><b>${MISSING_N}</b> Missing</div>
    <div class=\"stat bad\"><b>${CONTR_N}</b> Contradicted</div>
    <div class=\"stat muted\"><b>${UNVER_N}</b> Unverifiable</div>
  </div>
  ${MATRIX_LINK}
</section>"
else
  TRUTH_BLOCK='<section><h2>Claims matrix</h2><p class="note">No <code>docs/audit/claims-matrix.md</code> found. Run an audit to populate truth data.</p></section>'
fi

GRAPH_TAIL="└── audit/claims-matrix (missing)"
[[ "$HAS_MATRIX" -eq 1 ]] && GRAPH_TAIL="└── audit/claims-matrix (present)"

mkdir -p "$OUT_DIR"

{
  cat <<'HDR'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
HDR
  printf '<title>Knowledge dashboard — %s</title>\n' "$(html_escape "$ROOT_NAME")"
  cat <<'CSS'
<style>
  :root {
    --bg: #0b0f14; --panel: #121820; --text: #e7eef7; --muted: #8b9bb0;
    --line: #243041; --ok: #3dd68c; --warn: #f5a524; --bad: #f31260; --link: #6cb6ff;
    --mono: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
    --sans: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; font-family: var(--sans); background: var(--bg); color: var(--text);
    line-height: 1.5; padding: 2rem clamp(1rem, 3vw, 2.5rem) 4rem;
  }
  header { margin-bottom: 1.5rem; border-bottom: 1px solid var(--line); padding-bottom: 1rem; }
  h1 { font-size: 1.5rem; margin: 0 0 0.35rem; letter-spacing: -0.02em; }
  h2 { font-size: 1.05rem; margin: 0 0 0.75rem; }
  .sub { color: var(--muted); font-size: 0.92rem; }
  .banner {
    background: #1a2330; border: 1px solid var(--line); border-radius: 10px;
    padding: 0.75rem 1rem; margin: 1rem 0 1.5rem; color: var(--muted); font-size: 0.9rem;
  }
  .banner strong { color: var(--warn); }
  nav a { color: var(--link); margin-right: 1rem; text-decoration: none; }
  nav a:hover { text-decoration: underline; }
  section {
    background: var(--panel); border: 1px solid var(--line); border-radius: 12px;
    padding: 1rem 1.1rem; margin-bottom: 1rem;
  }
  table { width: 100%; border-collapse: collapse; font-size: 0.92rem; }
  th, td { text-align: left; padding: 0.5rem 0.4rem; border-bottom: 1px solid var(--line); vertical-align: top; }
  th { color: var(--muted); font-weight: 600; font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.04em; }
  code { font-family: var(--mono); font-size: 0.85em; }
  a { color: var(--link); }
  .pill {
    display: inline-block; padding: 0.12rem 0.5rem; border-radius: 999px;
    font-size: 0.78rem; border: 1px solid var(--line); color: var(--muted);
  }
  .pill.ok { color: var(--ok); border-color: #2a5a40; }
  .pill.warn { color: var(--warn); border-color: #5a4520; }
  .pill.bad { color: var(--bad); border-color: #5a2030; }
  .pill.muted { color: var(--muted); }
  .stats { display: flex; flex-wrap: wrap; gap: 0.6rem; margin: 0.75rem 0; }
  .stat {
    min-width: 6.5rem; padding: 0.55rem 0.7rem; border-radius: 10px;
    background: #0e141c; border: 1px solid var(--line); font-size: 0.85rem; color: var(--muted);
  }
  .stat b { display: block; font-size: 1.15rem; color: var(--text); }
  .stat.ok b { color: var(--ok); }
  .stat.warn b { color: var(--warn); }
  .stat.bad b { color: var(--bad); }
  .score { display: flex; align-items: baseline; gap: 0.6rem; margin: 0.5rem 0 0.75rem; }
  .score-num { font-size: 2rem; font-weight: 700; letter-spacing: -0.03em; }
  .score-label { color: var(--muted); font-size: 0.85rem; }
  .note { color: var(--muted); font-size: 0.88rem; }
  .empty { color: var(--muted); font-style: italic; }
  footer { margin-top: 1.5rem; color: var(--muted); font-size: 0.8rem; }
  .graph {
    font-family: var(--mono); font-size: 0.8rem; white-space: pre-wrap; color: var(--muted);
    background: #0e141c; border-radius: 8px; padding: 0.75rem; border: 1px solid var(--line);
  }
</style>
</head>
<body>
CSS
  cat <<EOF
<header>
  <h1>Knowledge dashboard</h1>
  <p class="sub">$(html_escape "$ROOT_NAME") · generated <time datetime="$(html_escape "$GENERATED_AT")">$(html_escape "$GENERATED_AT")</time> UTC</p>
  <div class="banner"><strong>View only.</strong> Markdown under <code>docs/</code> + hub is the source of truth. Do not edit this HTML as documentation.</div>
  <nav>${NAV_HTML}</nav>
</header>

<section>
  <h2>Overview</h2>
  <div class="stats">
    <div class="stat"><b>${FEAT_N}</b> features</div>
    <div class="stat"><b>${PLAN_N}</b> plans</div>
    <div class="stat"><b>${HAS_MATRIX}</b> claims matrix</div>
  </div>
  <div class="graph">hub
├── features (${FEAT_N})
├── plans (${PLAN_N})
${GRAPH_TAIL}</div>
</section>

<section>
  <h2>Features</h2>
  ${FEATURE_TABLE}
</section>

<section>
  <h2>Plans</h2>
  ${PLAN_TABLE}
</section>

${TRUTH_BLOCK}

<footer>
  Generated by <code>scripts/generate-docs-dashboard.sh</code> · Documentation Manager knowledge dashboard · offline static file
</footer>
</body>
</html>
EOF
} >"$OUT"

echo "✓ Dashboard written: $OUT"
echo "  Features: $FEAT_N · Plans: $PLAN_N · Matrix: $HAS_MATRIX · Truth score: $SCORE"
echo "  Open: file://$OUT"
