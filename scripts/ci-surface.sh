#!/usr/bin/env bash
# ci-surface.sh — detect which docs-audit CI surface a repo uses, and read one verdict.
#
# The gate process is still audit-claims.sh (whole matrix, no change-set flags).
# This script does not parse a claims matrix and does not poll.
#
#   ci-surface.sh detect [ROOT]
#       surface=github-actions|vercel|both|none
#
#   ci-surface.sh read --fixture DIR [ROOT]
#   ci-surface.sh read --live [ROOT]
#       surface=<same> verdict=pass|fail|pending|absent
#       exit 0 when a verdict was decided (fail is data)
#       exit 2 on usage, unreadable fixture, or --live without a usable gh/GitHub remote
#
#   ci-surface.sh recipe --build '<framework command>'
#       prints one buildCommand: audit-claims.sh from the git root, then the framework command.
#       The framework command is not invented. Omit --build and the audit half is printed alone.
#
# detect is offline. read --fixture is offline. read --live shells out to gh.
# GitLab, Bitbucket, and GitHub Enterprise Server are out of scope.
#
# Verdict policy (captain, 2026-11-04):
#   skipped / ignored / canceled → absent (never pass)
#   Actions and Vercel both present → both must pass
#   unknown context (not the pinned Vercel status, not vercel[bot], not slug vercel) → absent
#
# Pinned identifiers (sanitized GitHub responses; see scripts/fixtures/ci-surface/README.md):
#   commit status context == Vercel
#   check-run app.slug == vercel  (comments check "Vercel Preview Comments" is not the deployment)
#   check-run app.slug == github-actions AND name == Structural claims audit
#   deployment creator.login == vercel[bot]

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat <<EOF
Usage:
  $SCRIPT_NAME detect [ROOT]
  $SCRIPT_NAME read --fixture DIR [ROOT]
  $SCRIPT_NAME read --live [ROOT]
  $SCRIPT_NAME recipe [--build FRAMEWORK_CMD]
  $SCRIPT_NAME -h | --help

detect prints surface=github-actions|vercel|both|none.
read prints surface=<same> verdict=pass|fail|pending|absent.
recipe prints a buildCommand that runs audit-claims.sh (no change-set flags)
from the git root, then FRAMEWORK_CMD when --build is set.
EOF
}

surface_token() {
  local root="$1"
  local gha=0 vercel=0
  if [[ -f "$root/.github/workflows/docs-audit.yml" ]]; then
    gha=1
  fi
  if [[ -f "$root/vercel.json" || -f "$root/.vercel/project.json" || "${VERCEL:-}" == "1" ]]; then
    vercel=1
  fi
  if [[ "$gha" -eq 1 && "$vercel" -eq 1 ]]; then
    printf 'both\n'
  elif [[ "$gha" -eq 1 ]]; then
    printf 'github-actions\n'
  elif [[ "$vercel" -eq 1 ]]; then
    printf 'vercel\n'
  else
    printf 'none\n'
  fi
}

resolve_root() {
  local raw="${1:-.}"
  if [[ ! -d "$raw" ]]; then
    echo "$SCRIPT_NAME: not a directory: $raw" >&2
    exit 2
  fi
  (cd "$raw" && pwd)
}

cmd_detect() {
  local root
  root="$(resolve_root "${1:-.}")"
  printf 'surface=%s\n' "$(surface_token "$root")"
}

