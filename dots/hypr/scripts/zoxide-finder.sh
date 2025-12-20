#!/bin/bash

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi

# Zoxide directory finder with fzf in kitty
# Opens selected directory in a new terminal window

if ! command -v zoxide >/dev/null 2>&1; then
    notify_msg "Zoxide not found" "Please install zoxide first"
    exit 1
fi

SCRIPT_PATH="$0"
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
    SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

if [[ -z "${ZOXIDE_FINDER_RUNNING:-}" ]]; then
    if command -v launch_kitty_popup >/dev/null 2>&1 && launch_kitty_popup "zoxide-finder-popup" "Zoxide Finder" "" "ZOXIDE_FINDER_RUNNING=1 \"$SCRIPT_PATH\""; then
        exit 0
    fi
    hyprctl dispatch exec "[float] kitty --class zoxide-finder-popup --title 'Zoxide Finder' bash -c 'ZOXIDE_FINDER_RUNNING=1 \"$SCRIPT_PATH\"'"
    exit 0
fi

selected_dir=$(zoxide query -l | fzf --reverse --height 95% --border rounded \
                         --prompt="Recent dirs: " \
                         --preview="ls -la {}" \
                         --preview-window=right:50% \
                         --header="Enter: open dir, CTRL-C: cancel")

if [ -n "$selected_dir" ]; then
    echo "Selected: $selected_dir" > /tmp/zoxide_debug.log
    
    if [ -d "$selected_dir" ]; then
        hypr_exec "kitty --directory='$selected_dir'" || hyprctl dispatch exec "kitty --directory='$selected_dir'"
        echo "Launched kitty with directory: $selected_dir" >> /tmp/zoxide_debug.log
    else
        notify_msg "Directory not found" "The selected directory no longer exists"
        echo "Directory not found: $selected_dir" >> /tmp/zoxide_debug.log
    fi
else
    echo "No directory selected" >> /tmp/zoxide_debug.log
fi

pkill -f "kitty --class zoxide-finder-popup"
