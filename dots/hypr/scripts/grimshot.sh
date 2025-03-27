#!/bin/bash

# Check if we're running in a detached window
if [[ -z "$GRIMSHOT_RUNNING" ]]; then
    # Launch in a detached kitty window with special variable
    hyprctl dispatch exec "[float; size 500 300] kitty --class grimshot-tui --title 'Grimshot' bash -c 'GRIMSHOT_RUNNING=1 $0'"
    exit 0
fi

# Select screenshot type with fzf
CHOICE=$(printf "Window\nActive\nRegion\nOutput\nClipboard-only\nCancel" | fzf --prompt "Screenshot type: " --height 10 --border)

# Set clipboard-only flag
CLIPBOARD_ONLY=0
if [[ "$CHOICE" == "Clipboard-only" ]]; then
    CLIPBOARD_ONLY=1
    CHOICE="Region"  # Default to region for clipboard-only
fi

# Get geometry based on choice
case "$CHOICE" in
    "Window")
        GEOM=$(hyprctl -j clients | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp -r)
        ;;
    "Active")
        GEOM=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        ;;
    "Region")
        GEOM=$(slurp -d)
        ;;
    "Output")
        GEOM=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | "\(.x),\(.y) \(.width)x\(.height)"')
        ;;
    "Cancel")
        pkill -f "kitty --class grimshot-tui"
        ;;
esac

# Take screenshot
SAVE_PATH="$HOME/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png"

if [[ $CLIPBOARD_ONLY -eq 1 ]]; then
    # Clipboard only
    grim -g "$GEOM" - | wl-copy
    notify-send "Screenshot copied to clipboard"
else
    # Save to file and clipboard
    mkdir -p "$(dirname "$SAVE_PATH")"
    grim -g "$GEOM" "$SAVE_PATH"
    wl-copy < "$SAVE_PATH"
    notify-send "Screenshot saved" "$SAVE_PATH"
fi

# Ensure kitty closes by killing this process
pkill -f "kitty --class grimshot-tui"
