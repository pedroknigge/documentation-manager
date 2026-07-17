#!/usr/bin/env bash
# template-telemetry.sh — local-only template-gap ledger for Documentation Manager (v2.4)
# Default OFF. No network. Template/skill UX gaps only.
#
# Usage:
#   template-telemetry.sh status [--ledger PATH] [--opt-in-file PATH]
#   template-telemetry.sh record --gap-kind KIND --template-id ID [options]
#
# Opt-in: DOCS_TELEMETRY_OPT_IN=1|true|yes  OR  --opt-in  OR  --opt-in-file with 1/true/yes
# Exit 0 on no-op (opt-in off). Exit 2 on usage/validation error.
set -euo pipefail

CMD="${1:-}"
if [[ -z "$CMD" || "$CMD" == "-h" || "$CMD" == "--help" ]]; then
  cat <<'EOF'
Usage:
  template-telemetry.sh status [--ledger PATH] [--opt-in-file PATH]
  template-telemetry.sh record --gap-kind KIND --template-id ID
      [--ledger PATH] [--opt-in-file PATH] [--opt-in]
      [--skill-version VER] [--host TOKEN]

Default: opt-in OFF (record is no-op). Never opens network connections.
EOF
  exit 0
fi
shift || true

LEDGER=""
OPT_IN_FILE=""
FORCE_OPT_IN=0
GAP_KIND=""
TEMPLATE_ID=""
SKILL_VERSION=""
HOST_TOKEN="unknown"

# Reject never-send smuggling flags early
for a in "$@"; do
  case "$a" in
    --source|--source-code|--url|--repo|--repo-url|--path|--content|--file|--snippet|--diff|--secret|--env)
      echo "template-telemetry: refused never-send flag: $a" >&2
      exit 2
      ;;
  esac
done

# Require a non-empty flag value that is not another option (starts with -)
take_value() {
  local flag="$1" val="${2:-}"
  if [[ -z "$val" || "$val" == -* ]]; then
    echo "template-telemetry: $flag requires a value" >&2
    exit 2
  fi
  printf '%s' "$val"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ledger)
      LEDGER="$(take_value "$1" "${2:-}")"; shift 2
      ;;
    --opt-in-file)
      OPT_IN_FILE="$(take_value "$1" "${2:-}")"; shift 2
      ;;
    --opt-in)
      FORCE_OPT_IN=1; shift
      ;;
    --gap-kind)
      GAP_KIND="$(take_value "$1" "${2:-}")"; shift 2
      ;;
    --template-id)
      TEMPLATE_ID="$(take_value "$1" "${2:-}")"; shift 2
      ;;
    --skill-version)
      SKILL_VERSION="$(take_value "$1" "${2:-}")"; shift 2
      ;;
    --host)
      HOST_TOKEN="$(take_value "$1" "${2:-}")"; shift 2
      ;;
    *)
      echo "template-telemetry: unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$LEDGER" ]]; then
  LEDGER="docs/audit/generated/template-telemetry.jsonl"
fi

is_truthy() {
  case "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')" in
    1|true|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

opt_in_enabled() {
  if [[ "$FORCE_OPT_IN" -eq 1 ]]; then
    return 0
  fi
  if is_truthy "${DOCS_TELEMETRY_OPT_IN:-}"; then
    return 0
  fi
  if [[ -n "$OPT_IN_FILE" && -f "$OPT_IN_FILE" ]]; then
    if is_truthy "$(head -1 "$OPT_IN_FILE" 2>/dev/null || true)"; then
      return 0
    fi
  fi
  return 1
}

# gap_kind allowlist
valid_gap_kind() {
  case "$1" in
    TEMPLATE_MISSING|TEMPLATE_STALE|LAYOUT_GAP|PROCEDURE_UNCLEAR|OTHER_UX) return 0 ;;
    *) return 1 ;;
  esac
}

# template_id: short slug only (no paths, no URLs)
valid_template_id() {
  [[ "$1" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]{0,63}$ ]] || return 1
  [[ "$1" != *"/"* && "$1" != *"\\"* && "$1" != *":"* ]] || return 1
  return 0
}

json_escape() {
  # minimal JSON string escape
  local s="$1"
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  printf '%s' "$s"
}

case "$CMD" in
  status)
    if opt_in_enabled; then
      echo "opt-in: on"
    else
      echo "opt-in: off"
    fi
    echo "ledger: $LEDGER"
    echo "network: never"
    if [[ -f "$LEDGER" ]]; then
      echo "ledger_exists: yes"
      echo "ledger_lines: $(wc -l < "$LEDGER" | tr -d ' ')"
    else
      echo "ledger_exists: no"
    fi
    exit 0
    ;;
  record)
    if ! opt_in_enabled; then
      # Default off: no-op, zero network, no ledger
      echo "template-telemetry: opt-in off — no-op"
      exit 0
    fi
    if [[ -z "$GAP_KIND" || -z "$TEMPLATE_ID" ]]; then
      echo "template-telemetry: record requires --gap-kind and --template-id" >&2
      exit 2
    fi
    if ! valid_gap_kind "$GAP_KIND"; then
      echo "template-telemetry: invalid gap_kind: $GAP_KIND" >&2
      exit 2
    fi
    if ! valid_template_id "$TEMPLATE_ID"; then
      echo "template-telemetry: invalid template_id (use short slug, no paths/URLs): $TEMPLATE_ID" >&2
      exit 2
    fi
    if [[ -n "$HOST_TOKEN" ]] && ! [[ "$HOST_TOKEN" =~ ^[a-zA-Z0-9_-]{1,32}$ ]]; then
      echo "template-telemetry: invalid host token" >&2
      exit 2
    fi

    TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    mkdir -p "$(dirname "$LEDGER")"

    # Build JSON with only allowlisted fields
    line="{\"ts\":\"$(json_escape "$TS")\",\"event\":\"template_gap\",\"gap_kind\":\"$(json_escape "$GAP_KIND")\",\"template_id\":\"$(json_escape "$TEMPLATE_ID")\""
    if [[ -n "$SKILL_VERSION" ]]; then
      if ! [[ "$SKILL_VERSION" =~ ^[0-9]+(\.[0-9]+){0,3}([.-][a-zA-Z0-9]+)?$ ]]; then
        echo "template-telemetry: invalid skill_version" >&2
        exit 2
      fi
      line+=",\"skill_version\":\"$(json_escape "$SKILL_VERSION")\""
    fi
    line+=",\"host\":\"$(json_escape "$HOST_TOKEN")\"}"

    printf '%s\n' "$line" >> "$LEDGER"
    echo "template-telemetry: recorded → $LEDGER"
    exit 0
    ;;
  *)
    echo "template-telemetry: unknown command: $CMD" >&2
    exit 2
    ;;
esac