cmd_recipe() {
  local build=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --build)
        [[ $# -ge 2 ]] || { echo "$SCRIPT_NAME: --build requires a command" >&2; exit 2; }
        build="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "$SCRIPT_NAME: unknown recipe argument: $1" >&2
        exit 2
        ;;
    esac
  done
  local audit='root="$(git rev-parse --show-toplevel)" && bash "$root/scripts/audit-claims.sh" "$root"'
  if [[ -n "$build" ]]; then
    printf '%s && %s\n' "$audit" "$build"
  else
    echo "$SCRIPT_NAME: no --build; printing the audit half only. Append the existing framework command with &&." >&2
    printf '%s\n' "$audit"
  fi
}

github_slug() {
  local root="$1"
  local url
  url="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
  url="${url%.git}"
  url="${url%/}"
  local owner repo
  if [[ "$url" =~ github.com[:/]([^/]+)/([^/]+)$ ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
    printf '%s/%s\n' "$owner" "$repo"
    return 0
  fi
  echo "$SCRIPT_NAME: --live needs a GitHub origin remote (other forges are out of scope)" >&2
  return 2
}

cmd_read() {
  local fixture="" live=0 root_arg=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fixture)
        [[ $# -ge 2 ]] || { echo "$SCRIPT_NAME: --fixture requires a directory" >&2; exit 2; }
        fixture="$2"
        shift 2
        ;;
      --live)
        live=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "$SCRIPT_NAME: unknown read argument: $1" >&2
        exit 2
        ;;
      *)
        if [[ -n "$root_arg" ]]; then
          echo "$SCRIPT_NAME: unexpected argument: $1" >&2
          exit 2
        fi
        root_arg="$1"
        shift
        ;;
    esac
  done
  if [[ -n "$fixture" && "$live" -eq 1 ]]; then
    echo "$SCRIPT_NAME: pass only one of --fixture or --live" >&2
    exit 2
  fi
  if [[ -z "$fixture" && "$live" -eq 0 ]]; then
    echo "$SCRIPT_NAME: read requires --fixture DIR or --live" >&2
    exit 2
  fi
  local root
  root="$(resolve_root "${root_arg:-.}")"
  local surface
  surface="$(surface_token "$root")"

  local work=""
  if [[ "$live" -eq 1 ]]; then
    if ! command -v gh >/dev/null 2>&1; then
      echo "$SCRIPT_NAME: gh is required for --live" >&2
      exit 2
    fi
    if ! command -v python3 >/dev/null 2>&1; then
      echo "$SCRIPT_NAME: python3 is required to read CI payloads" >&2
      exit 2
    fi
    local slug sha
    slug="$(github_slug "$root")" || exit 2
    sha="$(git -C "$root" rev-parse HEAD 2>/dev/null || true)"
    if [[ -z "$sha" ]]; then
      echo "$SCRIPT_NAME: --live needs a git HEAD" >&2
      exit 2
    fi
    work="$(mktemp -d)"
    # shellcheck disable=SC2064
    trap 'rm -rf "$work"' RETURN
    if ! gh api "repos/${slug}/commits/${sha}/status" >"$work/status.json"; then
      echo "$SCRIPT_NAME: gh status read failed" >&2
      exit 2
    fi
    if ! gh api "repos/${slug}/commits/${sha}/check-runs?per_page=100" >"$work/check-runs.json"; then
      echo "$SCRIPT_NAME: gh check-runs read failed" >&2
      exit 2
    fi
    if ! gh api "repos/${slug}/deployments?sha=${sha}&per_page=100" >"$work/deployments.json"; then
      echo "$SCRIPT_NAME: gh deployments read failed" >&2
      exit 2
    fi
    python3 - "$work" "$slug" <<'PY' || exit 2
import json, subprocess, sys
work, slug = sys.argv[1], sys.argv[2]
deps = json.load(open(work + "/deployments.json"))
if isinstance(deps, dict):
    deps = deps.get("deployments") or deps.get("items") or []
out = []
for dep in deps:
    did = dep.get("id")
    if did is None:
        out.append(dep)
        continue
    proc = subprocess.run(
        ["gh", "api", f"repos/{slug}/deployments/{did}/statuses?per_page=100"],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        sys.stderr.write("ci-surface.sh: gh deployment statuses read failed\n")
        sys.exit(2)
    try:
        statuses = json.loads(proc.stdout or "[]")
    except json.JSONDecodeError:
        sys.stderr.write("ci-surface.sh: deployment statuses are not JSON\n")
        sys.exit(2)
    if isinstance(statuses, dict):
        statuses = statuses.get("statuses") or []
    dep = dict(dep)
    dep["statuses"] = statuses
    out.append(dep)
json.dump(out, open(work + "/deployments.json", "w"))
PY
    fixture="$work"
  fi

  if [[ ! -d "$fixture" ]]; then
    echo "$SCRIPT_NAME: fixture directory not found: $fixture" >&2
    exit 2
  fi
  if ! command -v python3 >/dev/null 2>&1; then
    echo "$SCRIPT_NAME: python3 is required to read CI payloads" >&2
    exit 2
  fi
  python3 - "$fixture" "$surface" <<'PY'
import json, os, re, sys

fixture, surface = sys.argv[1], sys.argv[2]
SKIP = re.compile(r"(skipped|ignored|canceled|cancelled)", re.I)
DOCS_JOB = "Structural claims audit"
VERCEL_CONTEXT = "Vercel"
VERCEL_BOT = "vercel[bot]"
COMMENTS_CHECK = "Vercel Preview Comments"

def load(name, default):
    path = os.path.join(fixture, name)
    if not os.path.isfile(path):
        return default
    try:
        with open(path) as fh:
            return json.load(fh)
    except json.JSONDecodeError:
        sys.stderr.write(f"ci-surface.sh: unreadable JSON: {name}\n")
        sys.exit(2)

def classify(state, description, life=None):
    desc = description or ""
    if SKIP.search(desc):
        return "absent"
    life_l = (life or "").lower()
    if life_l in {"queued", "in_progress", "pending", "waiting"}:
        return "pending"
    st = (state or "").lower()
    if st in {"skipped", "cancelled", "canceled", "neutral", "inactive"}:
        return "absent"
    if st in {"failure", "error", "timed_out"}:
        return "fail"
    if st in {"pending", "queued", "in_progress", "expected"}:
        return "pending"
    if st == "success":
        return "pass"
    return "absent"

def fold(values):
    if not values:
        return "absent"
    if "fail" in values:
        return "fail"
    if "pending" in values:
        return "pending"
    if "pass" in values:
        return "pass"
    return "absent"

def combine(parts):
    if not parts:
        return "absent"
    if "fail" in parts:
        return "fail"
    if "pending" in parts:
        return "pending"
    if all(p == "pass" for p in parts):
        return "pass"
    return "absent"

def latest(statuses):
    if not statuses:
        return None
    def key(item):
        return item.get("updated_at") or item.get("created_at") or ""
    if any(key(item) for item in statuses):
        return max(statuses, key=key)
    return statuses[0]

def check_runs():
    raw = load("check-runs.json", {"check_runs": []})
    if isinstance(raw, list):
        return raw
    return raw.get("check_runs") or []

def commit_statuses():
    raw = load("status.json", {"statuses": []})
    if isinstance(raw, list):
        return raw
    return raw.get("statuses") or []

def deployments():
    raw = load("deployments.json", [])
    if isinstance(raw, dict):
        raw = raw.get("deployments") or raw.get("items") or []
    extra = load("deployment-statuses.json", None)
    by_id = {}
    if isinstance(extra, list):
        for item in extra:
            if isinstance(item, dict) and "statuses" in item and item.get("deployment_id") is not None:
                by_id[item["deployment_id"]] = item["statuses"]
            elif isinstance(item, dict) and item.get("state"):
                # Flat status list: attach later only when the deployment has none.
                by_id.setdefault("__flat__", []).append(item)
    elif isinstance(extra, dict):
        for key, val in extra.items():
            by_id[key] = val
    out = []
    flat = by_id.pop("__flat__", [])
    for dep in raw:
        dep = dict(dep)
        nested = dep.get("statuses")
        if not nested:
            nested = by_id.get(dep.get("id"))
            if nested is None:
                nested = by_id.get(str(dep.get("id")))
        if not nested and flat and (dep.get("creator") or {}).get("login") == VERCEL_BOT:
            nested = flat
            flat = []
        if nested:
            dep["statuses"] = nested
        out.append(dep)
    return out

def actions_verdict():
    found = []
    for run in check_runs():
        name = run.get("name") or ""
        slug = ((run.get("app") or {}).get("slug"))
        if name != DOCS_JOB:
            continue
        if slug not in (None, "", "github-actions"):
            continue
        output = run.get("output") if isinstance(run.get("output"), dict) else {}
        desc = " ".join(bit for bit in (output.get("title"), output.get("summary")) if bit)
        found.append(classify(run.get("conclusion"), desc, run.get("status")))
    return fold(found)

def vercel_verdict():
    found = []
    for st in commit_statuses():
        if st.get("context") == VERCEL_CONTEXT:
            found.append(classify(st.get("state"), st.get("description")))
    for dep in deployments():
        login = ((dep.get("creator") or {}).get("login"))
        if login != VERCEL_BOT:
            continue
        statuses = dep.get("statuses") or []
        if not statuses:
            found.append("pending")
            continue
        st = latest(statuses)
        found.append(classify(st.get("state"), st.get("description")))
    for run in check_runs():
        slug = ((run.get("app") or {}).get("slug"))
        if slug != "vercel":
            continue
        if (run.get("name") or "") == COMMENTS_CHECK:
            continue
        output = run.get("output") if isinstance(run.get("output"), dict) else {}
        desc = " ".join(bit for bit in (output.get("title"), output.get("summary")) if bit)
        found.append(classify(run.get("conclusion"), desc, run.get("status")))
    return fold(found)

parts = []
if surface in ("github-actions", "both"):
    parts.append(actions_verdict())
if surface in ("vercel", "both"):
    parts.append(vercel_verdict())
verdict = "absent" if surface == "none" else combine(parts)
sys.stdout.write(f"surface={surface} verdict={verdict}\n")
PY
}

main() {
  local cmd="${1:-}"
  if [[ -z "$cmd" ]]; then
    usage >&2
    exit 2
  fi
  shift || true
  case "$cmd" in
    detect) cmd_detect "$@" ;;
    read) cmd_read "$@" ;;
    recipe) cmd_recipe "$@" ;;
    -h|--help|help) usage ;;
    *)
      echo "$SCRIPT_NAME: unknown command: $cmd" >&2
      usage >&2
      exit 2
      ;;
  esac
}

main "$@"
