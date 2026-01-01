#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UTILS_PATH="$REPO_ROOT/dots/hypr/scripts/utils.sh"
LOG_FILE="/tmp/wofi-bottom-left-test.log"

log() {
  local timestamp
  timestamp=$(date --iso-8601=seconds)
  printf '%s %s\n' "$timestamp" "$*" | tee -a "$LOG_FILE"
}

corner_input="bottom-left"
use_normal_window=1
for arg in "$@"; do
  case "$arg" in
    --layer)
      use_normal_window=0
      ;;
    --normal|--normal-window)
      use_normal_window=1
      ;;
    tl|top-left|tr|top-right|bl|bottom-left|br|bottom-right)
      corner_input="$arg"
      ;;
    *)
      printf 'usage: %s [--normal|--layer] [tl|tr|bl|br|top-left|top-right|bottom-left|bottom-right]\n' "$0" >&2
      exit 1
      ;;
  esac
done

case "$corner_input" in
  tl|top-left)
    corner_label="top-left"
    wofi_location="top-left"
    ;;
  tr|top-right)
    corner_label="top-right"
    wofi_location="top-right"
    ;;
  bl|bottom-left)
    corner_label="bottom-left"
    wofi_location="bottom-left"
    ;;
  br|bottom-right)
    corner_label="bottom-right"
    wofi_location="bottom-right"
    ;;
esac

log "starting wofi corner test (${corner_label})"

if [[ ! -r "$UTILS_PATH" ]]; then
  log "utils.sh not found at $UTILS_PATH"
  exit 1
fi

# shellcheck source=/dev/null
. "$UTILS_PATH"

require_cmds hyprctl jq wofi || exit 1

read -r mon_name mon_x mon_y mon_w mon_h mon_scale r_top r_right r_bottom r_left <<<"$(hypr_focused_monitor_info)"
if [[ -z "$mon_name" ]]; then
  log "failed to read monitor info"
  exit 1
fi
log "monitor info name=${mon_name} geom=${mon_x},${mon_y}+${mon_w}x${mon_h} scale=${mon_scale} reserved=${r_top},${r_right},${r_bottom},${r_left}"

prev_focus=$(hypr_active_window_address || true)
log "previous focus address=${prev_focus:-unset}"

margin=12
read -r corner_left corner_right corner_top corner_bottom <<<"$(hypr_focused_monitor_corner_bounds_with_waybar "$margin")"
log "monitor corner bounds (waybar-aware) left=${corner_left} right=${corner_right} top=${corner_top} bottom=${corner_bottom} margin=${margin}"
if [[ "$use_normal_window" == "1" ]]; then
  log "launching wofi normal window for ${corner_label}"
  hypr_exec "[float] wofi --show drun --normal-window --monitor \"${mon_name}\""
else
  log "launching wofi layer for ${corner_label} with offsets x=${margin} y=${margin}"
  hypr_exec "[float] wofi --show drun --location ${wofi_location} --xoffset ${margin} --yoffset ${margin} --monitor \"${mon_name}\""
fi
sleep 0.2

read -r active_class active_title <<<"$(hypr_active_window_class_title)"
log "active window class=${active_class:-unset} title=${active_title:-unset}"

if [[ -n "$prev_focus" && "$prev_focus" != "null" ]]; then
  hypr_dispatch_focuswindow_address "$prev_focus" || true
  log "restored focus to address=${prev_focus}"
fi

if [[ "$use_normal_window" == "1" ]]; then
  address=""
  win_w=""
  win_h=""
  for _ in $(seq 1 20); do
    address=$(hypr_find_client_address_by_class_or_title "wofi" "wofi")
    if [[ -n "$address" && "$address" != "null" ]]; then
      read -r win_w win_h <<<"$(hypr_client_size_by_address "$address")"
      break
    fi
    sleep 0.05
  done

  if [[ -z "$address" || "$address" == "null" ]]; then
    log "failed to resolve wofi window address"
    exit 1
  fi
  log "wofi window address=$address size=${win_w}x${win_h}"

  read -r expected_x expected_y <<<"$(hypr_corner_target_for_size "$corner_label" "$win_w" "$win_h" "$margin")"
  log "moving wofi to ${corner_label} at=${expected_x},${expected_y}"
  hypr_dispatch_movewindowpixel_exact "$expected_x" "$expected_y" "$address"

  sleep 0.2
  read -r after_x after_y <<<"$(hypr_client_at_by_address "$address")"
  read -r after_w after_h <<<"$(hypr_client_size_by_address "$address")"
  log "wofi after move at=${after_x},${after_y} size=${after_w}x${after_h}"
else
  sleep 0.2
  wofi_layer=$(hypr_layer_namespace_for_monitor "$mon_name" "wofi")

  if [[ -z "$wofi_layer" || "$wofi_layer" == "null" ]]; then
    log "wofi layer not found on monitor=${monitor_name}"
    exit 1
  fi

  read -r layer_x layer_y layer_w layer_h <<<"$wofi_layer"
  log "wofi layer at=${layer_x},${layer_y} size=${layer_w}x${layer_h}"

  read -r expected_x expected_y <<<"$(hypr_corner_target_for_size "$corner_label" "$layer_w" "$layer_h" "$margin")"
  log "expected ${corner_label} at=${expected_x},${expected_y} (based on layer size)"
fi
