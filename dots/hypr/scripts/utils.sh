#!/usr/bin/env bash
set -euo pipefail

notify_msg() {
  local title="$1"
  local message="$2"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$message"
  else
    printf '%s: %s\n' "$title" "$message" >&2
  fi
}

require_cmds() {
  local missing=()
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if ((${#missing[@]})); then
    notify_msg "Missing tools" "Install: ${missing[*]}"
    return 1
  fi
  return 0
}

log_dispatch() {
  if [[ -n "${LOG_FUNC:-}" ]]; then
    "$LOG_FUNC" "$@"
  fi
}

hypr_exec() {
  log_dispatch "dispatch helper command: $*"
  if hyprctl dispatch exec "$@" >/dev/null 2>&1; then
    log_dispatch "hyprctl dispatch exec succeeded for helper"
    return 0
  fi
  log_dispatch "hyprctl dispatch exec failed for helper"
  return 1
}

pick_terminal() {
  local term
  for term in kitty alacritty foot wezterm gnome-terminal xfce4-terminal xterm; do
    if command -v "$term" >/dev/null 2>&1; then
      printf '%s' "$term"
      return 0
    fi
  done
  return 1
}

run_in_terminal() {
  if (("$#" == 0)); then
    return 1
  fi
  local term
  term=$(pick_terminal) || return 1
  local cmd=("$@")
  case "$term" in
    wezterm)
      setsid "$term" start -- "${cmd[@]}" >/dev/null 2>&1 &
      ;;
    gnome-terminal)
      setsid "$term" -- "${cmd[@]}" >/dev/null 2>&1 &
      ;;
    *)
      setsid "$term" -e "${cmd[@]}" >/dev/null 2>&1 &
      ;;
  esac
  return 0
}

launch_kitty_popup() {
  # Usage: launch_kitty_popup <class> <title> <size (unused)> <cmd_string> [toggle (default 1)]
  # Size is now controlled via Hyprland window rules; third argument is kept for compatibility.
  local popup_class="$1"
  local popup_title="$2"
  local _popup_size_ignored="$3"
  local popup_cmd="$4"
  local toggle="${5:-1}"

  if ! command -v kitty >/dev/null 2>&1; then
    log_dispatch "kitty not available for popup ${popup_class}"
    return 1
  fi

  local pattern="kitty --class ${popup_class} --title ${popup_title}"
  if [[ "$toggle" == "1" ]] && pgrep -fx "${pattern}.*" >/dev/null; then
    log_dispatch "popup already running, toggling off: ${popup_class}"
    pkill -f "${pattern}"
    return 0
  fi

  local launch_cmd="[float] kitty --detach --class ${popup_class} --app-id ${popup_class} --name ${popup_class} --title '${popup_title}' bash -lc \"${popup_cmd}\""
  log_dispatch "launching popup class=${popup_class} title=${popup_title} cmd=${popup_cmd}"
  if command -v hypr_exec >/dev/null 2>&1; then
    hypr_exec "$launch_cmd" && return 0
  fi
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exec "$launch_cmd" >/dev/null 2>&1 && return 0
  fi
  if command -v setsid >/dev/null 2>&1; then
    setsid -f -- bash -lc "$launch_cmd" >/dev/null 2>&1 && return 0
  fi
  bash -lc "$launch_cmd" >/dev/null 2>&1
}
