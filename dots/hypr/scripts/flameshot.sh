#!/bin/bash

# Ensure the script runs in a detached, floating Kitty window
if [[ -z "$KITTY_WINDOW_ID" ]]; then
    hyprctl dispatch exec "[float; size 500 300] kitty --detach --class flameshot-tui --title 'Flameshot' bash -c '$0'"
    exit 0
fi

# Provide a multi-selection UI
CHOICES=$(printf "
GUI Start a manual capture in GUI mode
Screen Capture a single screen
Full Capture the entire desktop
Config Configure flameshot
Clipboard Save to clipboard only (GUI mode)
Delay5 GUI mode with 5 seconds delay
Fix Try with fix for Hyprland compatibility
Cancel Exit without taking a screenshot
" | fzf --prompt=" Select flameshot mode ▶ " --height=12 --border --reverse --color=dark)

# Exit if user cancels or selects "Cancel"
[ -z "$CHOICES" ] || [[ "$CHOICES" == *"Cancel"* ]] && exit 1

# Set environment variables for flameshot in Hyprland
fix_flameshot_env() {
    # Set desktop environment for flameshot
    export XDG_CURRENT_DESKTOP=sway
    
    # Disable style override that causes errors
    export QT_STYLE_OVERRIDE=""
    
    # For fallback compatibility
    export QT_QPA_PLATFORM=wayland
}

# Build the flameshot command based on selection
case "$CHOICES" in
    "GUI")
        notify-send "Flameshot" "Starting GUI capture mode"
        fix_flameshot_env
        flameshot gui
        ;;
    "Screen")
        notify-send "Flameshot" "Capturing single screen"
        fix_flameshot_env
        flameshot screen
        ;;
    "Full")
        notify-send "Flameshot" "Capturing entire desktop"
        fix_flameshot_env
        flameshot full
        ;;
    "Config")
        notify-send "Flameshot" "Opening configuration"
        fix_flameshot_env
        flameshot config
        ;;
    "Clipboard")
        notify-send "Flameshot" "Starting GUI mode (clipboard only)"
        fix_flameshot_env
        flameshot gui --clipboard
        ;;
    "Delay5")
        notify-send "Flameshot" "Starting GUI mode with 5s delay"
        fix_flameshot_env
        flameshot gui --delay 5000
        ;;
    "Fix")
        notify-send "Flameshot" "Trying with Hyprland compatibility fix"
        fix_flameshot_env
        # Additional fix for Hyprland - use grim/slurp if available
        if command -v grim &> /dev/null && command -v slurp &> /dev/null; then
            notify-send "Flameshot" "Using grim/slurp as fallback"
            TEMP_FILE="/tmp/screenshot_$(date +%Y%m%d_%H%M%S).png"
            slurp | grim -g - "$TEMP_FILE"
            if [ -f "$TEMP_FILE" ]; then
                wl-copy < "$TEMP_FILE"
                notify-send "Screenshot" "Image saved to $TEMP_FILE and copied to clipboard"
                xdg-open "$TEMP_FILE" &
            else
                notify-send "Screenshot" "Failed to capture screenshot"
            fi
        else
            flameshot gui
        fi
        ;;
esac

# Close Kitty window after execution
exit 0 