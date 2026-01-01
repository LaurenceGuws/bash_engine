#!/bin/bash
set -euo pipefail

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

run_zoxide_finder() {
    local selected_dir
    selected_dir=$(zoxide query -l | fzf --reverse --height 95% --border rounded \
                             --prompt="Recent dirs: " \
                             --preview="ls -la {}" \
                             --preview-window=right:50% \
                             --header="Enter: open dir, CTRL-C: cancel")

    if [[ -n "$selected_dir" ]]; then
        echo "Selected: $selected_dir" > /tmp/zoxide_debug.log
        if [[ -d "$selected_dir" ]]; then
            if command -v run_in_terminal >/dev/null 2>&1; then
                run_in_terminal kitty --directory="$selected_dir"
            else
                setsid -f -- kitty --directory="$selected_dir" >/dev/null 2>&1 || true
            fi
            echo "Launched terminal with directory: $selected_dir" >> /tmp/zoxide_debug.log
        else
            notify_msg "Directory not found" "The selected directory no longer exists"
            echo "Directory not found: $selected_dir" >> /tmp/zoxide_debug.log
        fi
    else
        echo "No directory selected" >> /tmp/zoxide_debug.log
    fi
}

hypr_popup_run "ZOXIDE_FINDER_RUNNING" "zoxide-finder-popup" "Zoxide Finder" \
    "kitty --class zoxide-finder-popup --title 'Zoxide Finder' bash -lc 'ZOXIDE_FINDER_RUNNING=1 \"${SCRIPT_PATH}\"'" \
    run_zoxide_finder \
    br
