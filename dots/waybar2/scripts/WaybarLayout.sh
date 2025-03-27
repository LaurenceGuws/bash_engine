#!/bin/bash

# Simple script to toggle between Waybar layouts

# Configuration
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
WAYBAR_CONFIG_FILE="$WAYBAR_CONFIG_DIR/config"
WAYBAR_CONFIG_HORIZONTAL="$WAYBAR_CONFIG_DIR/config.horizontal"
WAYBAR_CONFIG_VERTICAL="$WAYBAR_CONFIG_DIR/config.vertical"
CURRENT_LAYOUT_FILE="/tmp/waybar_layout"

# Check if waybar is installed
if ! command -v waybar >/dev/null 2>&1; then
    notify-send "Error" "waybar is not installed"
    exit 1
fi

# Function to get current layout
get_current_layout() {
    # If the file doesn't exist, create it with default layout
    if [ ! -f "$CURRENT_LAYOUT_FILE" ]; then
        echo "horizontal" > "$CURRENT_LAYOUT_FILE"
    fi
    
    cat "$CURRENT_LAYOUT_FILE"
}

# Function to toggle between horizontal and vertical layouts
toggle_layout() {
    current=$(get_current_layout)
    
    if [ "$current" = "horizontal" ]; then
        # Switch to vertical layout
        if [ -f "$WAYBAR_CONFIG_VERTICAL" ]; then
            ln -sf "$WAYBAR_CONFIG_VERTICAL" "$WAYBAR_CONFIG_FILE"
            echo "vertical" > "$CURRENT_LAYOUT_FILE"
            notify-send "Waybar Layout" "Switched to vertical"
        else
            notify-send "Error" "Vertical config not found: $WAYBAR_CONFIG_VERTICAL"
            return 1
        fi
    else
        # Switch to horizontal layout
        if [ -f "$WAYBAR_CONFIG_HORIZONTAL" ]; then
            ln -sf "$WAYBAR_CONFIG_HORIZONTAL" "$WAYBAR_CONFIG_FILE"
            echo "horizontal" > "$CURRENT_LAYOUT_FILE"
            notify-send "Waybar Layout" "Switched to horizontal"
        else
            notify-send "Error" "Horizontal config not found: $WAYBAR_CONFIG_HORIZONTAL"
            return 1
        fi
    fi
    
    # Restart Waybar to apply changes
    pkill waybar
    waybar &
}

# Main
toggle_layout

exit 0 