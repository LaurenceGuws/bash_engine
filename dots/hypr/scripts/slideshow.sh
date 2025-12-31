#!/bin/bash

set_wallpapers() {
  local config_path="$HOME/.config/hypr/hyprpaper.conf"
  local tmp_config
  tmp_config="$(mktemp)"
  local wallpapers_root="$HOME/Pictures/wallpapers"

  # Stop any running hyprpaper instance so it reloads the new config cleanly.
  pkill -x hyprpaper >/dev/null 2>&1 || true
  sleep 1

  # Base config (new hyprpaper syntax).
  {
    printf 'splash = false\n'
    printf 'ipc = true\n\n'
  } >"$tmp_config"

  # Read script hints from hyprpaper.conf (defaults).
  local use_all="false"
  local use_theme=""
  local use_resolution_match="false"
  if [[ -f "$config_path" ]]; then
    while IFS= read -r line; do
      case "$line" in
        use_all\ *=*)
          use_all="${line#*=}"
          ;;
        use_theme\ *=*)
          use_theme="${line#*=}"
          ;;
        use_resolution_match\ *=*)
          use_resolution_match="${line#*=}"
          ;;
      esac
    done <"$config_path"
  fi

  use_all="$(printf '%s' "$use_all" | tr -d '[:space:]')"
  use_resolution_match="$(printf '%s' "$use_resolution_match" | tr -d '[:space:]')"
  use_theme="$(printf '%s' "$use_theme" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  if command -v envsubst >/dev/null 2>&1; then
    use_theme="$(printf '%s' "$use_theme" | envsubst)"
  else
    use_theme="${use_theme//$THEME/$THEME}"
  fi

  # Build the candidate list based on category rules.
  local candidate_dir="$wallpapers_root"
  if [[ "$use_all" != "true" && -n "$use_theme" ]]; then
    candidate_dir="${wallpapers_root}/${use_theme}"
  fi
  if [[ ! -d "$candidate_dir" ]]; then
    candidate_dir="$wallpapers_root"
  fi

  local candidates
  if [[ "$use_all" == "true" ]]; then
    candidates="$(fd -e png -e jpg -e jpeg -e webp . "$wallpapers_root")"
  else
    candidates="$(fd -e png -e jpg -e jpeg -e webp . "$candidate_dir")"
  fi

  # Prepare resolution cache (path -> width height).
  local cache_file="$HOME/.cache/hyprpaper-wallpapers.tsv"
  mkdir -p "$(dirname "$cache_file")"
  declare -A size_cache
  if [[ -f "$cache_file" ]]; then
    while IFS=$'\t' read -r path mtime width height; do
      size_cache["$path"]="$mtime $width $height"
    done <"$cache_file"
  fi
  local cache_tmp
  cache_tmp="$(mktemp)"

  # Helper to get image size with minimal overhead.
  get_image_size() {
    local img_path="$1"
    if command -v identify >/dev/null 2>&1; then
      identify -format '%w %h' "$img_path" 2>/dev/null
      return
    fi
    if command -v magick >/dev/null 2>&1; then
      magick identify -format '%w %h' "$img_path" 2>/dev/null
      return
    fi
    if command -v ffprobe >/dev/null 2>&1; then
      ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0:s=' ' "$img_path" 2>/dev/null
      return
    fi
    return 1
  }

  # Get all monitor names with their pixel sizes.
  local monitors_json
  monitors_json="$(hyprctl monitors -j)"

  # Pre-index candidates by resolution when matching is enabled.
  declare -A res_map
  if [[ "$use_resolution_match" == "true" ]]; then
    while IFS= read -r img_path; do
      [[ -z "$img_path" ]] && continue
      local mtime
      mtime="$(stat -c %Y "$img_path" 2>/dev/null || echo 0)"
      local cached="${size_cache["$img_path"]:-}"
      local cached_mtime cached_w cached_h
      cached_mtime="${cached%% *}"
      cached_w="${cached#* }"
      cached_w="${cached_w%% *}"
      cached_h="${cached##* }"
      if [[ "$cached_mtime" != "$mtime" ]]; then
        local dims
        dims="$(get_image_size "$img_path" || true)"
        if [[ -n "$dims" ]]; then
          cached_w="${dims%% *}"
          cached_h="${dims##* }"
          size_cache["$img_path"]="$mtime $cached_w $cached_h"
        fi
      fi
      printf '%s\t%s\t%s\t%s\n' "$img_path" "$mtime" "$cached_w" "$cached_h" >>"$cache_tmp"
      if [[ -n "$cached_w" && -n "$cached_h" ]]; then
        local key="${cached_w}x${cached_h}"
        res_map["$key"]+="${img_path}"$'\n'
      fi
    done <<<"$candidates"
  fi

  # Assign a random wallpaper to each monitor.
  local monitor name width height
  while IFS=$'\t' read -r name width height; do
    local wallpaper=""
    if [[ "$use_resolution_match" == "true" ]]; then
      local key="${width}x${height}"
      if [[ -n "${res_map["$key"]:-}" ]]; then
        wallpaper="$(printf '%s' "${res_map["$key"]}" | shuf -n1)"
      fi
    fi

    if [[ -z "$wallpaper" ]]; then
      wallpaper="$(printf '%s\n' "$candidates" | shuf -n1)"
    fi

    if [[ -n "$wallpaper" ]]; then
      {
        printf 'wallpaper {\n'
        printf '  monitor = %s\n' "$name"
        printf '  path = %s\n' "$wallpaper"
        printf '  fit_mode = cover\n'
        printf '}\n\n'
      } >>"$tmp_config"
    fi
  done < <(printf '%s\n' "$monitors_json" | jq -r '.[] | [.name, .width, .height] | @tsv')

  # Refresh cache.
  if [[ -s "$cache_tmp" ]]; then
    sort -u "$cache_tmp" >"$cache_file"
  fi
  rm -f "$cache_tmp"

  install -m 0644 "$tmp_config" "$config_path"
  rm -f "$tmp_config"

  # Start hyprpaper with the new config.
  hyprpaper >/dev/null 2>&1 &
  sleep 1
}

# The main loop instead of recursion
slideshow() {
  # Initial wallpaper setup.
  set_wallpapers

  while true; do
    # Refresh wallpapers every 10 minutes.
    sleep 10m
    set_wallpapers
  done
}

# If we're already running, don't start again.
if pgrep -f "bash $0" | grep -v "$$" >/dev/null; then
  echo "Slideshow is already running"
  exit 0
fi

# Run the slideshow function in the background.
slideshow &

# Detach from the terminal.
disown
