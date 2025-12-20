#!/bin/bash

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

if [[ -z "${BTOP_POPUP_RUNNING:-}" ]]; then
    if command -v launch_kitty_popup >/dev/null 2>&1; then
        launch_kitty_popup "$POPUP_CLASS" "$POPUP_TITLE" "" "BTOP_POPUP_RUNNING=1 \"$SCRIPT_PATH\"" || true
        exit 0
    fi
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl dispatch exec "[float] kitty --detach --class ${POPUP_CLASS} --app-id ${POPUP_CLASS} --title '${POPUP_TITLE}' bash -c 'BTOP_POPUP_RUNNING=1 \"$SCRIPT_PATH\"'"
        exit 0
    fi
    setsid -f -- kitty --class "${POPUP_CLASS}" --app-id "${POPUP_CLASS}" --title "${POPUP_TITLE}" bash -c "BTOP_POPUP_RUNNING=1 \"$SCRIPT_PATH\"" >/dev/null 2>&1
    exit 0
fi

btop
pkill -f "kitty --class ${POPUP_CLASS} --title ${POPUP_TITLE}"
