#!/usr/bin/env bash
set -euo pipefail

POPUP_CLASS="pulsemixer-popup"
POPUP_TITLE="PulseMixer"

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
  # shellcheck source=/dev/null
  . "$UTILS_PATH"
fi

if ! command -v notify_msg >/dev/null 2>&1; then
  notify_msg() { printf '%s: %s\n' "$1" "$2" >&2; }
fi

if ! command -v pulsemixer >/dev/null 2>&1; then
  printf 'volume popup: pulsemixer not found\n' >&2
  exit 1
fi

if command -v hyprctl >/dev/null 2>&1; then
  # Toggle existing popup if present.
  if pgrep -fx "kitty --class ${POPUP_CLASS} --title ${POPUP_TITLE}" >/dev/null; then
    pkill -f "kitty --class ${POPUP_CLASS} --title ${POPUP_TITLE}"
    exit 0
  fi

  launch_cmd="[float] kitty --detach --class ${POPUP_CLASS} --title '${POPUP_TITLE}' bash -lc 'pulsemixer; pkill -f \"kitty --class ${POPUP_CLASS} --title ${POPUP_TITLE}\"'"
  if command -v hypr_exec >/dev/null 2>&1; then
    hypr_exec "$launch_cmd" || hyprctl dispatch exec "$launch_cmd" >/dev/null 2>&1 || true
  else
    hyprctl dispatch exec "$launch_cmd" >/dev/null 2>&1 || true
  fi
  exit 0
fi

# Fallback: run in a terminal without Hyprland controls
if command -v run_in_terminal >/dev/null 2>&1; then
  run_in_terminal pulsemixer || notify_msg "Volume popup" "No terminal available to launch pulsemixer"
else
  notify_msg "Volume popup" "Install kitty/alacritty/foot to open pulsemixer"
fi
