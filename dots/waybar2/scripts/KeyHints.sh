#!/bin/bash

# Simple script to show keybinding hints

# Configuration
KEY_HINTS_FILE="$HOME/.config/hypr/keybinds.md"
TEMP_HTML="/tmp/keyhints.html"

# Check if the key hints file exists, create basic one if not
if [ ! -f "$KEY_HINTS_FILE" ]; then
    mkdir -p "$(dirname "$KEY_HINTS_FILE")"
    cat > "$KEY_HINTS_FILE" << 'EOL'
# Hyprland Key Bindings

## General
- `SUPER + Q` - Close active window
- `SUPER + Space` - App launcher
- `SUPER + T` - Terminal
- `SUPER + E` - File manager
- `SUPER + F` - Toggle fullscreen

## Workspace
- `SUPER + 1-9` - Switch to workspace 1-9
- `SUPER + SHIFT + 1-9` - Move window to workspace 1-9

## Window Management
- `SUPER + Arrow keys` - Focus window in direction
- `SUPER + SHIFT + Arrow keys` - Move window in direction
- `SUPER + CTRL + Arrow keys` - Resize window

## Miscellaneous
- `SUPER + L` - Lock screen
- `SUPER + P` - Power menu
- `SUPER + V` - Toggle floating
EOL
    notify-send "Created default keybinds.md" "Edit it at $KEY_HINTS_FILE"
fi

# Function to display markdown file
display_keyhints() {
    # Convert markdown to HTML
    if command -v markdown >/dev/null 2>&1; then
        markdown "$KEY_HINTS_FILE" > "$TEMP_HTML"
    elif command -v pandoc >/dev/null 2>&1; then
        pandoc -f markdown -t html "$KEY_HINTS_FILE" > "$TEMP_HTML"
    else
        # Fallback to basic HTML if markdown parsers not available
        cat > "$TEMP_HTML" << EOL
<!DOCTYPE html>
<html>
<head>
    <title>Key Bindings</title>
    <style>
        body { font-family: sans-serif; margin: 20px; }
        pre { background: #f5f5f5; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>Key Bindings</h1>
    <pre>$(cat "$KEY_HINTS_FILE")</pre>
</body>
</html>
EOL
    fi

    # Display HTML file with default browser
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$TEMP_HTML"
    else
        notify-send "Error" "Cannot open browser, install xdg-utils"
    fi
}

# Display key hints
display_keyhints

exit 0 