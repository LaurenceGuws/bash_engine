#!/bin/bash

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

if [[ -z "${PACSEEK_RUNNING:-}" ]]; then
    if command -v launch_kitty_popup >/dev/null 2>&1 && launch_kitty_popup "pacseek-popup" "pacseek" "" "PACSEEK_RUNNING=1 \"$SCRIPT_PATH\""; then
        exit 0
    fi
    hyprctl dispatch exec "[float] kitty --detach --class pacseek-popup --title 'pacseek' bash -lc 'PACSEEK_RUNNING=1 \"$SCRIPT_PATH\"'"
    exit 0
fi

pacseek
pkill -f "kitty --class pacseek-popup --title pacseek"

exit 0
