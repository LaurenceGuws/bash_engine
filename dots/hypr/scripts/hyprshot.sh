#!/bin/bash

# Ensure the script runs in a detached, floating Kitty window
if [[ -z "$KITTY_WINDOW_ID" ]]; then
    hyprctl dispatch exec "[float; size 500 300] kitty --detach --class hyprshot-tui --title 'Hyprshot' bash -c '$0'"
    exit 0
fi

# Provide a multi-selection UI
CHOICES=$(printf "
Window Take screenshot of a window
Active Take screenshot of the active window
Region Select a region to capture
Monitor Capture an entire monitor
Clipboard Copy screenshot to clipboard only (don't save)
Silent Don't show notifications after capturing
Freeze Freeze screen while capturing
Cancel Exit without taking a screenshot
" | fzf --prompt=" Select modes (TAB to multi-select) ▶ " --height=12 --border --reverse --multi --color=dark)

# Exit if user cancels or selects "Cancel"
[ -z "$CHOICES" ] || [[ "$CHOICES" == *"Cancel"* ]] && exit 1

# Start building the Hyprshot command
HYPRSHOT_CMD="hyprshot"

# Process multiple selections
for CHOICE in $CHOICES; do
    case "$CHOICE" in
        "Window")     HYPRSHOT_CMD+=" -m window" ;;
        "Active")     HYPRSHOT_CMD+=" -m window -m active" ;;
        "Region")     HYPRSHOT_CMD+=" -m region" ;;
        "Monitor")    
            MONITOR=$(hyprctl monitors | awk '/Monitor/ {print $2}' | fzf --prompt=" Select Monitor ▶ " --height=5 --border --reverse --color=dark)
            [ -z "$MONITOR" ] && exit 1
            HYPRSHOT_CMD+=" -m output -m $MONITOR"
            ;;
        "Clipboard")  HYPRSHOT_CMD+=" --clipboard-only" ;;
        "Silent")     HYPRSHOT_CMD+=" -s" ;;
        "Freeze")     HYPRSHOT_CMD+=" -z" ;;
    esac
done

# Final confirmation before executing
notify-send "Hyprshot" "Executing: $HYPRSHOT_CMD"

# Execute the final built command
eval "$HYPRSHOT_CMD"

# Close Kitty window after execution
exit 0
