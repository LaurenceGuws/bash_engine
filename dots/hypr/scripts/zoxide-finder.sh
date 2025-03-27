#!/bin/bash

# Zoxide directory finder with fzf in kitty
# Opens selected directory in a new terminal window

# Make sure zoxide is installed
if ! command -v zoxide &> /dev/null; then
    notify-send "Zoxide not found" "Please install zoxide first"
    exit 1
fi

# Enable debugging
# set -x

# Check if we're running in a detached window
if [[ -z "$ZOXIDE_FINDER_RUNNING" ]]; then
    # Launch in a detached kitty window with special variable
    hyprctl dispatch exec "[float; size 1300 500] kitty --class zoxide-finder-popup --title 'Zoxide Finder' bash -c 'ZOXIDE_FINDER_RUNNING=1 $0'"
    exit 0
fi

# Use zoxide to get directory list, use fzf to select
selected_dir=$(zoxide query -l | fzf --reverse --height 95% --border rounded \
                         --prompt="Recent dirs: " \
                         --preview="ls -la {}" \
                         --preview-window=right:50% \
                         --header="Enter: open dir, CTRL-C: cancel")

# If a directory was selected, open it in a new terminal
if [ -n "$selected_dir" ]; then
    # Log selection to debug file
    echo "Selected: $selected_dir" > /tmp/zoxide_debug.log
    
    # Check if directory exists before trying to open it
    if [ -d "$selected_dir" ]; then
        # Launch a new kitty terminal with the selected directory using hyprctl
        # This ensures it's completely detached from this process
        hyprctl dispatch exec "kitty --directory='$selected_dir'"
        
        # Log success
        echo "Launched kitty with directory: $selected_dir" >> /tmp/zoxide_debug.log
    else
        notify-send "Directory not found" "The selected directory no longer exists"
        echo "Directory not found: $selected_dir" >> /tmp/zoxide_debug.log
    fi
else
    echo "No directory selected" >> /tmp/zoxide_debug.log
fi

# Ensure the popup closes
pkill -f "kitty --class zoxide-finder-popup" 