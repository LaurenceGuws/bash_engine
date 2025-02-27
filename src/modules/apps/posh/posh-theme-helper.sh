#!/bin/bash

theme() {
    if [[ -z "$1" ]]; then
        return
    fi
    ENV_FILE="$PROFILE_DIR/config/env/env.yaml"
    case "$1" in
        list)
            ls "$THEME_DIR" 2>/dev/null | sed 's/\.[^.]*$//' | sed 's/\.omp$//'
            ;;
        set)
            local selected_theme="$2"

            if [[ -z "$selected_theme" ]]; then
                echo "Error: No theme specified."
                return
            fi

            if [[ -f "$THEME_DIR/$selected_theme.omp.json" ]]; then
                sed -i "s/^THEME: .*/THEME: \"$selected_theme\"/" "$ENV_FILE"
                echo "Theme updated to: $selected_theme"
                echo "To apply the changes, reload your environment."
            else
                echo "Error: Theme '$selected_theme' not found in $THEME_DIR."
            fi
            ;;
        current)
            grep "^THEME:" "$ENV_FILE" | awk -F': ' '{print $2}' | tr -d '"'
            ;;
        loop)
            if ! command -v pwsh &> /dev/null; then
                echo "PowerShell not found. Install PowerShell to use this feature."
                return
            fi

            pwsh -Command "Get-PoshThemes '$THEME_DIR'"
            ;;
        *)
            echo "Usage: theme [list|set <theme>|current|loop]"
            ;;
    esac
}

