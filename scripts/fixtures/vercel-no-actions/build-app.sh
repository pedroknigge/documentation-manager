#!/usr/bin/env bash
# Stand-in for the framework build that follows a passing docs-audit.
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
printf 'FRAMEWORK_BUILD_RAN\n' > "$root/build-stamp"
