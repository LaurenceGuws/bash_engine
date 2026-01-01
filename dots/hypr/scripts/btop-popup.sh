#!/bin/bash
set -euo pipefail

POPUP_CLASS="btop"
POPUP_TITLE="btop"

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

run_btop() {
    btop
}

hypr_popup_run "BTOP_POPUP_RUNNING" "$POPUP_CLASS" "$POPUP_TITLE" \
    "kitty --detach --class ${POPUP_CLASS} --app-id ${POPUP_CLASS} --title '${POPUP_TITLE}' bash -lc 'BTOP_POPUP_RUNNING=1 \"${SCRIPT_PATH}\"'" \
    run_btop \
    br
