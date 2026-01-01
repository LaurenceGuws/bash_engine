#!/usr/bin/env bash
set -euo pipefail

POPUP_CLASS="pulsemixer-popup"
POPUP_TITLE="PulseMixer"
ENV_FLAG="VOLUME_POPUP_RUNNING"

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

SCRIPT_PATH="$0"
if command -v realpath >/dev/null 2>&1; then
  SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
  SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

run_pulsemixer() {
  pulsemixer
}

if command -v hypr_popup_run >/dev/null 2>&1; then
  hypr_popup_run "$ENV_FLAG" "$POPUP_CLASS" "$POPUP_TITLE" \
    "kitty --detach --class ${POPUP_CLASS} --title '${POPUP_TITLE}' bash -lc '${ENV_FLAG}=1 \"${SCRIPT_PATH}\"'" \
    run_pulsemixer \
    br
  exit 0
fi

# Fallback: run in a terminal without Hyprland controls
if command -v run_in_terminal >/dev/null 2>&1; then
  run_in_terminal pulsemixer || notify_msg "Volume popup" "No terminal available to launch pulsemixer"
else
  notify_msg "Volume popup" "Install kitty/alacritty/foot to open pulsemixer"
fi
