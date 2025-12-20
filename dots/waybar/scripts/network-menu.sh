#!/usr/bin/env bash
set -euo pipefail

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi

if ! command -v notify_msg >/dev/null 2>&1; then
    notify_msg() { printf '%s: %s\n' "$1" "$2" >&2; }
fi

PALETTE_PATH="$HOME/.config/nmtui/palette"
DEFAULT_PALETTE=$'root=lightgray,black\nroottext=lightgray,black\nborder=lightblue,black\nwindow=lightgray,black\nshadow=black,black\ntitle=lightgray,black\nlabel=lightgray,black\nentry=black,lightgray\ndisentry=gray,black\ncheckbox=black,lightgray\nactcheckbox=black,lightmagenta\nlistbox=black,lightgray\nactlistbox=black,lightmagenta\ntextbox=black,lightgray\nacttextbox=black,lightmagenta\nbutton=black,lightgray\nactbutton=black,lightblue\nhelpline=black,lightgray'
if [[ -r "$PALETTE_PATH" ]]; then
    PALETTE_CONTENT="$(<"$PALETTE_PATH")"
else
    PALETTE_CONTENT="$DEFAULT_PALETTE"
fi
PALETTE_ESCAPED="$(printf %q "$PALETTE_CONTENT")"

NMTUI_LINES_DEFAULT=32
NMTUI_COLS_DEFAULT=110
NMTUI_LINES=${NMTUI_LINES:-$NMTUI_LINES_DEFAULT}
NMTUI_COLS=${NMTUI_COLS:-$NMTUI_COLS_DEFAULT}

launch_in_kitty_popup() {
    if ! command -v launch_kitty_popup >/dev/null 2>&1; then
        return 1
    fi
    local env_cmd="NEWT_COLORS=${PALETTE_ESCAPED} LINES=${NMTUI_LINES} COLUMNS=${NMTUI_COLS} nmtui"
    launch_kitty_popup "nmtui-popup" "NMTUI" "" "$env_cmd"
}

if command -v nmtui >/dev/null 2>&1; then
    if launch_in_kitty_popup; then
        exit 0
    fi

    if command -v run_in_terminal >/dev/null 2>&1; then
        if run_in_terminal bash -lc "export NEWT_COLORS=$(printf %q "$PALETTE_CONTENT"); export LINES=$NMTUI_LINES; export COLUMNS=$NMTUI_COLS; exec nmtui"; then
            exit 0
        fi
    fi
    NEWT_COLORS="$PALETTE_CONTENT" LINES="$NMTUI_LINES" COLUMNS="$NMTUI_COLS" nmtui &
    exit 0
fi

notify_msg "Network" "Install nmtui or a terminal to run it for managing connections."
