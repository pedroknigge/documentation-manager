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
  # >= 1.5.0
  echo "$VER" | grep -Eq '^1\.(5|[6-9]|[1-9][0-9])\.' || \
    echo "$VER" | grep -Eq '^[2-9]\.' || \
    fail "expected version >= 1.5.0, got $VER"
  ok "version is >= 1.5.0"
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
  implementation-bridge.md
do
  [[ -f "$SKILL_DIR/references/$ref" ]] || fail "Missing references/$ref"
done
ok "all references present (incl. plan-template, audit-template, arkgate-bridge, implementation-bridge)"

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
  "1.5.0"
do
  grep -F -q -- "$concept" "$SKILL_FILE" || fail "Missing concept in SKILL.md: $concept"
done
ok "core concepts present (Intent, plan, autopilot v2, ArkGate bridge, 1.5.0)"

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
  "Implementation bridge"
do
  grep -F -q -- "$concept" "$MODES" || fail "Missing concept in modes.md: $concept"
done
ok "modes.md plan + feature autopilot v2 + ArkGate bridge procedures present"

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
ok "quality-checklist Intent + plan + mature + bridges present"

PT="$SKILL_DIR/references/plan-template.md"
grep -F -q "Implementation bridge" "$PT" || fail "plan-template missing Implementation bridge section"
ok "plan-template has Implementation bridge"

ST="$SKILL_DIR/references/status-taxonomy.md"
for label in Real Dual Local Demo Partial Planned Unknown Index; do
  grep -F -q "\`$label\`" "$ST" || fail "status-taxonomy missing label: $label"
done
ok "status-taxonomy labels present"

AT="$SKILL_DIR/references/audit-template.md"
for concept in "OK" "Partial" "Missing" "Contradicted" "Unverifiable" "Claims matrix" "Code inventory"; do
  grep -F -q -- "$concept" "$AT" || fail "audit-template missing: $concept"
done
ok "audit-template verdicts present"

PT="$SKILL_DIR/references/plan-template.md"
for concept in "Promotion" "Acceptance criteria" "Open questions" "MVP scope" "docs/features"; do
  grep -F -q -- "$concept" "$PT" || fail "plan-template missing: $concept"
done
ok "plan-template promotion path present"

grep -F -q "Surface coverage" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing Surface coverage"
grep -F -q "code wins" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing code wins"
grep -F -q "docs/plans" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing docs/plans"
ok "agents-md-template has Plans + Surface coverage + code wins"

grep -F -q "Canonical authority" "$SKILL_DIR/references/feature-readme-template.md" || \
  fail "feature-readme-template missing Canonical authority"
ok "feature-readme-template has Canonical authority"

echo "$NAME_VAL" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || fail "name violates agentskills.io pattern"

echo ""
echo "✅ Validation passed for $SKILL_DIR"
