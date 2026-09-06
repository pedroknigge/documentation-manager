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
for f in thin-repo mature-repo no-docs-repo python-thin-repo go-thin-repo monorepo-thin \
  golden/autopilot-cases.tsv claims-pass claims-fail claims-none; do
  [[ -e "$FIX/$f" ]] || fail "missing fixture $f"
done
ok "fixtures present (thin, mature, no-docs, python-thin, go-thin, monorepo-thin, golden, claims-*)"

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

# monorepo-thin: multi-package workspace signals, no root hub/docs
[[ -f "$FIX/monorepo-thin/pnpm-workspace.yaml" ]] || fail "monorepo-thin missing pnpm-workspace.yaml"
[[ -f "$FIX/monorepo-thin/package.json" ]] || fail "monorepo-thin missing package.json"
[[ -f "$FIX/monorepo-thin/packages/api/package.json" ]] || fail "monorepo-thin missing packages/api"
[[ -f "$FIX/monorepo-thin/packages/web/package.json" ]] || fail "monorepo-thin missing packages/web"
[[ -f "$FIX/monorepo-thin/packages/api/src/index.ts" ]] || fail "monorepo-thin missing api code"
[[ -f "$FIX/monorepo-thin/packages/web/src/index.ts" ]] || fail "monorepo-thin missing web code"
[[ ! -f "$FIX/monorepo-thin/AGENTS.md" ]] || fail "monorepo-thin should not have root AGENTS.md"
[[ ! -d "$FIX/monorepo-thin/docs" ]] || fail "monorepo-thin should not have root docs/"
ok "monorepo-thin shape"

# ─── detect-packages.sh drives monorepo fixture (shipped entry point) ───────
DPKG="$ROOT/scripts/detect-packages.sh"
[[ -f "$DPKG" ]] || fail "missing scripts/detect-packages.sh"
chmod +x "$DPKG" 2>/dev/null || true
pkg_out=$(bash "$DPKG" "$FIX/monorepo-thin")
echo "$pkg_out" | grep -qx "packages/api" || fail "detect-packages expected packages/api, got: $pkg_out"
echo "$pkg_out" | grep -qx "packages/web" || fail "detect-packages expected packages/web, got: $pkg_out"
pkg_count=$(echo "$pkg_out" | grep -c . || true)
[[ "$pkg_count" -ge 2 ]] || fail "detect-packages monorepo-thin expected ≥2 packages, got $pkg_count"
# single-repo fixtures must not invent packages
single_out=$(bash "$DPKG" "$FIX/thin-repo")
[[ -z "${single_out// }" ]] || fail "detect-packages thin-repo should be empty, got: $single_out"
# go.work multi-module (temp) — shipped path must resolve use ( ./mod ) blocks
_gw=$(mktemp -d)
mkdir -p "$_gw/mod-a" "$_gw/mod-b"
printf 'module a\n' > "$_gw/mod-a/go.mod"
printf 'module b\n' > "$_gw/mod-b/go.mod"
cat > "$_gw/go.work" <<'EOF'
go 1.22
use (
	./mod-a
	./mod-b
)
EOF
gw_out=$(bash "$DPKG" "$_gw")
echo "$gw_out" | grep -qx "mod-a" || fail "detect-packages go.work expected mod-a, got: $gw_out"
echo "$gw_out" | grep -qx "mod-b" || fail "detect-packages go.work expected mod-b, got: $gw_out"
rm -rf "$_gw"
# npm workspaces only (no pnpm-workspace.yaml)
_nw=$(mktemp -d)
mkdir -p "$_nw/packages/a" "$_nw/packages/b"
printf '%s\n' '{"name":"root","private":true,"workspaces":["packages/*"]}' > "$_nw/package.json"
printf '%s\n' '{"name":"a"}' > "$_nw/packages/a/package.json"
printf '%s\n' '{"name":"b"}' > "$_nw/packages/b/package.json"
nw_out=$(bash "$DPKG" "$_nw")
echo "$nw_out" | grep -qx "packages/a" || fail "detect-packages npm workspaces expected packages/a, got: $nw_out"
echo "$nw_out" | grep -qx "packages/b" || fail "detect-packages npm workspaces expected packages/b, got: $nw_out"
rm -rf "$_nw"
ok "detect-packages.sh on monorepo-thin (+ empty thin + go.work + npm workspaces)"

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
for ref in plan-template.md arkgate-bridge.md implementation-bridge.md knowledge-dashboard.md \
  team-governance.md team-owners-template.md team-approval-notes-template.md \
  living-claims.md; do
  grep -q "$ref" "$ROOT/install.sh" || fail "install.sh remote list missing $ref"
done
grep -q "template-telemetry.md" "$ROOT/install.sh" \
  && fail "install.sh must not fetch withdrawn template-telemetry.md"
ok "install.sh remote reference list includes v1.3–2.5 skill refs (telemetry withdrawn)"

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

# ─── Monorepo hubs anchors (Slice B) ─────────────────────────────────────────
for anchor in \
  "Monorepo hubs" \
  "Package index" \
  "pnpm-workspace.yaml" \
  "go.work" \
  "Root hub = map" \
  "multi-package"
