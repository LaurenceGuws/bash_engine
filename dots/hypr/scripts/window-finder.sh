#!/bin/bash

# Window Finder - A utility to find and focus on lost windows
# Uses kitty terminal and fzf for selection

# Config
KITTY_WIDTH=1200
KITTY_HEIGHT=800
FZF_PREVIEW_WINDOW="right:50%:wrap"

# Function to get all client windows with useful information
get_windows() {
  hyprctl clients -j | jq -r '.[] | "\(.address) | Title: \(.title) | App: \(.class) | WS: \(.workspace.name) | Pos: \(.at[0]),\(.at[1]) | Mapped: \(.mapped)"' |
  grep -v 'Title:  | App:' |   # Remove empty title entries
  sort -t'|' -k4   # Sort by workspace
}

# Function to focus on a selected window
focus_window() {
  local window_address=$(echo "$1" | awk '{print $1}')
  
  # Check if address is valid
  if [[ -n "$window_address" ]]; then
    echo "Focusing window $window_address"
    hyprctl dispatch focuswindow address:$window_address
  else
    echo "No valid window address found"
  fi
}

# Main function
main() {
  # Get window list
  local windows=$(get_windows)
  
  if [[ -z "$windows" ]]; then
    notify-send "Window Finder" "No windows found" -t 2000
    exit 0
  fi
  
  # Present window list in fzf with preview
  local selected_window=$(echo "$windows" | fzf \
    --prompt="Find window > " \
    --header="Select a window to focus on it" \
    --preview="echo {}" \
    --preview-window="$FZF_PREVIEW_WINDOW" \
    --height=100% \
    --border=rounded \
    --layout=reverse \
    --info=inline \
    --cycle)
  
  # Focus the selected window
  if [[ -n "$selected_window" ]]; then
    focus_window "$selected_window"
  fi
}

# Launch in a kitty terminal
if [[ "$1" == "--standalone" ]]; then
  main
else
  kitty --title "Window Finder" --class "window-finder-popup" -e "$0" --standalone
fi

exit 0 