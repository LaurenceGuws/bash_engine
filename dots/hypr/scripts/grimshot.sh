#!/bin/bash

# Simple and reliable screenshot script using grim and slurp
# This is a fallback option that should always work on Hyprland

# Ensure the script runs in a detached, floating Kitty window
if [[ -z "$KITTY_WINDOW_ID" ]]; then
    hyprctl dispatch exec "[float; size 500 300] kitty --detach --class grimshot-tui --title 'Grimshot' bash -c '$0'"
    exit 0
fi

# Function to close this window
close_window() {
    if [ -n "$KITTY_WINDOW_ID" ]; then
        # First try using hyprctl to close this specific window
        WINDOW_ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class == \"grimshot-tui\") | .address")
        if [ -n "$WINDOW_ADDR" ]; then
            hyprctl dispatch closewindow address:$WINDOW_ADDR
        else
            # Fallback 1: Try to close by title
            hyprctl dispatch closewindow title:Grimshot
        fi
        
        # Fallback 2: Force kill this process
        (sleep 0.2 && kill -9 $$) &
    fi
    exit 0
}

# Trap Ctrl+C to ensure we close the window
trap close_window SIGINT SIGTERM

# Provide a multi-selection UI
CHOICES=$(printf "
Window Take screenshot of a window
Active Take screenshot of the active window
Region Select a region to capture
Monitor Capture an entire monitor
Clipboard Copy to clipboard only (don't save to file)
Cancel Exit without taking a screenshot
" | fzf --prompt=" Select screenshot mode ▶ " --height=10 --border --reverse --color=dark)

# Exit if user cancels or selects "Cancel"
[ -z "$CHOICES" ] || [[ "$CHOICES" == *"Cancel"* ]] && close_window

# Set default flags
CLIPBOARD_ONLY=0
SAVE_PATH="$HOME/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Process clipboard option if selected
if [[ "$CHOICES" == *"Clipboard"* ]]; then
    CLIPBOARD_ONLY=1
    CHOICES=${CHOICES/Clipboard*/}
fi

# Determine what to capture
case "$CHOICES" in
    *"Window"*)
        notify-send "Grimshot" "Select a window to capture"
        # Get all window geometries
        GEOM=$(hyprctl -j clients | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1]) \(.title)"' | cut -f1,2 -d' ' | slurp -r)
        ;;
    *"Active"*)
        notify-send "Grimshot" "Capturing active window"
        # Get active window geometry
        GEOM=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        ;;
    *"Region"*)
        notify-send "Grimshot" "Select a region to capture"
        # Let user select a region
        GEOM=$(slurp -d)
        ;;
    *"Monitor"*)
        notify-send "Grimshot" "Select a monitor to capture"
        # Let user select a monitor
        MONITOR=$(hyprctl monitors | grep -o "Monitor.*" | awk '{print $2}' | fzf --prompt=" Select Monitor ▶ " --height=5 --border --reverse --color=dark)
        if [ -z "$MONITOR" ]; then
            notify-send "Grimshot" "No monitor selected, exiting"
            close_window
        fi
        # Get monitor geometry
        GEOM=$(hyprctl -j monitors | jq -r ".[] | select(.name == \"$MONITOR\") | \"\(.x),\(.y) \(.width)x\(.height)\"")
        ;;
    *)
        notify-send "Grimshot" "Invalid selection, exiting"
        close_window
        ;;
esac

# Check if we got a geometry
if [ -z "$GEOM" ]; then
    notify-send "Grimshot" "Failed to get geometry, exiting"
    close_window
fi

# Take the screenshot
if [ $CLIPBOARD_ONLY -eq 1 ]; then
    # Screenshot directly to clipboard
    grim -g "$GEOM" - | wl-copy
    notify-send "Grimshot" "Screenshot copied to clipboard"
else
    # Save to file and copy to clipboard
    mkdir -p "$(dirname "$SAVE_PATH")"
    grim -g "$GEOM" "$SAVE_PATH"
    wl-copy < "$SAVE_PATH"
    notify-send "Grimshot" "Screenshot saved to $SAVE_PATH and copied to clipboard"
    # Open the screenshot in default image viewer in background so we can close window immediately
    nohup xdg-open "$SAVE_PATH" &>/dev/null &
fi

# Small delay to ensure notification shows before closing
sleep 0.5

# Close Kitty window immediately
close_window 