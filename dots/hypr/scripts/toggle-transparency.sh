#!/bin/bash

# Incremental window transparency script for Hyprland

# Configuration - adjust these values to your preference
MIN_OPACITY=0.0      # Minimum opacity (maximum transparency) - set to 0 for fully transparent
MAX_OPACITY=1.0      # Maximum opacity (minimum transparency)
TOGGLE_OPACITY=0.85  # Opacity when toggling from opaque to transparent
OPACITY_STEP=0.05    # How much to change per increment/decrement
SAME_OPACITY=true    # Set to true to use same opacity for active and inactive windows
INACTIVE_DELTA=0.1   # How much more transparent inactive windows should be (if SAME_OPACITY=false)

# Path to store the current state
STATE_FILE="$HOME/.config/hypr/transparency_state"

# Debug all commands
LOG_FILE="/tmp/transparency_debug.log"
echo "Script started with arg: $1" >> $LOG_FILE

# Get current active_opacity directly from Hyprland
# This should work regardless of whether the state file exists or is valid
CURRENT_HYPR_CMD=$(hyprctl -j getoption decoration:active_opacity)
echo "Hyprland command output: $CURRENT_HYPR_CMD" >> $LOG_FILE

# Try to extract the value, use a default if it fails
if command -v jq &> /dev/null; then
    CURRENT_OPACITY=$(echo "$CURRENT_HYPR_CMD" | jq -r '.float' 2>/dev/null)
else
    CURRENT_OPACITY=$(echo "$CURRENT_HYPR_CMD" | grep -o '"float": [0-9.]*' | awk '{print $2}' 2>/dev/null)
fi

# Verify we got a valid number, otherwise use default
if ! [[ "$CURRENT_OPACITY" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Failed to get current opacity, using default" >> $LOG_FILE
    CURRENT_OPACITY="0.95" # Default if we can't get the value
fi

echo "Current opacity after validation: $CURRENT_OPACITY" >> $LOG_FILE

# Save current value to state file
echo "$CURRENT_OPACITY" > "$STATE_FILE"

# Handle arguments
case "$1" in
    "increase")
        # Increase opacity (decrease transparency)
        NEW_OPACITY=$(echo "$CURRENT_OPACITY + $OPACITY_STEP" | bc | awk '{printf "%.2f", $0}')
        if (( $(echo "$NEW_OPACITY > $MAX_OPACITY" | bc -l) )); then
            NEW_OPACITY="$MAX_OPACITY"
        fi
        ;;
    "decrease")
        # Decrease opacity (increase transparency)
        NEW_OPACITY=$(echo "$CURRENT_OPACITY - $OPACITY_STEP" | bc | awk '{printf "%.2f", $0}')
        if (( $(echo "$NEW_OPACITY < $MIN_OPACITY" | bc -l) )); then
            NEW_OPACITY="$MIN_OPACITY"  # Don't let windows get too transparent
        fi
        ;;
    "toggle")
        # Toggle between transparent and opaque
        if (( $(echo "$CURRENT_OPACITY >= 0.99" | bc -l) )); then
            NEW_OPACITY="$TOGGLE_OPACITY"
        else
            NEW_OPACITY="$MAX_OPACITY"
        fi
        ;;
    *)
        echo "Usage: $0 [increase|decrease|toggle]" >> $LOG_FILE
        echo "Got argument: '$1'" >> $LOG_FILE
        exit 1
        ;;
esac

# Update opacity for inactive windows
if [ "$SAME_OPACITY" = true ]; then
    # Use same opacity for active and inactive windows
    INACTIVE_OPACITY="$NEW_OPACITY"
else
    # Make inactive windows more transparent
    INACTIVE_OPACITY=$(echo "$NEW_OPACITY - $INACTIVE_DELTA" | bc | awk '{printf "%.2f", $0}')
    if (( $(echo "$INACTIVE_OPACITY < $MIN_OPACITY" | bc -l) )); then
        INACTIVE_OPACITY="$MIN_OPACITY"
    fi
fi

# Log what we're setting
echo "Setting active: $NEW_OPACITY, inactive: $INACTIVE_OPACITY" >> $LOG_FILE

# Apply the change
HYPR_CMD="keyword decoration:active_opacity $NEW_OPACITY; keyword decoration:inactive_opacity $INACTIVE_OPACITY"
echo "Running hyprctl command: $HYPR_CMD" >> $LOG_FILE
hyprctl --batch "$HYPR_CMD"

# Save the new state
echo "$NEW_OPACITY" > "$STATE_FILE"

# Display notification
if [ "$SAME_OPACITY" = true ]; then
    notify-send "Window Transparency" "Opacity: ${NEW_OPACITY}" -t 1000
else
    notify-send "Window Transparency" "Active: ${NEW_OPACITY}, Inactive: ${INACTIVE_OPACITY}" -t 1000
fi

exit 0 