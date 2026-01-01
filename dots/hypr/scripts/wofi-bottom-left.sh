#!/usr/bin/env bash
set -euo pipefail
HYPR_FLOAT_PATH="$HOME/.config/hypr/scripts/hypr_float.sh"
LOG_FILE="/tmp/wofi-bottom-left-test.log"

if [[ ! -r "$HYPR_FLOAT_PATH" ]]; then
  printf 'hypr_float.sh not found at %s\n' "$HYPR_FLOAT_PATH" >&2
  exit 1
fi

export LOG_FILE

# shellcheck source=/dev/null
. "$HYPR_FLOAT_PATH"

hypr_float "$@"
