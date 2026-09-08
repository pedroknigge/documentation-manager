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
mkdir -p "$FAKE_HOME/.grok" "$FAKE_HOME/.claude" "$FAKE_HOME/.codex" "$FAKE_HOME/.agents" \
  "$FAKE_HOME/.gemini/config/skills" "$FAKE_HOME/.gemini/antigravity/skills"

echo "→ First install"
HOME="$FAKE_HOME" bash "$INSTALL_SH" 2>&1 | cat

for path in \
  "$FAKE_HOME/.grok/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.claude/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.gemini/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.gemini/skills/documentation-manager/scripts/audit-claims.sh" \
  "$FAKE_HOME/.gemini/config/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.gemini/config/skills/documentation-manager/scripts/audit-claims.sh" \
  "$FAKE_HOME/.gemini/antigravity/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.gemini/antigravity/skills/documentation-manager/scripts/audit-claims.sh" \
  "$FAKE_HOME/.agents/skills/documentation-manager/SKILL.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/modes.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/skill-discovery.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/plan-template.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/living-claims.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/references/prototype-to-production.md" \
  "$FAKE_HOME/.agents/skills/documentation-manager/scripts/generate-docs-dashboard.sh" \
  "$FAKE_HOME/.agents/skills/documentation-manager/scripts/audit-claims.sh" \
  "$FAKE_HOME/.agents/skills/documentation-manager/scripts/detect-stack.sh" \
  "$FAKE_HOME/.agents/skills/documentation-manager/scripts/detect-packages.sh" \
  "$FAKE_HOME/.agents/skills/documentation-manager/scripts/survey-docs.sh"
do
  [[ -f "$path" ]] || { echo "FAIL: missing $path"; exit 1; }
done

for script in audit-claims.sh detect-stack.sh detect-packages.sh survey-docs.sh generate-docs-dashboard.sh; do
  [[ -x "$FAKE_HOME/.agents/skills/documentation-manager/scripts/$script" ]] \
    || { echo "FAIL: not executable: $script"; exit 1; }
done

# Package-root copies remain SSOT (CI example + maintainer scripts stay here)
[[ -f "$ROOT/scripts/audit-claims.sh" ]] || { echo "FAIL: missing scripts/audit-claims.sh"; exit 1; }
[[ -f "$ROOT/.github/workflows/docs-audit.yml" ]] || { echo "FAIL: missing docs-audit workflow"; exit 1; }

grep -q "BEGIN documentation-manager skill" "$FAKE_HOME/.codex/AGENTS.md" \
  || { echo "FAIL: codex block missing"; exit 1; }

echo "✓ First install OK"

echo "→ Gemini official-only (no optional parents invented)"
FAKE_HOME_GEM="$TMPDIR/fakehome-gemini-only"
mkdir -p "$FAKE_HOME_GEM/.gemini" "$FAKE_HOME_GEM/.agents"
HOME="$FAKE_HOME_GEM" bash "$INSTALL_SH" 2>&1 | cat
[[ -x "$FAKE_HOME_GEM/.gemini/skills/documentation-manager/scripts/audit-claims.sh" ]] \
  || { echo "FAIL: missing Gemini official install + audit-claims.sh"; exit 1; }
[[ ! -e "$FAKE_HOME_GEM/.gemini/config" ]] \
  || { echo "FAIL: invented ~/.gemini/config when parent did not exist"; exit 1; }
[[ ! -e "$FAKE_HOME_GEM/.gemini/antigravity" ]] \
  || { echo "FAIL: invented ~/.gemini/antigravity when parent did not exist"; exit 1; }
echo "✓ Gemini official-only OK"

echo "→ Raw / curl install path (file:// stand-in, no local skill tree)"
RAW="$TMPDIR/raw"
mkdir -p "$RAW/skills/documentation-manager/references" "$RAW/scripts"
cp "$SKILL_SRC" "$RAW/skills/documentation-manager/SKILL.md"
cp "$ROOT/skills/documentation-manager/references/"*.md "$RAW/skills/documentation-manager/references/"
for script in audit-claims.sh detect-stack.sh detect-packages.sh survey-docs.sh generate-docs-dashboard.sh; do
  cp "$ROOT/scripts/$script" "$RAW/scripts/$script"
done
INSTALLER="$TMPDIR/installer"
mkdir -p "$INSTALLER"
cp "$INSTALL_SH" "$INSTALLER/install.sh"
FAKE_HOME_RAW="$TMPDIR/fakehome-raw"
mkdir -p "$FAKE_HOME_RAW/.claude" "$FAKE_HOME_RAW/.agents"
(
  cd "$INSTALLER"
  HOME="$FAKE_HOME_RAW" DOCUMENTATION_MANAGER_RAW="file://${RAW}" bash "$INSTALLER/install.sh"
) 2>&1 | cat
for script in audit-claims.sh detect-stack.sh detect-packages.sh survey-docs.sh generate-docs-dashboard.sh; do
  raw_script="$FAKE_HOME_RAW/.agents/skills/documentation-manager/scripts/$script"
  [[ -x "$raw_script" ]] || { echo "FAIL: raw install missing executable $script"; exit 1; }
done
echo "✓ Raw install path OK"

echo "→ Re-run (idempotent)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" 2>&1 | cat
COUNT=$(grep -c "BEGIN documentation-manager skill" "$FAKE_HOME/.codex/AGENTS.md" || true)
[[ "$COUNT" -eq 1 ]] || { echo "FAIL: codex block duplicated ($COUNT)"; exit 1; }
echo "✓ Idempotent OK"

echo "→ Uninstall"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --uninstall 2>&1 | cat

[[ ! -e "$FAKE_HOME/.grok/skills/documentation-manager" ]] || { echo "FAIL: still present after uninstall"; exit 1; }
[[ ! -e "$FAKE_HOME/.gemini/skills/documentation-manager" ]] || { echo "FAIL: Gemini official still present after uninstall"; exit 1; }
[[ ! -e "$FAKE_HOME/.gemini/config/skills/documentation-manager" ]] || { echo "FAIL: Gemini config still present after uninstall"; exit 1; }
[[ ! -e "$FAKE_HOME/.gemini/antigravity/skills/documentation-manager" ]] || { echo "FAIL: Gemini antigravity still present after uninstall"; exit 1; }
grep -q "BEGIN documentation-manager skill" "$FAKE_HOME/.codex/AGENTS.md" 2>/dev/null \
  && { echo "FAIL: codex block still present"; exit 1; }

echo "✓ Uninstall OK"
echo ""
echo "✅ All smoke tests passed"
