#!/usr/bin/env bash
# test-skill-hardening.sh — fixtures, golden mode anchors, version sync, dashboard smoke
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_DIR="$ROOT/skills/documentation-manager"
SKILL_FILE="$SKILL_DIR/SKILL.md"
MODES="$SKILL_DIR/references/modes.md"
FIX="$ROOT/scripts/fixtures"
FAILS=0

fail() { echo "FAIL: $*" >&2; FAILS=$((FAILS + 1)); }
ok()   { echo "✓ $*"; }

echo "→ Skill hardening tests ($ROOT)"

# ─── Version single source of truth ──────────────────────────────────────────
FM=$(awk 'BEGIN{n=0} /^---$/{n++; next} n==1{print} n==2{exit}' "$SKILL_FILE")
VER=$(echo "$FM" | awk -F'"' '/version:/{print $2; exit}')
[[ -n "$VER" ]] || VER=$(echo "$FM" | awk -F"'" '/version:/{print $2; exit}')
[[ -n "$VER" ]] || fail "no version in SKILL.md frontmatter"
ok "SKILL version: $VER"

grep -q "v${VER}" "$ROOT/README.md" || fail "README.md missing v${VER}"
grep -q "skill-${VER}" "$ROOT/README.md" || grep -q "skill-$VER" "$ROOT/README.md" \
  || fail "README.md badge missing skill-${VER}"
grep -q "skill version \*\*${VER}\*\*" "$ROOT/AGENTS.md" \
  || grep -q "**${VER}**" "$ROOT/AGENTS.md" \
  || fail "AGENTS.md missing skill version ${VER}"
ok "version sync README + AGENTS ↔ SKILL ($VER)"

# ─── Fixtures present ───────────────────────────────────────────────────────
for f in thin-repo mature-repo no-docs-repo golden/autopilot-cases.tsv; do
  [[ -e "$FIX/$f" ]] || fail "missing fixture $f"
done
ok "fixtures present (thin, mature, no-docs, golden)"

# thin: code, no hub/docs
[[ -f "$FIX/thin-repo/src/app/index.ts" ]] || fail "thin-repo missing code"
[[ ! -f "$FIX/thin-repo/AGENTS.md" ]] || fail "thin-repo should not have AGENTS.md"
[[ ! -d "$FIX/thin-repo/docs" ]] || fail "thin-repo should not have docs/"
ok "thin-repo shape"

# mature: hub + feature + plan + code
[[ -f "$FIX/mature-repo/AGENTS.md" ]] || fail "mature missing AGENTS.md"
[[ -f "$FIX/mature-repo/docs/features/billing/README.md" ]] || fail "mature missing feature pack"
[[ -f "$FIX/mature-repo/docs/plans/invite/README.md" ]] || fail "mature missing plan"
[[ -f "$FIX/mature-repo/src/billing/index.ts" ]] || fail "mature missing billing code"
ok "mature-repo shape"

# no-docs: only readme-ish
[[ -f "$FIX/no-docs-repo/README.md" ]] || fail "no-docs missing README"
[[ ! -d "$FIX/no-docs-repo/docs" ]] || fail "no-docs should not have docs/"
ok "no-docs-repo shape"

