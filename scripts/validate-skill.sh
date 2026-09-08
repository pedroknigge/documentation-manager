#!/usr/bin/env bash
# validate-skill.sh — structure + agentskills.io frontmatter sanity checks
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="${1:-$ROOT/skills/documentation-manager}"
SKILL_FILE="$SKILL_DIR/SKILL.md"
NAME="documentation-manager"
MAX_LINES=500
MAX_DESC=1024

fail() { echo "FAIL: $*" >&2; exit 1; }
ok()   { echo "✓ $*"; }

echo "→ Validating $SKILL_DIR"

[[ -f "$SKILL_FILE" ]] || fail "SKILL.md not found: $SKILL_FILE"

head -1 "$SKILL_FILE" | grep -q '^---' || fail "Missing YAML frontmatter start (---)"

FM=$(awk 'BEGIN{n=0} /^---$/{n++; next} n==1{print} n==2{exit}' "$SKILL_FILE")

echo "$FM" | grep -q '^name:' || fail "Missing name:"
echo "$FM" | grep -q '^description:' || fail "Missing description:"

NAME_VAL=$(echo "$FM" | awk -F': *' '/^name:/{print $2; exit}' | tr -d '"' | tr -d "'")
[[ "$NAME_VAL" == "$NAME" ]] || fail "name '$NAME_VAL' != directory '$NAME'"
ok "name matches directory ($NAME)"

if echo "$FM" | grep -q 'version:'; then
  VER=$(echo "$FM" | awk -F'"' '/version:/{print $2; exit}')
  [[ -n "$VER" ]] || VER=$(echo "$FM" | awk -F"'" '/version:/{print $2; exit}')
  [[ -n "$VER" ]] || fail "version present but empty"
  ok "version: $VER"
  # >= 2.0.0
  echo "$VER" | grep -Eq '^[2-9]\.' || \
    fail "expected version >= 2.0.0, got $VER"
  ok "version is >= 2.0.0"
else
  fail "Missing version in frontmatter"
fi

