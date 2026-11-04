#!/usr/bin/env bash
# Unit + end-to-end tests for ci-surface.sh (Approach A).
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CI="$ROOT/scripts/ci-surface.sh"
FIX="$ROOT/scripts/fixtures/ci-surface"
VERCEL_FIX="$ROOT/scripts/fixtures/vercel-no-actions"
AUDIT="$ROOT/scripts/audit-claims.sh"
FAILS=0

fail() { echo "FAIL: $*" >&2; FAILS=$((FAILS + 1)); }
ok() { echo "✓ $*"; }

unset VERCEL || true
chmod +x "$CI" "$VERCEL_FIX/build-app.sh" "$VERCEL_FIX/simulate-control-plane.sh" "$AUDIT"

[[ -x "$CI" ]] || fail "missing ci-surface.sh"
command -v python3 >/dev/null 2>&1 || fail "python3 is required"

# Fixtures must stay anonymized: no absolute GitHub URLs, preview hosts, or raw SHAs.
if grep -R -E -q 'github\.com/.+/.+|vercel\.app|[0-9a-f]{40}' \
  "$FIX" "$VERCEL_FIX" --exclude='*.sh' --exclude='README.md'; then
  fail "CI fixtures contain a URL, preview host, or raw SHA"
fi

recipe_line='root="$(git rev-parse --show-toplevel)" && bash "$root/scripts/audit-claims.sh" "$root" && bash "$root/build-app.sh"'
got_recipe="$(bash "$CI" recipe --build 'bash "$root/build-app.sh"')"
[[ "$got_recipe" == "$recipe_line" ]] || fail "recipe mismatch: $got_recipe"
if printf '%s\n' "$got_recipe" | grep -E -q -- '--(list-changed|list-claims|upsert-claims|record-haken|cascade-recommend|group-by)'; then
  fail "recipe must not pass change-set flags"
fi
python3 - "$VERCEL_FIX/vercel.json" "$recipe_line" <<'PY' || fail "vercel.json buildCommand is not the recipe"
import json, sys
path, expect = sys.argv[1], sys.argv[2]
got = json.load(open(path))["buildCommand"]
sys.exit(0 if got == expect else 1)
PY
ok "recipe is the whole-matrix gate plus the framework command"

mkroot() {
  local dir
  dir="$(mktemp -d)"
  printf '%s\n' "$dir"
}

read_fix() {
  local root="$1" fixture="$2"
  bash "$CI" read --fixture "$fixture" "$root" 2>"$root/read.err" || true
}

# ─── detect ──────────────────────────────────────────────────────────────────
empty="$(mkroot)"
[[ "$(bash "$CI" detect "$empty")" == "surface=none" ]] || fail "empty tree should be surface=none"

gha="$(mkroot)"
mkdir -p "$gha/.github/workflows"
printf 'name: docs-audit\n' > "$gha/.github/workflows/docs-audit.yml"
[[ "$(bash "$CI" detect "$gha")" == "surface=github-actions" ]] || fail "workflow-only detect"

vercel_only="$(mkroot)"
printf '{}\n' > "$vercel_only/vercel.json"
[[ "$(bash "$CI" detect "$vercel_only")" == "surface=vercel" ]] || fail "vercel.json detect"
rm -f "$vercel_only/vercel.json"
mkdir -p "$vercel_only/.vercel"
printf '{}\n' > "$vercel_only/.vercel/project.json"
[[ "$(bash "$CI" detect "$vercel_only")" == "surface=vercel" ]] || fail ".vercel/project.json detect"
rm -rf "$vercel_only/.vercel"
[[ "$(VERCEL=1 bash "$CI" detect "$vercel_only")" == "surface=vercel" ]] || fail "VERCEL=1 detect"
unset VERCEL || true
printf '{}\n' > "$vercel_only/vercel.json"

both="$(mkroot)"
mkdir -p "$both/.github/workflows"
printf 'name: docs-audit\n' > "$both/.github/workflows/docs-audit.yml"
printf '{}\n' > "$both/vercel.json"
[[ "$(bash "$CI" detect "$both")" == "surface=both" ]] || fail "both-surfaces detect"

# This package ships Actions and no Vercel project file.
[[ "$(bash "$CI" detect "$ROOT")" == "surface=github-actions" ]] || fail "package root should detect github-actions"
ok "detect none / github-actions / vercel / both"

# ─── read: pinned success, absent snapshot, synthetic verdicts ───────────────
expect_read() {
  local root="$1" fixture="$2" want="$3" label="$4"
  local got
  got="$(bash "$CI" read --fixture "$fixture" "$root")" || fail "$label read exited non-zero"
  [[ "$got" == "$want" ]] || fail "$label: got [$got] want [$want]"
}

