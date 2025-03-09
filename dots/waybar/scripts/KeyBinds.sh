#!/bin/bash

# Simple script to edit keybindings

# Configuration
KEY_HINTS_FILE="$HOME/.config/hypr/keybinds.md"
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"
EDITOR="${VISUAL:-${EDITOR:-nano}}"

# Check if key hints file exists
if [ ! -f "$KEY_HINTS_FILE" ]; then
    # Run KeyHints.sh to create the default file
    "$HOME/.config/waybar/scripts/KeyHints.sh"
fi

# Function to edit keybindings
edit_keybinds() {
    # Option 1: Edit the keybinds markdown file
    $EDITOR "$KEY_HINTS_FILE"
    
    # Option 2: If you want to edit the hyprland.conf instead
    # $EDITOR "$HYPR_CONFIG"
}

# Main
edit_keybinds

# Optional: Show notification after editing
notify-send "Keybindings updated" "Changes saved to $KEY_HINTS_FILE"

exit 0 