DESC=$(echo "$FM" | awk '
  /^description:/{
    sub(/^description:[[:space:]]*/, "")
    if ($0 == ">" || $0 == "|" || $0 == ">-" || $0 == "|-") { grab=1; next }
    print $0
    grab=1
    next
  }
  grab && /^[a-zA-Z0-9_-]+:/ { exit }
  grab { print }
')
DESC_FLAT=$(echo "$DESC" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
DESC_LEN=${#DESC_FLAT}
[[ "$DESC_LEN" -gt 0 ]] || fail "description empty"
[[ "$DESC_LEN" -le "$MAX_DESC" ]] || fail "description length $DESC_LEN > $MAX_DESC"
ok "description length $DESC_LEN ≤ $MAX_DESC"

LINES=$(wc -l < "$SKILL_FILE" | tr -d ' ')
[[ "$LINES" -le "$MAX_LINES" ]] || fail "SKILL.md has $LINES lines (max $MAX_LINES for progressive disclosure)"
ok "SKILL.md lines: $LINES ≤ $MAX_LINES"

for ref in \
  agents-md-template.md \
  adr-template.md \
  feature-readme-template.md \
  feature-cluster-template.md \
  architecture-template.md \
  modes.md \
  quality-checklist.md \
  status-taxonomy.md \
  audit-template.md \
  plan-template.md \
  arkgate-bridge.md \
  implementation-bridge.md \
  knowledge-dashboard.md \
  skill-discovery.md \
  team-governance.md \
  team-owners-template.md \
  team-approval-notes-template.md \
  living-claims.md \
  go-nogo-template.md \
  prototype-to-production.md
do
  [[ -f "$SKILL_DIR/references/$ref" ]] || fail "Missing references/$ref"
done
ok "all references present (incl. bridges + dashboard + discovery + team + living-claims + go-nogo + p2p)"

for concept in \
  "Step 0" \
  "feature" \
  "AGENTS.md" \
  "docs/features" \
  "docs/plans" \
  "bootstrap" \
  "sync" \
  "references/modes.md" \
  "adopt-integrate" \
  "Integrate-first" \
  "Coverage matrix" \
  "status-taxonomy" \
  "Intent" \
  "from-zero" \
  "audit" \
  "Code wins" \
  "Feature autopilot" \
  "Plan mode" \
  "ArkGate bridge" \
  "Implementation bridge" \
  "Knowledge dashboard" \
  "Skill hardening" \
  "v2.0" \
  "2.0.0" \
  "Polyglot stack detection" \
  "2.1.0" \
  "Monorepo hubs" \
  "2.2.0" \
  "Team governance" \
  "2.3.0" \
  "docs/team" \
  "2.4.0" \
  "Living claims" \
  "2.5.0" \
  "2.5.4" \
  "2.5.5" \
  "2.5.6" \
  "2.5.8" \
  "2.5.9" \
  "2.5.10" \
  "Go/no-go" \
  "§2 Mínimo" \
  "production-harden" \
  "Production-harden DoD" \
  "Sólido states/transitions" \
  "Cold-agent readable" \
  "Gate A" \
  "audit-claims" \
  "diff-first" \
  "docs-universe" \
  "§6.10" \
  "evolved layout" \
  "Silent structure rewrite" \
  "prototype-to-production" \
  "out-of-scope (captain)"
do
  grep -F -q -- "$concept" "$SKILL_FILE" || fail "Missing concept in SKILL.md: $concept"
done
ok "core concepts present (… team 2.3.0, bridge 2.4.0, living-claims 2.5.0, go/no-go 2.5.4, current 2.5.10, §2 Mínimo + production-harden DoD + Sólido states/transitions + Cold-agent readable)"

MODES="$SKILL_DIR/references/modes.md"
for concept in \
  "Detect doc maturity" \
  "adopt-full" \
  "adopt-integrate" \
  "Coverage matrix" \
  "Feature sizing" \
  "Feature autopilot" \
  "Mode: plan" \
  "Always-on non-writes" \
  "Promote plan" \
  "ADR placement" \
  "Promotion plan" \
  "sandbox" \
  "Intent selection" \
  "from-zero" \
  "Claims matrix" \
  "Contradicted" \
  "Code inventory" \
  "Code wins" \
  "ArkGate bridge" \
  "Post-gate" \
  "Kind refinement" \
  "Implementation bridge" \
  "Knowledge dashboard" \
  "Polyglot stack detection" \
  "Inventory by stack" \
  "Monorepo hubs" \
  "Package index" \
  "package non-writes" \
  "Team governance" \
  "docs/team" \
  "approval notes" \
  "Living claims" \
  "audit-claims" \
  "anchor.path" \
  "severity" \
  "diff-first" \
  "--list-changed" \
  "--list-claims" \
  "--upsert-claims" \
  "--record-haken" \
  "--cascade-recommend" \
  "Cascade verdicts" \
  "Versklavungsprinzip" \
  "for-review" \
  "Reconcile classification" \
  "regime change" \
  "No living contradictions" \
  "Who wins (AS-IS vs TO-BE)" \
  "AS-IS" \
  "TO-BE" \
  "Domain invariants" \
  "Recommend review" \
  "Audience (closed)" \
  "auto-assign" \
  "Narrative comments" \
  "fact-vs-changed-symbol" \
  "auto-delete" \
  "evolved layout" \
  "Cold-start survey heuristics" \
  "case-insensitive" \
  "*adr*" \
  "examples/**" \
  "survey-docs.sh" \
  "docs-universe" \
  "Valid-but-huge" \
  "remeasure" \
  "Gate A" \
  "Gate B" \
  "N/A justificado" \
  "residual-risk" \
  "cannot be Go" \
  "living-claims CI" \
  "Prototype → production coverage" \
  "out-of-scope (captain)" \
  "§2 Mínimo" \
  "killer assumptions" \
  "Missing stays Missing" \
  "JTBD" \
  "Production-harden DoD" \
  "production-harden" \
  "Sólido states/transitions" \
  "no flag soup" \
  "Cold-agent readable" \
  "as we discussed"
do
  grep -F -q -- "$concept" "$MODES" || fail "Missing concept in modes.md: $concept"
done
ok "modes.md … + team + living-claims + go/no-go + p2p + §2 Mínimo + production-harden DoD + Sólido states/transitions + Cold-agent readable procedures present"

[[ -x "$ROOT/scripts/generate-docs-dashboard.sh" ]] || [[ -f "$ROOT/scripts/generate-docs-dashboard.sh" ]] \
  || fail "Missing scripts/generate-docs-dashboard.sh"
ok "generate-docs-dashboard.sh present"

KD="$SKILL_DIR/references/knowledge-dashboard.md"
for concept in "SSOT" "generate-docs-dashboard" "View only" "gitignore"; do
  grep -F -q -- "$concept" "$KD" || fail "knowledge-dashboard.md missing: $concept"
done
ok "knowledge-dashboard.md procedure present"

IB="$SKILL_DIR/references/implementation-bridge.md"
for concept in \
  "Stage B" \
  "opt-in" \
  "Placement" \
  "Promote checklist" \
  "hypothesis" \
  "Anti-hallucination"
do
  grep -F -q -- "$concept" "$IB" || fail "implementation-bridge.md missing: $concept"
done
ok "implementation-bridge.md Stage B + promote checklist present"

BRIDGE="$SKILL_DIR/references/arkgate-bridge.md"
for concept in \
  "Detection" \
  "ark.config.json" \
  "Post-gate" \
  "code wins" \
  "Contradicted" \
  "no-op"
do
  grep -F -q -- "$concept" "$BRIDGE" || fail "arkgate-bridge.md missing: $concept"
done
ok "arkgate-bridge.md detection + post-gate present"

QC="$SKILL_DIR/references/quality-checklist.md"
grep -F -q "Coverage matrix" "$QC" || fail "quality-checklist missing Coverage matrix"
grep -F -q "Mature-repo" "$QC" || fail "quality-checklist missing Mature-repo section"
grep -F -q "Snapshots" "$QC" || fail "quality-checklist missing Snapshots section"
grep -F -q "Feature autopilot / plan" "$QC" || fail "quality-checklist missing Feature autopilot section"
grep -F -q "Implementation bridge" "$QC" || fail "quality-checklist missing Implementation bridge checks"
grep -F -q "Intent / audit / from-zero" "$QC" || fail "quality-checklist missing Intent section"
grep -F -q "ArkGate bridge" "$QC" || fail "quality-checklist missing ArkGate bridge section"
grep -F -q "Knowledge dashboard" "$QC" || fail "quality-checklist missing Knowledge dashboard section"
grep -F -q "Polyglot stack detection" "$QC" || fail "quality-checklist missing Polyglot stack detection section"
grep -F -q "Monorepo hubs" "$QC" || fail "quality-checklist missing Monorepo hubs section"
grep -F -q "Team governance" "$QC" || fail "quality-checklist missing Team governance section"
grep -F -q "Living claims" "$QC" || fail "quality-checklist missing Living claims section"
grep -F -q "Narrative comments" "$QC" || fail "quality-checklist missing Narrative comments"
grep -F -q "fact-vs-changed-symbol" "$QC" || fail "quality-checklist missing fact-vs-changed-symbol"
grep -F -q "silent structure rewrite" "$QC" || fail "quality-checklist missing silent structure rewrite bar"
grep -F -q "Readme.md" "$QC" || fail "quality-checklist missing case-insensitive Readme.md"
grep -F -q "*adr*" "$QC" || fail "quality-checklist missing tight ADR *adr* ban"
grep -F -q "examples/**" "$QC" || fail "quality-checklist missing examples/** claim-scope exclude"
grep -F -q "docs-universe" "$QC" || fail "quality-checklist missing docs-universe escape"
grep -F -q "remeasure" "$QC" || fail "quality-checklist missing anti-snapshot remeasure"
grep -F -q "Go/no-go" "$QC" || fail "quality-checklist missing Go/no-go"
grep -F -q "Gate A" "$QC" || fail "quality-checklist missing Gate A"
grep -F -q "residual-risk" "$QC" || fail "quality-checklist missing residual-risk"
grep -F -q "never invent a Sí" "$QC" || fail "quality-checklist missing never invent a Sí"
grep -F -q "Prototype → production" "$QC" || fail "quality-checklist missing Prototype → production"
grep -F -q "out-of-scope (captain)" "$QC" || fail "quality-checklist missing out-of-scope (captain)"
grep -F -q "§2 Mínimo" "$QC" || fail "quality-checklist missing §2 Mínimo"
grep -F -q "JTBD" "$QC" || fail "quality-checklist missing JTBD"
grep -F -q "killer assumptions" "$QC" || fail "quality-checklist missing killer assumptions"
grep -F -q "Missing stays Missing" "$QC" || fail "quality-checklist missing Missing stays Missing"
grep -F -q "Production-harden DoD" "$QC" || fail "quality-checklist missing Production-harden DoD"
grep -F -q "no greenwash OK" "$QC" || fail "quality-checklist missing no greenwash OK"
grep -F -q "Sólido states/transitions" "$QC" || fail "quality-checklist missing Sólido states/transitions"
grep -F -q "no flag soup" "$QC" || fail "quality-checklist missing no flag soup"
ok "quality-checklist … + team + living-claims + go/no-go + p2p + §2 Mínimo + production-harden DoD + Sólido states/transitions present"

PT="$SKILL_DIR/references/plan-template.md"
grep -F -q "Implementation bridge" "$PT" || fail "plan-template missing Implementation bridge section"
ok "plan-template has Implementation bridge"

ST="$SKILL_DIR/references/status-taxonomy.md"
for label in Real Dual Local Demo Partial Planned Unknown Index; do
  grep -F -q "\`$label\`" "$ST" || fail "status-taxonomy missing label: $label"
done
ok "status-taxonomy labels present"

AT="$SKILL_DIR/references/audit-template.md"
for concept in "OK" "Partial" "Missing" "Contradicted" "Unverifiable" "Claims matrix" "Code inventory" "Severity" "anchor.path" "Go/no-go" "living-claims CI"; do
  grep -F -q -- "$concept" "$AT" || fail "audit-template missing: $concept"
done
ok "audit-template verdicts + living-claims severity/anchor + go/no-go token present"

LC="$SKILL_DIR/references/living-claims.md"
for concept in \
  "anchor.path" \
  "severity" \
  "critical" \
  "Contradicted" \
  "truth score" \
  "audit-claims" \
  "diff-first" \
  "whole matrix" \
  "--list-claims" \
  "--upsert-claims" \
  "--record-haken" \
  "--cascade-recommend" \
  "Narrative comments" \
  "fact-vs-changed-symbol" \
  "Domain invariants" \
  "no greenwash"
do
  grep -F -qi -- "$concept" "$LC" || fail "living-claims.md missing: $concept"
done
ok "living-claims.md wire-format anchors present"

P2P="$SKILL_DIR/references/prototype-to-production.md"
for concept in \
  "generates" \
  "audits" \
  "out-of-scope (captain)" \
  "Problem / scope / non-goals" \
  "Domain invariants" \
  "Context diagram" \
  "Data inventory" \
  "Threat model 1-pager" \
  "ADRs" \
  "Definition of Done" \
  "Runbooks SEV" \
  "Gate A/B signed" \
  "This page is the SSOT"
do
  grep -F -q -- "$concept" "$P2P" || fail "prototype-to-production.md missing: $concept"
done
ok "prototype-to-production.md Appendix A honesty map present"

DISC="$SKILL_DIR/references/skill-discovery.md"
for concept in \
  "Cold-start survey heuristics" \
  "Readme.md" \
  "*adr*" \
  "TableHeadRenderer" \
  "examples/**" \
  "survey-docs.sh" \
  "Skill-runtime scripts"
do
  grep -F -q -- "$concept" "$DISC" || fail "skill-discovery.md missing: $concept"
done
ok "skill-discovery.md cold-start survey heuristics present"

grep -F -q "audit-claims.sh" "$ROOT/install.sh" \
  || fail "install.sh must ship audit-claims.sh into the skill tree"

[[ -f "$ROOT/scripts/survey-docs.sh" ]] || fail "missing scripts/survey-docs.sh"
chmod +x "$ROOT/scripts/survey-docs.sh" 2>/dev/null || true
if grep -E -q '\b(curl|wget|nc)\b|https?://' "$ROOT/scripts/survey-docs.sh"; then
  fail "survey-docs.sh must not use network tools or URLs"
fi
ok "survey-docs.sh present (air-gapped)"

[[ -f "$ROOT/scripts/audit-claims.sh" ]] || fail "missing scripts/audit-claims.sh"
chmod +x "$ROOT/scripts/audit-claims.sh" 2>/dev/null || true
if grep -E -q '\b(curl|wget|nc)\b|https?://' "$ROOT/scripts/audit-claims.sh"; then
  fail "audit-claims.sh must not use network tools or URLs"
fi
grep -F -q -- "--list-changed" "$ROOT/scripts/audit-claims.sh" \
  || fail "audit-claims.sh missing --list-changed helper"
grep -F -q -- "--list-claims" "$ROOT/scripts/audit-claims.sh" \
  || fail "audit-claims.sh missing --list-claims helper"
grep -F -q -- "--upsert-claims" "$ROOT/scripts/audit-claims.sh" \
  || fail "audit-claims.sh missing --upsert-claims helper"
grep -F -q -- "--record-haken" "$ROOT/scripts/audit-claims.sh" \
  || fail "audit-claims.sh missing --record-haken helper"
grep -F -q -- "--cascade-recommend" "$ROOT/scripts/audit-claims.sh" \
  || fail "audit-claims.sh missing --cascade-recommend helper"
[[ -f "$ROOT/.github/workflows/docs-audit.yml" ]] || fail "missing .github/workflows/docs-audit.yml"
grep -F -q "audit-claims.sh" "$ROOT/.github/workflows/docs-audit.yml" \
  || fail "docs-audit.yml must invoke audit-claims.sh"
if grep -E -q 'run:.*--(list-changed|list-claims|upsert-claims|record-haken|cascade-recommend)' "$ROOT/.github/workflows/docs-audit.yml"; then
  fail "docs-audit.yml must not invoke change-set helpers (CI gate is whole-matrix)"
fi
grep -E -q '\[x\].*\.github/workflows/docs-audit\.yml' "$ROOT/docs/plans/knowledge-os/README.md" \
  || fail "knowledge-os plan must mark the GitHub Actions example AC satisfied (docs-audit.yml)"
ok "audit-claims.sh present (air-gapped) + example docs-audit whole-matrix gate"

PT="$SKILL_DIR/references/plan-template.md"
for concept in "Promotion" "Acceptance criteria" "Open questions" "MVP scope" "docs/features" "Next actions" "Cold-agent readable"; do
  grep -F -q -- "$concept" "$PT" || fail "plan-template missing: $concept"
done
ok "plan-template promotion path present"

grep -F -q "Surface coverage" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing Surface coverage"
grep -F -q "code wins" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing code wins"
grep -F -q "docs/plans" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing docs/plans"
grep -F -q "Package index" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing Package index"
grep -F -q "docs/team/OWNERS.md" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing Team docs/team/OWNERS.md link"
grep -F -q "docs/ops/go-nogo.md" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing Go/no-go docs/ops/go-nogo.md link"
ok "agents-md-template has Plans + Surface coverage + Package index + Team + Go/no-go + code wins"

TG="$SKILL_DIR/references/team-governance.md"
for concept in "docs/team" "OWNERS.md" "approval-notes" "create" "link" "Integrate-first" "anti-wiki"; do
  grep -F -q -- "$concept" "$TG" || fail "team-governance.md missing: $concept"
done
ok "team-governance.md create/link + integrate-first present"

grep -F -q "Owner" "$SKILL_DIR/references/team-owners-template.md" || \
  fail "team-owners-template missing Owner"
grep -F -q "Approved by" "$SKILL_DIR/references/team-approval-notes-template.md" || \
  fail "team-approval-notes-template missing Approved by"
grep -F -q "last approved" "$SKILL_DIR/references/team-approval-notes-template.md" || \
  grep -F -q "Last approved" "$SKILL_DIR/references/team-approval-notes-template.md" || \
  fail "team-approval-notes-template missing last approved"
ok "team owner + approval-notes templates present"

GN="$SKILL_DIR/references/go-nogo-template.md"
for concept in \
  "Gate A" \
  "Gate B" \
  "N/A justificado" \
  "residual-risk" \
  "cannot be Go" \
  "living-claims CI" \
  "docs/ops/go-nogo.md" \
  "human captain"
do
  grep -F -q -- "$concept" "$GN" || fail "go-nogo-template.md missing: $concept"
done
ok "go-nogo-template.md Gate A/B + residual-risk + dual-plane present"

# Template telemetry was withdrawn from the skill surface (does not serve north star).
[[ ! -f "$SKILL_DIR/references/template-telemetry.md" ]] \
  || fail "template-telemetry.md must stay withdrawn (no skill-tree procedure)"
[[ ! -f "$ROOT/scripts/template-telemetry.sh" ]] \
  || fail "template-telemetry.sh must stay withdrawn (no shipped ledger ritual)"
ok "template telemetry withdrawn from skill tree + scripts"

grep -F -q "Canonical authority" "$SKILL_DIR/references/feature-readme-template.md" || \
  fail "feature-readme-template missing Canonical authority"
grep -F -q "Cold-agent readable" "$SKILL_DIR/references/feature-readme-template.md" || \
  fail "feature-readme-template missing Cold-agent readable"
grep -F -q "Next actions" "$SKILL_DIR/references/feature-readme-template.md" || \
  fail "feature-readme-template missing Next actions"
ok "feature-readme-template has Canonical authority + Cold-agent readable"

echo "$NAME_VAL" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || fail "name violates agentskills.io pattern"

HARDEN="$ROOT/scripts/test-skill-hardening.sh"
if [[ -f "$HARDEN" ]]; then
  echo ""
  bash "$HARDEN" || fail "test-skill-hardening.sh failed"
else
  fail "missing scripts/test-skill-hardening.sh"
fi

echo ""
echo "✅ Validation passed for $SKILL_DIR"