expect_read "$vercel_only" "$FIX/pass-vercel" "surface=vercel verdict=pass" "pinned pass"
# No Vercel project file: the success payload is not this repo's surface.
expect_read "$empty" "$FIX/pass-vercel" "surface=none verdict=absent" "payload without a surface"
expect_read "$empty" "$FIX/absent-actions-only" "surface=none verdict=absent" "actions-only snapshot, no surface"
expect_read "$gha" "$FIX/absent-actions-only" "surface=github-actions verdict=absent" "actions jobs are not docs-audit"

write_status_tree() {
  # $1 root already has vercel.json from vercel_only when reused; this writes a fixture dir
  local dest="$1"
  mkdir -p "$dest"
  python3 - "$dest" "${@:2}" <<'PY'
import json, sys
dest = sys.argv[1]
# remaining args are key=value for the Vercel commit status, then optional extras via env files
# argv: dest context state description
_, dest, context, state, description = sys.argv[:5]
extra = sys.argv[5:]
status = {
    "state": state,
    "total_count": 1,
    "statuses": [{
        "state": state,
        "description": description,
        "context": context,
    }],
}
json.dump(status, open(dest + "/status.json", "w"))
json.dump({"total_count": 0, "check_runs": []}, open(dest + "/check-runs.json", "w"))
json.dump([], open(dest + "/deployments.json", "w"))
PY
}

pending_dir="$(mkroot)"
write_status_tree "$pending_dir" "Vercel" "pending" "Deployment is building"
expect_read "$vercel_only" "$pending_dir" "surface=vercel verdict=pending" "pending"

fail_dir="$(mkroot)"
write_status_tree "$fail_dir" "Vercel" "failure" "Deployment has failed"
expect_read "$vercel_only" "$fail_dir" "surface=vercel verdict=fail" "failure state"

err_dir="$(mkroot)"
write_status_tree "$err_dir" "Vercel" "error" "Deployment has failed"
expect_read "$vercel_only" "$err_dir" "surface=vercel verdict=fail" "error state"

skip_dir="$(mkroot)"
write_status_tree "$skip_dir" "Vercel" "success" "Skipped"
expect_read "$vercel_only" "$skip_dir" "surface=vercel verdict=absent" "skipped description"

ign_dir="$(mkroot)"
write_status_tree "$ign_dir" "Vercel" "success" "Ignored Build Step"
expect_read "$vercel_only" "$ign_dir" "surface=vercel verdict=absent" "ignored description"

can_dir="$(mkroot)"
write_status_tree "$can_dir" "Vercel" "success" "Canceled"
expect_read "$vercel_only" "$can_dir" "surface=vercel verdict=absent" "canceled description"

unk_dir="$(mkroot)"
write_status_tree "$unk_dir" "custom-ci" "success" "Deployment has completed"
expect_read "$vercel_only" "$unk_dir" "surface=vercel verdict=absent" "unknown context"

prefix_dir="$(mkroot)"
write_status_tree "$prefix_dir" "Vercel – example" "success" "Deployment has completed"
expect_read "$vercel_only" "$prefix_dir" "surface=vercel verdict=absent" "context must be exactly Vercel"

# Deployment created by vercel[bot] with inactive/canceled state, no commit status.
bot_dir="$(mkroot)"
python3 - "$bot_dir" <<'PY'
import json, sys
dest = sys.argv[1]
json.dump({"state": "pending", "total_count": 0, "statuses": []}, open(dest + "/status.json", "w"))
json.dump({"total_count": 0, "check_runs": []}, open(dest + "/check-runs.json", "w"))
json.dump([{
    "id": 9,
    "environment": "Preview",
    "creator": {"login": "vercel[bot]", "type": "Bot"},
    "statuses": [{
        "state": "inactive",
        "description": "Canceled",
        "environment": "Preview",
        "creator": {"login": "vercel[bot]", "type": "Bot"},
    }],
}], open(dest + "/deployments.json", "w"))
PY
expect_read "$vercel_only" "$bot_dir" "surface=vercel verdict=absent" "vercel[bot] canceled deployment"

# Comments check success must not count as the deployment.
comments_dir="$(mkroot)"
python3 - "$comments_dir" <<'PY'
import json, sys
dest = sys.argv[1]
json.dump({"state": "success", "total_count": 0, "statuses": []}, open(dest + "/status.json", "w"))
json.dump({"total_count": 1, "check_runs": [{
    "name": "Vercel Preview Comments",
    "status": "completed",
    "conclusion": "success",
    "app": {"slug": "vercel"},
}]}, open(dest + "/check-runs.json", "w"))
json.dump([], open(dest + "/deployments.json", "w"))
PY
expect_read "$vercel_only" "$comments_dir" "surface=vercel verdict=absent" "comments check is not the gate"

