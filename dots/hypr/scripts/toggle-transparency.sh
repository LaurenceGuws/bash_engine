#!/bin/bash
set -euo pipefail

# Incremental window transparency script for Hyprland

# Configuration - adjust these values to your preference
MIN_OPACITY=0.0      # Minimum opacity (maximum transparency) - set to 0 for fully transparent
MAX_OPACITY=1.0      # Maximum opacity (minimum transparency)
TOGGLE_OPACITY=0.85  # Opacity when toggling from opaque to transparent
OPACITY_STEP=0.05    # How much to change per increment/decrement
SAME_OPACITY=true    # Set to true to use same opacity for active and inactive windows
INACTIVE_DELTA=0.1   # How much more transparent inactive windows should be (if SAME_OPACITY=false)

# Path to store the current state
STATE_FILE="$HOME/.config/hypr/transparency_state"

LOG_FILE="/tmp/transparency_debug.log"
MODE="${1:-toggle}"

log() {
  local msg="$1"
  printf '%s %s\n' "$(date --iso-8601=seconds)" "$msg" >> "$LOG_FILE"
}

if ! command -v hyprctl >/dev/null 2>&1; then
  log "hyprctl not found; cannot toggle transparency"
  exit 1
fi

if ! command -v bc >/dev/null 2>&1; then
  log "bc not found; install bc"
  exit 1
fi

log "Script started with mode: $MODE"

CURRENT_HYPR_CMD=$(hyprctl -j getoption decoration:active_opacity 2>/dev/null || true)
log "Hyprland getoption output: $CURRENT_HYPR_CMD"

if command -v jq >/dev/null 2>&1; then
    CURRENT_OPACITY=$(echo "$CURRENT_HYPR_CMD" | jq -r '.float' 2>/dev/null)
else
    CURRENT_OPACITY=$(echo "$CURRENT_HYPR_CMD" | grep -o '"float": [0-9.]*' | awk '{print $2}' 2>/dev/null)
fi

if ! [[ "${CURRENT_OPACITY:-}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    log "Failed to get current opacity, using default 0.95"
    CURRENT_OPACITY="0.95"
fi

echo "$CURRENT_OPACITY" > "$STATE_FILE"
log "Current opacity: $CURRENT_OPACITY"

case "$MODE" in
    increase)
        NEW_OPACITY=$(echo "$CURRENT_OPACITY + $OPACITY_STEP" | bc | awk '{printf "%.2f", $0}')
        if (( $(echo "$NEW_OPACITY > $MAX_OPACITY" | bc -l) )); then
            NEW_OPACITY="$MAX_OPACITY"
        fi
        ;;
    decrease)
        NEW_OPACITY=$(echo "$CURRENT_OPACITY - $OPACITY_STEP" | bc | awk '{printf "%.2f", $0}')
        if (( $(echo "$NEW_OPACITY < $MIN_OPACITY" | bc -l) )); then
            NEW_OPACITY="$MIN_OPACITY"
        fi
        ;;
    toggle)
        if (( $(echo "$CURRENT_OPACITY >= 0.99" | bc -l) )); then
            NEW_OPACITY="$TOGGLE_OPACITY"
        else
            NEW_OPACITY="$MAX_OPACITY"
        fi
        ;;
    *)
        log "Invalid mode '$MODE'"
        exit 1
        ;;
esac

if [ "$SAME_OPACITY" = true ]; then
    INACTIVE_OPACITY="$NEW_OPACITY"
else
    INACTIVE_OPACITY=$(echo "$NEW_OPACITY - $INACTIVE_DELTA" | bc | awk '{printf "%.2f", $0}')
    if (( $(echo "$INACTIVE_OPACITY < $MIN_OPACITY" | bc -l) )); then
        INACTIVE_OPACITY="$MIN_OPACITY"
    fi
fi

log "Setting active: $NEW_OPACITY, inactive: $INACTIVE_OPACITY"

HYPR_CMD="keyword decoration:active_opacity $NEW_OPACITY; keyword decoration:inactive_opacity $INACTIVE_OPACITY"
if hyprctl --batch "$HYPR_CMD"; then
  log "hyprctl applied"
else
  log "hyprctl failed to apply batch command"
fi

echo "$NEW_OPACITY" > "$STATE_FILE"

if command -v notify-send >/dev/null 2>&1; then
  if [ "$SAME_OPACITY" = true ]; then
      notify-send "Window Transparency" "Opacity: ${NEW_OPACITY}" -t 1000
  else
      notify-send "Window Transparency" "Active: ${NEW_OPACITY}, Inactive: ${INACTIVE_OPACITY}" -t 1000
  fi
fi

exit 0
