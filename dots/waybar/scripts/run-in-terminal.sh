#!/usr/bin/env bash
set -euo pipefail

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <command> [args...]" >&2
    exit 1
fi

if command -v run_in_terminal >/dev/null 2>&1 && run_in_terminal "$@"; then
    exit 0
fi

if command -v notify_msg >/dev/null 2>&1; then
    notify_msg "Waybar helper" "Install kitty, alacritty, foot, or xterm to run $1."
else
    echo "Waybar helper: install a terminal to run $1." >&2
fi
