#!/bin/bash
set -euo pipefail

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi

SCRIPT_PATH="$0"
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
    SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

run_pacseek() {
    pacseek
}

hypr_popup_run "PACSEEK_RUNNING" "pacseek-popup" "pacseek" \
    "kitty --detach --class pacseek-popup --title 'pacseek' bash -lc 'PACSEEK_RUNNING=1 \"${SCRIPT_PATH}\"'" \
    run_pacseek \
    br

exit 0
