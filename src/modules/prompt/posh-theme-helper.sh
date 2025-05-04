#!/bin/bash

theme() {
    if [[ -z "$1" ]]; then
        return
    fi
    ENV_FILE="$PROFILE_DIR/config/env.yaml"
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
            pwsh <<'EOF'
function Get-PoshThemes {
    $themeDir = $env:THEME_DIR
    Get-ChildItem "$themeDir" -Filter *.omp.json | ForEach-Object {
        $bar = "─" * 60
        Write-Host "$bar"
        Write-Host "THEME: $($_.BaseName)`n"
        oh-my-posh init pwsh --config $_.FullName | Invoke-Expression
        & $function:prompt
    }
    exit
}

Get-PoshThemes
EOF
            ;;
        *)
            echo "Usage: theme [list|set <theme>|current|loop]"
            ;;
    esac
}