do
  grep -F -q -- "$anchor" "$DISC" || fail "skill-discovery missing monorepo anchor: $anchor"
done
grep -F -q "Monorepo hubs" "$MODES" || fail "modes.md missing Monorepo hubs"
grep -F -q "Package index" "$MODES" || fail "modes.md missing Package index"
grep -F -q "package non-writes" "$MODES" || fail "modes.md missing package non-writes"
grep -F -q "Monorepo hubs" "$SKILL_FILE" || fail "SKILL.md missing Monorepo hubs"
grep -F -q "Monorepo hubs" "$SKILL_DIR/references/quality-checklist.md" \
  || fail "quality-checklist missing Monorepo hubs"
grep -F -q "Package index" "$SKILL_DIR/references/agents-md-template.md" \
  || fail "agents-md-template missing Package index"
ok "monorepo hubs anchors (discovery + modes + SKILL + QC + hub template)"

# ─── Team governance anchors (Slice C) ───────────────────────────────────────
for f in team-governance.md team-owners-template.md team-approval-notes-template.md; do
  [[ -f "$SKILL_DIR/references/$f" ]] || fail "missing references/$f"
done
TG="$SKILL_DIR/references/team-governance.md"
for anchor in \
  "docs/team" \
  "OWNERS.md" \
  "approval-notes" \
  "create" \
  "link" \
  "Integrate-first" \
  "last approved" \
  "anti-wiki"
do
  grep -F -q -- "$anchor" "$TG" || fail "team-governance missing anchor: $anchor"
done
grep -F -q "Owner" "$SKILL_DIR/references/team-owners-template.md" || fail "team-owners-template missing Owner"
grep -F -q "Approved by" "$SKILL_DIR/references/team-approval-notes-template.md" \
  || fail "team-approval-notes-template missing Approved by"
grep -F -q "Team governance" "$MODES" || fail "modes.md missing Team governance"
grep -F -q "docs/team" "$MODES" || fail "modes.md missing docs/team"
grep -F -q "Team governance" "$SKILL_FILE" || fail "SKILL.md missing Team governance"
grep -F -q "docs/team" "$SKILL_FILE" || fail "SKILL.md missing docs/team"
grep -F -q "Team governance" "$SKILL_DIR/references/quality-checklist.md" \
  || fail "quality-checklist missing Team governance"
grep -F -q "docs/team/OWNERS.md" "$SKILL_DIR/references/agents-md-template.md" \
  || fail "agents-md-template missing docs/team/OWNERS.md"
ok "team governance anchors (templates + modes + SKILL + QC + hub)"

# ─── Template telemetry withdrawn (does not serve north star) ────────────────
[[ ! -f "$SKILL_DIR/references/template-telemetry.md" ]] \
  || fail "template-telemetry.md must stay withdrawn from skill tree"
[[ ! -f "$ROOT/scripts/template-telemetry.sh" ]] \
  || fail "template-telemetry.sh must stay withdrawn"
grep -F -q "Template telemetry" "$MODES" \
  && fail "modes.md must not keep a Template telemetry procedure"
grep -F -q "Template telemetry" "$SKILL_FILE" \
  && fail "SKILL.md must not keep a Template telemetry rule"
grep -F -q "Template telemetry" "$SKILL_DIR/references/quality-checklist.md" \
  && fail "quality-checklist must not keep a Template telemetry section"
ok "template telemetry withdrawn from skill tree + modes + QC"

# ─── v2.0 adoption matrix + changelog + feature packs ────────────────────────
[[ -f "$ROOT/docs/adoption-matrix.md" ]] || fail "missing docs/adoption-matrix.md"
grep -q "Verified" "$ROOT/docs/adoption-matrix.md" || fail "adoption-matrix missing Verified token"
grep -q "ArkGate" "$ROOT/docs/adoption-matrix.md" || fail "adoption-matrix missing ArkGate pairing"
[[ -f "$ROOT/CHANGELOG.md" ]] || fail "missing CHANGELOG.md"
grep -q "2.0.0" "$ROOT/CHANGELOG.md" || fail "CHANGELOG.md missing 2.0.0"
grep -q "${VER}" "$ROOT/CHANGELOG.md" || fail "CHANGELOG.md missing current version ${VER}"
[[ -f "$ROOT/docs/features/tenx-v2-release/README.md" ]] || fail "missing tenx-v2-release feature pack"
[[ -f "$ROOT/docs/features/polyglot-mvp/README.md" ]] || fail "missing polyglot-mvp feature pack"
grep -q "Shipped" "$ROOT/docs/features/polyglot-mvp/README.md" || fail "polyglot-mvp pack not marked Shipped"
[[ -f "$ROOT/docs/features/monorepo-hubs/README.md" ]] || fail "missing monorepo-hubs feature pack"
grep -q "Shipped" "$ROOT/docs/features/monorepo-hubs/README.md" || fail "monorepo-hubs pack not marked Shipped"
[[ -f "$ROOT/docs/features/team-governance/README.md" ]] || fail "missing team-governance feature pack"
grep -q "Shipped" "$ROOT/docs/features/team-governance/README.md" || fail "team-governance pack not marked Shipped"
[[ -f "$ROOT/docs/features/template-telemetry/README.md" ]] || fail "missing template-telemetry feature pack"
grep -q "Withdrawn" "$ROOT/docs/features/template-telemetry/README.md" \
  || fail "template-telemetry pack must be marked Withdrawn"
