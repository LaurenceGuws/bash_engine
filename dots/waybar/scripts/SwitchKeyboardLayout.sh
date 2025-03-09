#!/bin/bash

# Simple script to switch keyboard layouts in Hyprland

# Configuration
LAYOUTS=("us" "de" "es" "fr")  # Add your preferred layouts here
CURRENT_LAYOUT_FILE="/tmp/current_keyboard_layout"

# Function to get the current layout
get_current_layout() {
    # If the file doesn't exist, create it with default layout
    if [ ! -f "$CURRENT_LAYOUT_FILE" ]; then
        echo "${LAYOUTS[0]}" > "$CURRENT_LAYOUT_FILE"
    fi
    
    cat "$CURRENT_LAYOUT_FILE"
}

# Function to set the next layout
set_next_layout() {
    current=$(get_current_layout)
    
    # Find index of current layout
    current_index=-1
    for i in "${!LAYOUTS[@]}"; do
        if [ "${LAYOUTS[$i]}" = "$current" ]; then
            current_index=$i
            break
        fi
    done
    
    # If current layout not found in list, use first layout
    if [ $current_index -eq -1 ]; then
        next="${LAYOUTS[0]}"
    else
        # Calculate next index (with wraparound)
        next_index=$(( (current_index + 1) % ${#LAYOUTS[@]} ))
        next="${LAYOUTS[$next_index]}"
    fi
    
    # Save next layout
    echo "$next" > "$CURRENT_LAYOUT_FILE"
    
    # Apply the layout using Hyprland
    hyprctl keyword input:kb_layout "$next"
    
    # Notify user
    notify-send "Keyboard Layout" "Switched to: $next"
}

# Main
set_next_layout

exit 0 