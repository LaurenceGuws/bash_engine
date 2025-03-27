#!/bin/bash

# Simple script to control brightness

# You may need to adjust these commands based on your system
# For most systems, you might want to use brightnessctl, light, or xbacklight

# Set the amount to increment/decrement (percentage)
STEP=5

case "$1" in
    --inc)
        # Increase brightness
        brightnessctl set +${STEP}%
        ;;
    --dec)
        # Decrease brightness
        brightnessctl set ${STEP}%-
        ;;
    *)
        echo "Usage: $0 [--inc|--dec]"
        exit 1
        ;;
esac

# Get current brightness for notification (optional)
CURRENT=$(brightnessctl get)
MAX=$(brightnessctl max)
PERCENT=$((CURRENT * 100 / MAX))

# Send notification (if you have notify-send)
notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness "Brightness: ${PERCENT}%" -h int:value:${PERCENT}

exit 0 