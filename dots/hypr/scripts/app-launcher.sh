#!/bin/bash

# App launcher with popup preview
# Based on icon locations identified in testing

# Check if running as a detached window
if [[ -z "$APP_LAUNCHER_RUNNING" ]]; then
    # Launch in a detached kitty window with special variable
    hyprctl dispatch exec "[float; size 1200 600] kitty --class app-launcher-popup --title 'App Launcher' bash -c 'APP_LAUNCHER_RUNNING=1 $0'"
    exit 0
fi

# Generate a list of applications
generate_app_list() {
    # Get desktop files
    find /usr/share/applications -name "*.desktop" | while read file; do
        # Extract basic info
        name=$(grep -m 1 "^Name=" "$file" | cut -d= -f2)
        exec=$(grep -m 1 "^Exec=" "$file" | sed 's/^Exec=//' | sed 's/%[a-zA-Z]//g')
        icon=$(grep -m 1 "^Icon=" "$file" | cut -d= -f2)
        
        # Skip hidden apps and those without name or exec
        if grep -q "^NoDisplay=true" "$file" || [ -z "$name" ] || [ -z "$exec" ]; then
            continue
        fi
        
        # Just output name, exec, icon - we'll find paths in a separate function
        echo "$name|$exec|$icon"
    done | sort
}

# Extremely simplified preview command to avoid getting stuck
preview_cmd='#!/bin/bash
    # Basic data extraction
    line={}
    name=$(echo "$line" | cut -d"|" -f1)
    exec=$(echo "$line" | cut -d"|" -f2)
    icon=$(echo "$line" | cut -d"|" -f3)
    
    # Show basic info - no fancy formatting
    echo "Name: $name"
    echo "Command: $exec"
    echo ""
    
    # Clear any previous image
    kitty +kitten icat --clear
    
    # Simplified icon path finding, no loops
    if [ -f "/usr/share/icons/hicolor/128x128/apps/$icon.png" ]; then
        kitty +kitten icat "/usr/share/icons/hicolor/128x128/apps/$icon.png"
    elif [ -f "/usr/share/pixmaps/$icon.png" ]; then
        kitty +kitten icat "/usr/share/pixmaps/$icon.png"
    else
        echo "No icon found"
    fi
'

# Generate applications list
app_list=$(generate_app_list)

# Show app selector - extremely simplified preview options
selected=$(echo "$app_list" | fzf --reverse --height 95% --border rounded \
                     --prompt="Applications: " \
                     --preview="bash -c \"$preview_cmd\"" \
                     --preview-window=right:40% \
                     --header="Enter: launch, CTRL-C: cancel")

# If an app was selected, launch it
if [[ -n "$selected" ]]; then
    cmd=$(echo "$selected" | cut -d"|" -f2)
    hyprctl dispatch exec "$cmd"
fi

# Close the launcher
pkill -f "kitty --class app-launcher-popup"