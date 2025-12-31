#!/bin/bash
# Nerd Fonts Icon Finder with fzf
# Usage: ./icon_finder.sh [simple|full|copy]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIMPLE_FILE="$SCRIPT_DIR/icons_simple.txt"
FZF_FILE="$SCRIPT_DIR/icons_fzf.txt"

# Options for fzf
FZF_OPTS="--ansi --reverse --border --height 40% --preview-window=right:30%"

show_help() {
    echo "Nerd Fonts Icon Finder"
    echo "Usage: $0 [mode]"
    echo ""
    echo "Modes:"
    echo "  simple    - Simple format with basic info (default)"
    echo "  full      - Full format with all keywords for better searching"
    echo "  copy      - Simple format with auto-copy to clipboard"
    echo "  help      - Show this help"
    echo ""
    echo "Controls:"
    echo "  - Type to search"
    echo "  - Use arrow keys or j/k to navigate"
    echo "  - Press Enter to select"
    echo "  - Escape to exit"
    echo ""
    echo "Examples:"
    echo "  $0              # Simple mode"
    echo "  $0 simple       # Same as above"
    echo "  $0 full         # Full search with keywords"
    echo "  $0 copy         # Auto-copy selected icon"
}

check_dependencies() {
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed."
        echo "Install with: sudo pacman -S fzf"
        exit 1
    fi
    
    if [[ ! -f "$SIMPLE_FILE" ]]; then
        echo "Error: $SIMPLE_FILE not found."
        echo "Run the create_fzf_icons.py script first."
        exit 1
    fi
}

copy_mode() {
    echo "Icon Finder - Copy Mode"
    echo "Select an icon to copy to clipboard"
    
    if ! command -v xclip &> /dev/null; then
        echo "Warning: xclip not found. Icons will be displayed but not copied."
        echo "Install with: sudo pacman -S xclip"
        echo ""
    fi
    
    selected=$(cat "$SIMPLE_FILE" | grep -v '^#' | fzf \
        --prompt="🔍 Search icons: " \
        --header="Press Enter to select and copy, Esc to exit" \
        --preview='echo "Icon: {1}" && echo "Name: {2}" && echo "Description: {3}"' \
        $FZF_OPTS)
    
    if [[ -n "$selected" ]]; then
        icon=$(echo "$selected" | awk '{print $1}')
        if command -v xclip &> /dev/null; then
            echo "$icon" | xclip -selection clipboard
            echo "Copied to clipboard: $icon"
        else
            echo "Selected icon: $icon"
            echo "(Install xclip to enable clipboard functionality)"
        fi
    fi
}

simple_mode() {
    echo "Icon Finder - Simple Mode"
    selected=$(cat "$SIMPLE_FILE" | grep -v '^#' | fzf \
        --prompt="🔍 Search icons: " \
        --header="Press Enter to select, Esc to exit" \
        --preview='echo "Icon: {1}" && echo "Name: {2}" && echo "Description: {3}"' \
        $FZF_OPTS)
    
    if [[ -n "$selected" ]]; then
        echo "Selected: $selected"
        icon=$(echo "$selected" | awk '{print $1}')
        echo "Icon only: $icon"
    fi
}

full_mode() {
    echo "Icon Finder - Full Mode (with all search keywords)"
    selected=$(cat "$FZF_FILE" | grep -v '^#' | fzf \
        --prompt="🔍 Search icons (with keywords): " \
        --header="Press Enter to select, Esc to exit" \
        --preview='echo {} | cut -d"|" -f1' \
        $FZF_OPTS)
    
    if [[ -n "$selected" ]]; then
        main_info=$(echo "$selected" | cut -d'|' -f1)
        echo "Selected: $main_info"
        icon=$(echo "$main_info" | awk '{print $1}')
        echo "Icon only: $icon"
    fi
}

main() {
    check_dependencies
    
    case "${1:-simple}" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "simple"|"")
            simple_mode
            ;;
        "full")
            full_mode
            ;;
        "copy")
            copy_mode
            ;;
        *)
            echo "Unknown mode: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"