# Both surfaces.
both_pass="$(mkroot)"
python3 - "$both_pass" "$FIX/pass-vercel" <<'PY'
import json, os, shutil, sys
dest, src = sys.argv[1], sys.argv[2]
os.makedirs(dest, exist_ok=True)
for name in ("status.json", "check-runs.json", "deployments.json"):
    shutil.copy(os.path.join(src, name), os.path.join(dest, name))
runs = json.load(open(dest + "/check-runs.json"))
runs["check_runs"].append({
    "name": "Structural claims audit",
    "status": "completed",
    "conclusion": "success",
    "app": {"slug": "github-actions"},
})
runs["total_count"] = len(runs["check_runs"])
json.dump(runs, open(dest + "/check-runs.json", "w"))
PY
expect_read "$both" "$both_pass" "surface=both verdict=pass" "both pass"

both_fail="$(mkroot)"
python3 - "$both_fail" "$both_pass" <<'PY'
import json, os, shutil, sys
dest, src = sys.argv[1], sys.argv[2]
os.makedirs(dest, exist_ok=True)
for name in ("status.json", "check-runs.json", "deployments.json"):
    shutil.copy(os.path.join(src, name), os.path.join(dest, name))
status = json.load(open(dest + "/status.json"))
status["state"] = "failure"
for item in status["statuses"]:
    if item.get("context") == "Vercel":
        item["state"] = "failure"
        item["description"] = "Deployment has failed"
json.dump(status, open(dest + "/status.json", "w"))
deps = json.load(open(dest + "/deployments.json"))
for dep in deps:
    for item in dep.get("statuses") or []:
        item["state"] = "failure"
        item["description"] = "Deployment has failed"
json.dump(deps, open(dest + "/deployments.json", "w"))
PY
expect_read "$both" "$both_fail" "surface=both verdict=fail" "vercel fail blocks actions pass"

both_absent="$(mkroot)"
python3 - "$both_absent" <<'PY'
import json, sys
dest = sys.argv[1]
json.dump({"state": "success", "total_count": 0, "statuses": []}, open(dest + "/status.json", "w"))
json.dump({"total_count": 1, "check_runs": [{
    "name": "Structural claims audit",
    "status": "completed",
    "conclusion": "success",
    "app": {"slug": "github-actions"},
}]}, open(dest + "/check-runs.json", "w"))
json.dump([], open(dest + "/deployments.json", "w"))
PY
expect_read "$both" "$both_absent" "surface=both verdict=absent" "actions pass with no vercel signal"

# Actions cancelled is absent, not fail.
gha_cancel="$(mkroot)"
python3 - "$gha_cancel" <<'PY'
import json, sys
dest = sys.argv[1]
json.dump({"statuses": []}, open(dest + "/status.json", "w"))
json.dump({"check_runs": [{
    "name": "Structural claims audit",
    "status": "completed",
    "conclusion": "cancelled",
    "app": {"slug": "github-actions"},
}]}, open(dest + "/check-runs.json", "w"))
json.dump([], open(dest + "/deployments.json", "w"))
PY
expect_read "$gha" "$gha_cancel" "surface=github-actions verdict=absent" "cancelled docs-audit job"

gha_fail="$(mkroot)"
python3 - "$gha_fail" <<'PY'
import json, sys
dest = sys.argv[1]
json.dump({"statuses": []}, open(dest + "/status.json", "w"))
json.dump({"check_runs": [{
    "name": "Structural claims audit",
    "status": "completed",
    "conclusion": "failure",
    "app": {"slug": "github-actions"},
}]}, open(dest + "/check-runs.json", "w"))
json.dump([], open(dest + "/deployments.json", "w"))
PY
expect_read "$gha" "$gha_fail" "surface=github-actions verdict=fail" "failed docs-audit job"

gha_pend="$(mkroot)"
python3 - "$gha_pend" <<'PY'
import json, sys
dest = sys.argv[1]
json.dump({"statuses": []}, open(dest + "/status.json", "w"))
json.dump({"check_runs": [{
    "name": "Structural claims audit",
    "status": "in_progress",
    "conclusion": None,
    "app": {"slug": "github-actions"},
}]}, open(dest + "/check-runs.json", "w"))
json.dump([], open(dest + "/deployments.json", "w"))
PY
expect_read "$gha" "$gha_pend" "surface=github-actions verdict=pending" "in-progress docs-audit job"

