#!/bin/bash

# Simple script to lock the screen using swaylock

# Configuration
LOCKSCREEN_WALLPAPER="$HOME/.config/hypr/wallpapers/lockscreen.png"
SWAYLOCK_ARGS=""

# Check if swaylock is installed
if ! command -v swaylock >/dev/null 2>&1; then
    notify-send "Error" "swaylock is not installed"
    exit 1
fi

# Function to lock screen
lock_screen() {
    # Check if custom wallpaper exists
    if [ -f "$LOCKSCREEN_WALLPAPER" ]; then
        SWAYLOCK_ARGS="--image $LOCKSCREEN_WALLPAPER"
    fi
    
    # Additional options for swaylock
    SWAYLOCK_ARGS="$SWAYLOCK_ARGS --fade-in 0.5 --clock --indicator"
    
    # Execute swaylock
    swaylock $SWAYLOCK_ARGS
}

# Main
lock_screen

exit 0 