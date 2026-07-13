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
  architecture-template.md \
  modes.md \
  quality-checklist.md
do
  [[ -f "$SKILL_DIR/references/$ref" ]] || fail "Missing references/$ref"
done
ok "all references present"

# Required concepts in SKILL.md
for concept in "Step 0" "feature" "AGENTS.md" "docs/features" "bootstrap" "sync" "references/modes.md"; do
  grep -F -q -- "$concept" "$SKILL_FILE" || fail "Missing concept in SKILL.md: $concept"
done
ok "core concepts present"

# name constraints (agentskills.io)
echo "$NAME_VAL" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$' || fail "name violates agentskills.io pattern"

echo ""
echo "✅ Validation passed for $SKILL_DIR"
