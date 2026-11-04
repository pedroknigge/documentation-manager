#!/usr/bin/env bash
# Copy the sanitized Vercel success payload into a control-plane directory.
# A non-zero build exit flips the deployment gate to failure and leaves the
# comments check green, so a comments check cannot mask a failed build.
# Usage: simulate-control-plane.sh <build-exit> <pass-fixture-dir> <out-dir>
set -euo pipefail

build_exit="${1:?build exit required}"
src="${2:?pass fixture dir required}"
out="${3:?output dir required}"

mkdir -p "$out"
cp "$src/status.json" "$src/check-runs.json" "$src/deployments.json" "$out/"

if [[ "$build_exit" -eq 0 ]]; then
  exit 0
fi

python3 - "$out" <<'PY'
import json, sys
out = sys.argv[1]

def flip_status(obj):
    if obj.get("context") == "Vercel" or (
        isinstance(obj.get("creator"), dict) and obj["creator"].get("login") == "vercel[bot]" and "state" in obj
    ):
        obj["state"] = "failure"
        obj["description"] = "Deployment has failed"

status = json.load(open(out + "/status.json"))
status["state"] = "failure"
for item in status.get("statuses") or []:
    flip_status(item)
json.dump(status, open(out + "/status.json", "w"))

deps = json.load(open(out + "/deployments.json"))
for dep in deps:
    for item in dep.get("statuses") or []:
        flip_status(item)
json.dump(deps, open(out + "/deployments.json", "w"))
PY
