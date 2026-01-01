#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HYPR_FLOAT_PATH="$REPO_ROOT/dots/hypr/scripts/hypr_float.sh"
LOG_FILE="/tmp/wofi-bottom-left-test.log"

if [[ ! -r "$HYPR_FLOAT_PATH" ]]; then
  printf 'hypr_float.sh not found at %s\n' "$HYPR_FLOAT_PATH" >&2
  exit 1
fi

export LOG_FILE

# shellcheck source=/dev/null
. "$HYPR_FLOAT_PATH"

hypr_float --exec "wofi --show drun --normal-window" "$@"
