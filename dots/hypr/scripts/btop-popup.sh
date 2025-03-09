#!/bin/bash

# Ensure only one instance of the floating btop window runs
if [[ -z "$KITTY_WINDOW_ID" ]]; then
    # If btop-popup is already running, close it instead of opening a new one
    if pgrep -fx "kitty --class btop-popup --title btop" > /dev/null; then
        pkill -f "kitty --class btop-popup --title btop"
        exit 0
    fi

    # Launch floating Kitty window with btop and auto-close after exit
    hyprctl dispatch exec "[float; size 800 500] kitty --detach --class btop-popup --title 'btop' bash -c '$0'"
    exit 0
fi

# Run btop, and when it exits, force Kitty to close
btop
pkill -f "kitty --class btop-popup --title btop"

# Exit cleanly
exit 0