# --live does not call the network when gh is missing.
live_rc=0
PATH="/var/empty:$PATH" bash "$CI" read --live "$empty" >/dev/null 2>"$empty/live.err" || live_rc=$?
[[ "$live_rc" -eq 2 ]] || fail "--live without gh must exit 2, got $live_rc"
ok "read pass / fail / pending / absent (skip, ignore, cancel, unknown, both)"

# Usage.
use_rc=0
bash "$CI" read >/dev/null 2>&1 || use_rc=$?
[[ "$use_rc" -eq 2 ]] || fail "read without fixture must exit 2, got $use_rc"
use_rc=0
bash "$CI" nosuch >/dev/null 2>&1 || use_rc=$?
[[ "$use_rc" -eq 2 ]] || fail "unknown command must exit 2, got $use_rc"

# ─── E2E: no Actions, real buildCommand, simulated control plane ─────────────
e2e="$(mkroot)"
cp -R "$VERCEL_FIX/." "$e2e/"
mkdir -p "$e2e/scripts" "$e2e/docs/audit" "$e2e/packages/web"
cp "$AUDIT" "$e2e/scripts/audit-claims.sh"
chmod +x "$e2e/scripts/audit-claims.sh" "$e2e/build-app.sh" "$e2e/simulate-control-plane.sh"
cp "$ROOT/scripts/fixtures/claims-fail/docs/audit/claims-matrix.md" "$e2e/docs/audit/claims-matrix.md"
git -C "$e2e" init -q
[[ ! -e "$e2e/.github" ]] || fail "e2e fixture must not contain .github"
[[ "$(bash "$CI" detect "$e2e")" == "surface=vercel" ]] || fail "e2e detect should be vercel"

build_cmd="$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["buildCommand"])' "$e2e/vercel.json")"
fail_rc=0
( cd "$e2e/packages/web" && bash -lc "$build_cmd" ) >"$e2e/fail-build.out" 2>"$e2e/fail-build.err" || fail_rc=$?
[[ "$fail_rc" -ne 0 ]] || fail "failing matrix must make buildCommand exit non-zero"
[[ ! -f "$e2e/build-stamp" ]] || fail "framework build ran after a failing audit"

fail_plane="$e2e/control-fail"
bash "$e2e/simulate-control-plane.sh" "$fail_rc" "$FIX/pass-vercel" "$fail_plane"
fail_read="$(bash "$CI" read --fixture "$fail_plane" "$e2e")"
[[ "$fail_read" == "surface=vercel verdict=fail" ]] || fail "e2e fail read: $fail_read"

cp "$ROOT/scripts/fixtures/claims-pass/docs/audit/claims-matrix.md" "$e2e/docs/audit/claims-matrix.md"
pass_rc=0
( cd "$e2e/packages/web" && bash -lc "$build_cmd" ) >"$e2e/pass-build.out" 2>"$e2e/pass-build.err" || pass_rc=$?
[[ "$pass_rc" -eq 0 ]] || fail "passing matrix must let buildCommand exit 0, got $pass_rc"
[[ "$(cat "$e2e/build-stamp")" == "FRAMEWORK_BUILD_RAN" ]] || fail "framework build did not run after a passing audit"

pass_plane="$e2e/control-pass"
bash "$e2e/simulate-control-plane.sh" "$pass_rc" "$FIX/pass-vercel" "$pass_plane"
pass_read="$(bash "$CI" read --fixture "$pass_plane" "$e2e")"
[[ "$pass_read" == "surface=vercel verdict=pass" ]] || fail "e2e pass read: $pass_read"

echo "E2E ci-surface"
echo "cwd=packages/web"
echo "buildCommand=$build_cmd"
echo "fail-build-exit=$fail_rc"
echo "fail-stamp=absent"
echo "fail-read=$fail_read"
echo "pass-build-exit=$pass_rc"
echo "pass-stamp=$(cat "$e2e/build-stamp")"
echo "pass-read=$pass_read"
ok "e2e no-Actions buildCommand + simulated Vercel control plane"

rm -rf "$empty" "$gha" "$vercel_only" "$both" "$pending_dir" "$fail_dir" "$err_dir" \
  "$skip_dir" "$ign_dir" "$can_dir" "$unk_dir" "$prefix_dir" "$bot_dir" "$comments_dir" \
  "$both_pass" "$both_fail" "$both_absent" "$gha_cancel" "$gha_fail" "$gha_pend" "$e2e"

if [[ "$FAILS" -ne 0 ]]; then
  echo "ci-surface tests: $FAILS failed" >&2
  exit 1
fi
echo "ci-surface tests passed"