# ─── Golden autopilot anchors (regression of decision table prose) ───────────
GOLDEN="$FIX/golden/autopilot-cases.tsv"
[[ -f "$GOLDEN" ]] || fail "missing golden TSV"
GCOUNT=0
while IFS=$'\t' read -r id signal mode path anchor || [[ -n "${id:-}" ]]; do
  [[ -z "${id:-}" || "$id" =~ ^# ]] && continue
  [[ "$id" == "id" ]] && continue
  GCOUNT=$((GCOUNT + 1))
  if ! grep -F -q -- "$anchor" "$SKILL_FILE" && ! grep -F -q -- "$anchor" "$MODES"; then
    fail "golden $id: anchor not found in SKILL/modes: $anchor"
  fi
done < "$GOLDEN"
[[ "$GCOUNT" -ge 8 ]] || fail "expected ≥8 golden cases, got $GCOUNT"
ok "golden autopilot anchors ($GCOUNT cases)"

# Explicit mode contracts that must not regress
for pair in \
  "Always-on non-writes:$MODES" \
  "Kind refinement:$MODES" \
  "Implementation bridge:$MODES" \
  "ArkGate bridge:$MODES" \
  "Knowledge dashboard:$MODES" \
  "from-zero:$SKILL_FILE" \
  "Code wins:$SKILL_FILE" \
  "Feature autopilot:$SKILL_FILE"
do
  text=${pair%%:*}
  file=${pair#*:}
  grep -F -q -- "$text" "$file" || fail "missing contract '$text' in $file"
done
ok "core mode contracts present"

# ─── Relative reference links from SKILL.md ──────────────────────────────────
# Extract markdown links to references/*.md
while IFS= read -r link; do
  rel=${link#references/}
  rel=${rel%%)*}
  rel=${rel%%#*}
  [[ -f "$SKILL_DIR/references/$rel" ]] || fail "SKILL.md broken link references/$rel"
done < <(grep -oE 'references/[a-zA-Z0-9._-]+\.md' "$SKILL_FILE" | sort -u)
ok "SKILL.md references/*.md links resolve"

# ─── Dashboard generator against mature fixture ──────────────────────────────
GEN="$ROOT/scripts/generate-docs-dashboard.sh"
if [[ -x "$GEN" || -f "$GEN" ]]; then
  chmod +x "$GEN" 2>/dev/null || true
  OUT="$FIX/mature-repo/docs/audit/generated/dashboard.html"
  rm -f "$OUT"
  bash "$GEN" "$FIX/mature-repo" >/dev/null
  [[ -f "$OUT" ]] || fail "dashboard not generated for mature-repo"
  grep -q "billing" "$OUT" || fail "dashboard missing billing feature"
  grep -q "invite" "$OUT" || fail "dashboard missing invite plan"
  grep -q "View only" "$OUT" || fail "dashboard missing View only banner"
  # status_class regression: Not Shipped must not be ok class alone — check helper via source
  if grep -q '\*shipped\*' "$GEN" && ! grep -q 'not\\ shipped\|not shipped' "$GEN"; then
    fail "status_class may false-positive on Not Shipped (need negate patterns)"
  fi
  ok "dashboard generator smoke on mature-repo"
  rm -rf "$FIX/mature-repo/docs/audit"
else
  fail "generate-docs-dashboard.sh missing"
fi

# ─── install.sh ships required remote refs (hardening regression) ────────────
for ref in plan-template.md arkgate-bridge.md implementation-bridge.md knowledge-dashboard.md; do
  grep -q "$ref" "$ROOT/install.sh" || fail "install.sh remote list missing $ref"
done
ok "install.sh remote reference list includes v1.3–1.6 files"

# ─── Discovery procedure present ─────────────────────────────────────────────
DISC="$SKILL_DIR/references/skill-discovery.md"
[[ -f "$DISC" ]] || fail "missing references/skill-discovery.md"
grep -q "upgrade" "$DISC" || fail "skill-discovery missing upgrade guidance"
grep -q "version" "$DISC" || fail "skill-discovery missing version detection"
ok "skill-discovery procedure present"

# ─── v2.0 adoption matrix + changelog ────────────────────────────────────────
[[ -f "$ROOT/docs/adoption-matrix.md" ]] || fail "missing docs/adoption-matrix.md"
grep -q "Verified" "$ROOT/docs/adoption-matrix.md" || fail "adoption-matrix missing Verified token"
grep -q "ArkGate" "$ROOT/docs/adoption-matrix.md" || fail "adoption-matrix missing ArkGate pairing"
[[ -f "$ROOT/CHANGELOG.md" ]] || fail "missing CHANGELOG.md"
grep -q "2.0.0" "$ROOT/CHANGELOG.md" || fail "CHANGELOG.md missing 2.0.0"
[[ -f "$ROOT/docs/features/tenx-v2-release/README.md" ]] || fail "missing tenx-v2-release feature pack"
ok "v2.0 adoption matrix + CHANGELOG + tenx feature pack"

if [[ "$FAILS" -gt 0 ]]; then
  echo ""
  echo "❌ Hardening failed: $FAILS issue(s)"
  exit 1
fi

echo ""
echo "✅ Skill hardening tests passed"
