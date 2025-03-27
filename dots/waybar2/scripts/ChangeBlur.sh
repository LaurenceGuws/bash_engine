#!/bin/bash

# Simple script to toggle blur in Hyprland

# Configuration
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
TEMP_FILE="/tmp/hypr_blur_state"

# Check if Hyprland is running
if ! pgrep -x "Hyprland" >/dev/null; then
    notify-send "Error" "Hyprland is not running"
    exit 1
fi

# Function to toggle blur
toggle_blur() {
    # Check if blur is enabled by reading state or checking config
    if [ -f "$TEMP_FILE" ] && [ "$(cat "$TEMP_FILE")" = "enabled" ]; then
        # Disable blur
        hyprctl --batch "keyword decoration:blur 0; keyword decoration:drop_shadow 0"
        echo "disabled" > "$TEMP_FILE"
        notify-send "Blur" "Disabled"
    else
        # Enable blur
        hyprctl --batch "keyword decoration:blur 1; keyword decoration:drop_shadow 1"
        echo "enabled" > "$TEMP_FILE"
        notify-send "Blur" "Enabled"
    fi
}

# Execute function
toggle_blur

exit 0 