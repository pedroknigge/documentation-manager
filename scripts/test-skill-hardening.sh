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
for f in thin-repo mature-repo no-docs-repo python-thin-repo go-thin-repo golden/autopilot-cases.tsv; do
  [[ -e "$FIX/$f" ]] || fail "missing fixture $f"
done
ok "fixtures present (thin, mature, no-docs, python-thin, go-thin, golden)"

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

# python-thin: polyglot non-TS fixture (no hub/docs, no invented APIs)
[[ -f "$FIX/python-thin-repo/pyproject.toml" ]] || fail "python-thin missing pyproject.toml"
[[ -f "$FIX/python-thin-repo/src/hello_app/__init__.py" ]] || fail "python-thin missing package source"
[[ ! -f "$FIX/python-thin-repo/AGENTS.md" ]] || fail "python-thin should not have AGENTS.md"
[[ ! -d "$FIX/python-thin-repo/docs" ]] || fail "python-thin should not have docs/"
[[ ! -f "$FIX/python-thin-repo/package.json" ]] || fail "python-thin should not be node"
ok "python-thin-repo shape"

# go-thin: polyglot non-TS fixture
[[ -f "$FIX/go-thin-repo/go.mod" ]] || fail "go-thin missing go.mod"
[[ -f "$FIX/go-thin-repo/cmd/hello/main.go" ]] || fail "go-thin missing cmd entry"
[[ -f "$FIX/go-thin-repo/internal/greet/greet.go" ]] || fail "go-thin missing internal package"
[[ ! -f "$FIX/go-thin-repo/AGENTS.md" ]] || fail "go-thin should not have AGENTS.md"
[[ ! -d "$FIX/go-thin-repo/docs" ]] || fail "go-thin should not have docs/"
ok "go-thin-repo shape"

# ─── detect-stack.sh drives real fixtures (shipped entry point) ─────────────
DETECT="$ROOT/scripts/detect-stack.sh"
[[ -f "$DETECT" ]] || fail "missing scripts/detect-stack.sh"
chmod +x "$DETECT" 2>/dev/null || true
node_out=$(bash "$DETECT" "$FIX/thin-repo")
echo "$node_out" | grep -qw "node-ts" || fail "detect-stack thin-repo expected node-ts, got: $node_out"
py_out=$(bash "$DETECT" "$FIX/python-thin-repo")
echo "$py_out" | grep -qw "python" || fail "detect-stack python-thin expected python, got: $py_out"
echo "$py_out" | grep -qw "node-ts" && fail "detect-stack python-thin must not report node-ts: $py_out"
go_out=$(bash "$DETECT" "$FIX/go-thin-repo")
echo "$go_out" | grep -qw "go" || fail "detect-stack go-thin expected go, got: $go_out"
echo "$go_out" | grep -qw "node-ts" && fail "detect-stack go-thin must not report node-ts: $go_out"
# Negative: orphan go.sum or cmd+internal without go.mod must not claim go
_edge=$(mktemp -d)
touch "$_edge/go.sum"
edge_out=$(bash "$DETECT" "$_edge")
echo "$edge_out" | grep -qw "go" && fail "detect-stack orphan go.sum must not report go, got: $edge_out"
rm -rf "$_edge"
_edge=$(mktemp -d)
mkdir -p "$_edge/cmd" "$_edge/internal"
edge_out=$(bash "$DETECT" "$_edge")
echo "$edge_out" | grep -qw "go" && fail "detect-stack cmd+internal without go.mod must not report go, got: $edge_out"
rm -rf "$_edge"
ok "detect-stack.sh on node + python + go fixtures (+ negative go edges)"

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

# ─── Polyglot stack detection anchors (Slice A) ──────────────────────────────
for anchor in \
  "Polyglot stack detection" \
  "pyproject.toml" \
  "go.mod" \
  "package.json" \
  "Inventory by stack" \
  "Docs layout guidance by stack"
do
  grep -F -q -- "$anchor" "$DISC" || fail "skill-discovery missing polyglot anchor: $anchor"
done
grep -F -q "Polyglot stack detection" "$MODES" || fail "modes.md missing Polyglot stack detection"
grep -F -q "Inventory by stack" "$MODES" || fail "modes.md missing Inventory by stack"
grep -F -q "Stack detection first" "$MODES" || fail "modes.md from-zero missing Stack detection first"
grep -F -q "Polyglot stack detection" "$SKILL_FILE" || fail "SKILL.md missing Polyglot stack detection"
grep -F -q "Polyglot stack detection" "$SKILL_DIR/references/quality-checklist.md" \
  || fail "quality-checklist missing Polyglot stack detection"
ok "polyglot stack detection anchors (discovery + modes + SKILL + QC)"

# ─── v2.0 adoption matrix + changelog + polyglot feature pack ────────────────
[[ -f "$ROOT/docs/adoption-matrix.md" ]] || fail "missing docs/adoption-matrix.md"
grep -q "Verified" "$ROOT/docs/adoption-matrix.md" || fail "adoption-matrix missing Verified token"
grep -q "ArkGate" "$ROOT/docs/adoption-matrix.md" || fail "adoption-matrix missing ArkGate pairing"
[[ -f "$ROOT/CHANGELOG.md" ]] || fail "missing CHANGELOG.md"
grep -q "2.0.0" "$ROOT/CHANGELOG.md" || fail "CHANGELOG.md missing 2.0.0"
grep -q "${VER}" "$ROOT/CHANGELOG.md" || fail "CHANGELOG.md missing current version ${VER}"
[[ -f "$ROOT/docs/features/tenx-v2-release/README.md" ]] || fail "missing tenx-v2-release feature pack"
[[ -f "$ROOT/docs/features/polyglot-mvp/README.md" ]] || fail "missing polyglot-mvp feature pack"
grep -q "Shipped" "$ROOT/docs/features/polyglot-mvp/README.md" || fail "polyglot-mvp pack not marked Shipped"
grep -q "Shipped" "$ROOT/docs/plans/phase-2-bridge/README.md" \
  || fail "phase-2-bridge plan should mark slice A shipped (grep Shipped)"
ok "adoption matrix + CHANGELOG + tenx + polyglot-mvp feature pack"

if [[ "$FAILS" -gt 0 ]]; then
  echo ""
  echo "❌ Hardening failed: $FAILS issue(s)"
  exit 1
fi

echo ""
echo "✅ Skill hardening tests passed"
