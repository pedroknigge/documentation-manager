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
warn() { echo "WARN: $*" >&2; }
ok()   { echo "✓ $*"; }

echo "→ Validating $SKILL_DIR"

[[ -f "$SKILL_FILE" ]] || fail "SKILL.md not found: $SKILL_FILE"

# Frontmatter
head -1 "$SKILL_FILE" | grep -q '^---' || fail "Missing YAML frontmatter start (---)"

# Extract frontmatter block
FM=$(awk 'BEGIN{n=0} /^---$/{n++; next} n==1{print} n==2{exit}' "$SKILL_FILE")

echo "$FM" | grep -q '^name:' || fail "Missing name:"
echo "$FM" | grep -q '^description:' || fail "Missing description:"

# name matches directory
NAME_VAL=$(echo "$FM" | awk -F': *' '/^name:/{print $2; exit}' | tr -d '"' | tr -d "'")
[[ "$NAME_VAL" == "$NAME" ]] || fail "name '$NAME_VAL' != directory '$NAME'"
ok "name matches directory ($NAME)"

# version 1.1.0+
if echo "$FM" | grep -q 'version:'; then
  VER=$(echo "$FM" | awk -F'"' '/version:/{print $2; exit}')
  [[ -n "$VER" ]] || VER=$(echo "$FM" | awk -F"'" '/version:/{print $2; exit}')
  [[ -n "$VER" ]] || fail "version present but empty"
  ok "version: $VER"
  echo "$VER" | grep -Eq '^1\.(1|[2-9]|[1-9][0-9])\.' || \
    echo "$VER" | grep -Eq '^[2-9]\.' || \
    fail "expected version >= 1.1.0, got $VER"
  ok "version is >= 1.1.0"
else
  fail "Missing version in frontmatter"
fi

# description length (folded YAML: sum continuation until next key)
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

# Line count of body skill
LINES=$(wc -l < "$SKILL_FILE" | tr -d ' ')
[[ "$LINES" -le "$MAX_LINES" ]] || fail "SKILL.md has $LINES lines (max $MAX_LINES for progressive disclosure)"
ok "SKILL.md lines: $LINES ≤ $MAX_LINES"

# Required references
for ref in \
  agents-md-template.md \
  adr-template.md \
  feature-readme-template.md \
  feature-cluster-template.md \
  architecture-template.md \
  modes.md \
  quality-checklist.md \
  status-taxonomy.md
do
  [[ -f "$SKILL_DIR/references/$ref" ]] || fail "Missing references/$ref"
done
ok "all references present (incl. status-taxonomy, feature-cluster)"

# Required concepts in SKILL.md
for concept in \
  "Step 0" \
  "feature" \
  "AGENTS.md" \
  "docs/features" \
  "bootstrap" \
  "sync" \
  "references/modes.md" \
  "adopt-integrate" \
  "Integrate-first" \
  "Coverage matrix" \
  "status-taxonomy" \
  "1.1.0"
do
  grep -F -q -- "$concept" "$SKILL_FILE" || fail "Missing concept in SKILL.md: $concept"
done
ok "core concepts present (incl. adopt-integrate, Coverage matrix)"

# Required concepts in modes.md
MODES="$SKILL_DIR/references/modes.md"
for concept in \
  "Detect doc maturity" \
  "adopt-full" \
  "adopt-integrate" \
  "Coverage matrix" \
  "Feature sizing" \
  "ADR placement" \
  "Promotion plan" \
  "sandbox"
do
  grep -F -q -- "$concept" "$MODES" || fail "Missing concept in modes.md: $concept"
done
ok "modes.md adopt-integrate / maturity procedures present"

# Quality checklist mature-repo
QC="$SKILL_DIR/references/quality-checklist.md"
grep -F -q "Coverage matrix" "$QC" || fail "quality-checklist missing Coverage matrix"
grep -F -q "Mature-repo" "$QC" || fail "quality-checklist missing Mature-repo section"
grep -F -q "Snapshots" "$QC" || fail "quality-checklist missing Snapshots section"
ok "quality-checklist mature-repo + snapshots checks present"

# Status taxonomy labels
ST="$SKILL_DIR/references/status-taxonomy.md"
for label in Real Dual Local Demo Partial Planned Unknown Index; do
  grep -F -q "\`$label\`" "$ST" || fail "status-taxonomy missing label: $label"
done
ok "status-taxonomy labels present"

# Agents template coverage
grep -F -q "Surface coverage" "$SKILL_DIR/references/agents-md-template.md" || \
  fail "agents-md-template missing Surface coverage"
ok "agents-md-template has Surface coverage"

# Feature template status + authority
grep -F -q "Canonical authority" "$SKILL_DIR/references/feature-readme-template.md" || \
  fail "feature-readme-template missing Canonical authority"
ok "feature-readme-template has Canonical authority"

# name constraints (agentskills.io)
echo "$NAME_VAL" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || fail "name violates agentskills.io pattern"

echo ""
echo "✅ Validation passed for $SKILL_DIR"
