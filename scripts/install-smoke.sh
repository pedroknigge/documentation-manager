#!/usr/bin/env bash
# install-smoke.sh — idempotent install + uninstall with fake HOME
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$ROOT/install.sh"
SKILL_SRC="$ROOT/skills/documentation-manager/SKILL.md"

[[ -f "$INSTALL_SH" ]] || { echo "ERROR: install.sh missing"; exit 1; }
[[ -f "$SKILL_SRC" ]] || { echo "ERROR: skill source missing"; exit 1; }
chmod +x "$INSTALL_SH" "$ROOT/scripts/validate-skill.sh" 2>/dev/null || true

echo "→ Running installer smoke test..."

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
FAKE_HOME="$TMPDIR/fakehome"
mkdir -p "$FAKE_HOME/.grok" "$FAKE_HOME/.claude" "$FAKE_HOME/.codex" "$FAKE_HOME/.agents"

echo "→ First install"
HOME="$FAKE_HOME" bash "$INSTALL_SH" 2>&1 | cat

for path in \
  "$FAKE_HOME/.grok/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.claude/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/modes.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/skill-discovery.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/plan-template.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/living-claims.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/scripts/generate-docs-dashboard.sh"
do
  [[ -f "$path" ]] || { echo "FAIL: missing $path"; exit 1; }
done

# Package-root CI gate (not copied into skill install tree; must exist for consumers)
[[ -f "$ROOT/scripts/audit-claims.sh" ]] || { echo "FAIL: missing scripts/audit-claims.sh"; exit 1; }
[[ -f "$ROOT/.github/workflows/docs-audit.yml" ]] || { echo "FAIL: missing docs-audit workflow"; exit 1; }

grep -q "BEGIN documentation-manager skill" "$FAKE_HOME/.codex/AGENTS.md" \
  || { echo "FAIL: codex block missing"; exit 1; }

echo "✓ First install OK"

echo "→ Re-run (idempotent)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" 2>&1 | cat
COUNT=$(grep -c "BEGIN documentation-manager skill" "$FAKE_HOME/.codex/AGENTS.md" || true)
[[ "$COUNT" -eq 1 ]] || { echo "FAIL: codex block duplicated ($COUNT)"; exit 1; }
echo "✓ Idempotent OK"

echo "→ Uninstall"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --uninstall 2>&1 | cat

[[ ! -e "$FAKE_HOME/.grok/skills/documentation-manager" ]] || { echo "FAIL: still present after uninstall"; exit 1; }
grep -q "BEGIN documentation-manager skill" "$FAKE_HOME/.codex/AGENTS.md" 2>/dev/null \
  && { echo "FAIL: codex block still present"; exit 1; }

echo "✓ Uninstall OK"
echo ""
echo "✅ All smoke tests passed"
