#!/bin/bash

# Window Finder - A utility to find and focus on lost windows
# Uses kitty terminal and fzf for selection

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
  # shellcheck source=/dev/null
  . "$UTILS_PATH"
fi

# Config
# Size is controlled by Hyprland window rules.
FZF_PREVIEW_WINDOW="right:50%:wrap"

# Function to get all client windows with useful information
# Output format (TSV): address, title, class, workspace, mapped, x, y
get_windows() {
  hyprctl clients -j | jq -r '
    .[]
    | select((.title // "") != "" and (.class // "") != "")
    | [
        .address,
        (.title | gsub("[\\t\\n]+"; " ") | .[0:120]),
        (.class | gsub("[\\t\\n]+"; " ")),
        (.workspace.name // ""),
        (.mapped | tostring),
        (.at[0] // 0 | tostring),
        (.at[1] // 0 | tostring)
      ] | @tsv' |
  sort -t $'\t' -k4
}

# Resolve script path for previews
SCRIPT_PATH="$0"
if command -v realpath >/dev/null 2>&1; then
  SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
  SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

# Preview renderer for fzf
if [[ "${1:-}" == "--preview" ]]; then
  debug_file="/tmp/window-finder-preview.log"
  printf '%s preview addr=%s title=%s app=%s ws=%s mapped=%s pos=%s,%s\n' \
    "$(date --iso-8601=seconds)" "$2" "$3" "$4" "$5" "$6" "$7" "$8" >> "$debug_file"
  addr="${2:-}"
  title="${3:-}"
  app="${4:-}"
  ws="${5:-}"
  mapped="${6:-}"
  x="${7:-}"
  y="${8:-}"
  if [[ -z "$addr" ]]; then
    exit 0
  fi

  preview_dir="/tmp"
  preview_addr="${addr//[:]/_}"
  preview_file="${preview_dir}/window-finder-${preview_addr}.png"
  cache_ttl=5
  if [[ -f "$preview_file" ]]; then
    mtime=$(stat -c %Y "$preview_file" 2>/dev/null || echo 0)
    now=$(date +%s)
    if (( now - mtime > cache_ttl )); then
      rm -f "$preview_file"
    fi
  fi

  if [[ -f "$preview_file" ]]; then
    if [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
      printf '%s using kitty icat file=%s\n' "$(date --iso-8601=seconds)" "$preview_file" >> "$debug_file"
      printf '\033[2J\033[H'
      kitty +kitten icat --transfer-mode=memory --stdin=no --place=60x30@0x7 "$preview_file"
    else
      echo "Preview: $preview_file"
    fi
  else
    printf '%s missing preview file=%s\n' "$(date --iso-8601=seconds)" "$preview_file" >> "$debug_file"
    echo "(no preview available)"
  fi

  printf "\nTitle: %s\nApp: %s\nWorkspace: %s\nPosition: %s,%s\nMapped: %s\nAddress: %s\n" \
    "$title" "$app" "$ws" "$x" "$y" "$mapped" "$addr"
  exit 0
fi

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
  
  # Pre-capture window screenshots so previews are instant
  local orig_addr
  orig_addr=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')
  capture_log="/tmp/window-finder-capture.log"
  printf '%s capturing %s windows\n' "$(date --iso-8601=seconds)" "$(echo "$windows" | wc -l)" >> "$capture_log"
  while IFS=$'\t' read -r addr title app ws mapped x y; do
    [[ -z "$addr" ]] && continue
    preview_addr="${addr//[:]/_}"
    preview_file="/tmp/window-finder-${preview_addr}.png"
    if [[ ! -f "$preview_file" ]]; then
      printf '%s capture addr=%s title=%s app=%s ws=%s\n' "$(date --iso-8601=seconds)" "$addr" "$title" "$app" "$ws" >> "$capture_log"
      hyprctl dispatch focuswindow address:"$addr" >/dev/null 2>&1
      hyprshot -m window -m active -s -o "/tmp" -f "window-finder-${preview_addr}.png" >/dev/null 2>&1 || true
    fi
  done <<< "$windows"
  if [[ -n "$orig_addr" ]]; then
    hyprctl dispatch focuswindow address:"$orig_addr" >/dev/null 2>&1
  fi

  local list_file="/tmp/window-finder-list-$$.tsv"
  printf '%s\n' "$windows" > "$list_file"
  trap 'rm -f "$list_file"' EXIT

  # Present window list in fzf with preview
  local selected_window
  selected_window=$(echo "$windows" | \
    awk -F'\t' '{
      ws=$4; app=$3; title=$2; mapped=$5;
      status=(mapped=="true"?"":"(hidden) ");
      printf "%s\t%s%s — %s (ws:%s)\n", $1, status, title, app, ws
    }' | \
    fzf \
      --prompt="Find window > " \
      --header="Select a window to focus on it" \
      --with-nth=2 \
      --delimiter="\t" \
      --preview="addr=\$(echo {} | cut -f1); \
        line=\$(awk -F'\\t' -v a=\"\$addr\" 'a==\$1 {print; exit}' \"$list_file\"); \
        IFS=\$'\\t' read -r a t c w m x y <<< \"\$line\"; \
        \"$SCRIPT_PATH\" --preview \"\$a\" \"\$t\" \"\$c\" \"\$w\" \"\$m\" \"\$x\" \"\$y\"" \
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

mode="${1:-}"

if [[ "$mode" == "--standalone" ]]; then
  main
else
  if command -v launch_kitty_popup >/dev/null 2>&1; then
    launch_kitty_popup "window-finder-popup" "Window Finder" "" "\"$SCRIPT_PATH\" --standalone"
    exit 0
  fi
  kitty --title "Window Finder" --class "window-finder-popup" -e "$SCRIPT_PATH" --standalone
fi

exit 0