[[ -f "$ROOT/docs/features/living-claims/README.md" ]] || fail "missing living-claims feature pack"
grep -q "Shipped" "$ROOT/docs/features/living-claims/README.md" || fail "living-claims pack not marked Shipped"
grep -q "Shipped" "$ROOT/docs/plans/phase-2-bridge/README.md" \
  || fail "phase-2-bridge plan should mark slices shipped (grep Shipped)"
ok "adoption matrix + CHANGELOG + feature packs (incl. withdrawn telemetry + living-claims)"

# ─── Living claims CI audit entrypoint + fixtures (Knowledge OS first increment) ─
AUDIT="$ROOT/scripts/audit-claims.sh"
[[ -f "$AUDIT" ]] || fail "missing scripts/audit-claims.sh"
chmod +x "$AUDIT" 2>/dev/null || true
if grep -E -q '\b(curl|wget|nc)\b|https?://' "$AUDIT"; then
  fail "audit-claims.sh must not use network tools or URLs"
fi
[[ -f "$FIX/claims-pass/docs/audit/claims-matrix.md" ]] || fail "claims-pass missing matrix"
[[ -f "$FIX/claims-fail/docs/audit/claims-matrix.md" ]] || fail "claims-fail missing matrix"
[[ ! -f "$FIX/claims-none/docs/audit/claims-matrix.md" ]] || fail "claims-none must not have matrix"
if ! bash "$AUDIT" "$FIX/claims-pass" >/dev/null; then
  fail "audit-claims.sh must PASS on claims-pass fixture"
fi
if bash "$AUDIT" "$FIX/claims-fail" >/dev/null 2>&1; then
  fail "audit-claims.sh must FAIL on claims-fail (critical Contradicted)"
fi
if ! bash "$AUDIT" "$FIX/claims-none" >/dev/null 2>&1; then
  fail "audit-claims.sh must skip/warn exit 0 on claims-none"
fi
# --list-changed: light git helper; default matrix gate unchanged
grep -F -q -- "--list-changed" "$AUDIT" || fail "audit-claims.sh missing --list-changed"
TMPGIT="$(mktemp -d)"
git -C "$TMPGIT" init -q -b main
git -C "$TMPGIT" config user.email "audit-test@example.com"
git -C "$TMPGIT" config user.name "audit-test"
echo one > "$TMPGIT/tracked.txt"
git -C "$TMPGIT" add tracked.txt
git -C "$TMPGIT" commit -qm init
echo two >> "$TMPGIT/tracked.txt"
echo new > "$TMPGIT/untracked.txt"
CHANGED="$(bash "$AUDIT" --list-changed "$TMPGIT" || true)"
echo "$CHANGED" | grep -qx "tracked.txt" || fail "--list-changed must list dirty tracked.txt"
echo "$CHANGED" | grep -qx "untracked.txt" || fail "--list-changed must list untracked.txt"
if bash "$AUDIT" --base main "$TMPGIT" >/dev/null 2>&1; then
  fail "--base without --list-changed must fail"
fi
rm -rf "$TMPGIT"
[[ -f "$ROOT/.github/workflows/docs-audit.yml" ]] || fail "missing .github/workflows/docs-audit.yml"
grep -F -q "audit-claims.sh" "$ROOT/.github/workflows/docs-audit.yml" \
  || fail "docs-audit.yml must invoke audit-claims.sh"
if grep -E -q 'run:.*--list-changed' "$ROOT/.github/workflows/docs-audit.yml"; then
  fail "docs-audit.yml must not invoke --list-changed (CI gate is whole-matrix)"
fi
grep -E -q '\[x\].*\.github/workflows/docs-audit\.yml' "$ROOT/docs/plans/knowledge-os/README.md" \
  || fail "knowledge-os plan must mark the GitHub Actions example AC satisfied"
LC="$SKILL_DIR/references/living-claims.md"
[[ -f "$LC" ]] || fail "missing references/living-claims.md"
for anchor in "anchor.path" "severity" "critical" "Contradicted" "audit-claims"; do
  grep -F -qi -- "$anchor" "$LC" || fail "living-claims.md missing: $anchor"
done
grep -F -q "Living claims" "$SKILL_FILE" || fail "SKILL.md missing Living claims"
grep -F -q "Living claims" "$MODES" || fail "modes.md missing Living claims"
grep -F -q "Severity" "$SKILL_DIR/references/audit-template.md" \
  || fail "audit-template missing Severity"
ok "living-claims CI audit script + fixtures + GHA + skill anchors"

if [[ "$FAILS" -gt 0 ]]; then
  echo ""
  echo "❌ Hardening failed: $FAILS issue(s)"
  exit 1
fi

echo ""
echo "✅ Skill hardening tests passed"
