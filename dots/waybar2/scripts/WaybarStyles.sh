#!/bin/bash

# Simple script to switch between Waybar styles

# Configuration
WAYBAR_CONFIG_DIR="$HOME/.config/waybar"
STYLE_DIR="$WAYBAR_CONFIG_DIR/style"
CURRENT_STYLE_LINK="$WAYBAR_CONFIG_DIR/style.css"

# Check if the style directory exists
if [ ! -d "$STYLE_DIR" ]; then
    notify-send "Error" "Style directory not found: $STYLE_DIR"
    exit 1
fi

# Get list of available styles
STYLES=($(ls -1 "$STYLE_DIR" | grep -E "\.css$" | sed 's/\.css$//'))

# If no styles found
if [ ${#STYLES[@]} -eq 0 ]; then
    notify-send "Error" "No styles found in $STYLE_DIR"
    exit 1
fi

# Function to show style menu with wofi
show_style_menu() {
    selected=$(printf "%s\n" "${STYLES[@]}" | wofi --dmenu --prompt="Select style" --insensitive)
    
    if [ -n "$selected" ]; then
        apply_style "$selected"
    fi
}

# Function to cycle to next style
cycle_next_style() {
    # Get current style
    current=$(basename "$(readlink -f "$CURRENT_STYLE_LINK")" .css)
    
    # Find index of current style
    current_index=-1
    for i in "${!STYLES[@]}"; do
        if [ "${STYLES[$i]}" = "$current" ]; then
            current_index=$i
            break
        fi
    done
    
    # If current style not found in list, use first style
    if [ $current_index -eq -1 ]; then
        apply_style "${STYLES[0]}"
        return
    fi
    
    # Calculate next index (with wraparound)
    next_index=$(( (current_index + 1) % ${#STYLES[@]} ))
    
    # Apply next style
    apply_style "${STYLES[$next_index]}"
}

# Function to apply a style
apply_style() {
    style_name="$1"
    style_file="$STYLE_DIR/${style_name}.css"
    
    if [ ! -f "$style_file" ]; then
        notify-send "Error" "Style file not found: $style_file"
        return
    fi
    
    # Create a symbolic link to the selected style
    ln -sf "$style_file" "$CURRENT_STYLE_LINK"
    
    # Restart Waybar to apply the new style
    pkill waybar
    waybar &
    
    # Notify user
    notify-send "Waybar Style" "Applied: $style_name"
}

# Main
if [ "$1" = "--menu" ]; then
    show_style_menu
else
    cycle_next_style
fi

exit 0 