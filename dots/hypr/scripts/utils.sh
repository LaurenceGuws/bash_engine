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

hypr_focused_monitor_geom() {
  # Prints: x y width height
  local monitors_json monitor
  monitors_json=$(hyprctl monitors -j 2>/dev/null) || return 1
  monitor=$(jq -r 'map(select(.focused == true))[0] // .[0]' <<<"$monitors_json")
  if [[ -z "$monitor" || "$monitor" == "null" ]]; then
    return 1
  fi
  printf '%s %s %s %s' \
    "$(jq -r '.x // 0' <<<"$monitor")" \
    "$(jq -r '.y // 0' <<<"$monitor")" \
    "$(jq -r '.width // 0' <<<"$monitor")" \
    "$(jq -r '.height // 0' <<<"$monitor")"
}

hypr_focused_monitor_info() {
  # Prints: name x y width height scale reserved_top reserved_right reserved_bottom reserved_left
  local monitors_json monitor
  monitors_json=$(hyprctl monitors -j 2>/dev/null) || return 1
  monitor=$(jq -r 'map(select(.focused == true))[0] // .[0]' <<<"$monitors_json")
  if [[ -z "$monitor" || "$monitor" == "null" ]]; then
    return 1
  fi
  local reserved_left reserved_right reserved_top reserved_bottom
  reserved_left=$(jq -r '.reserved[0] // 0' <<<"$monitor")
  reserved_right=$(jq -r '.reserved[1] // 0' <<<"$monitor")
  reserved_top=$(jq -r '.reserved[2] // 0' <<<"$monitor")
  reserved_bottom=$(jq -r '.reserved[3] // 0' <<<"$monitor")
  printf '%s %s %s %s %s %s %s %s %s %s' \
    "$(jq -r '.name // ""' <<<"$monitor")" \
    "$(jq -r '.x // 0' <<<"$monitor")" \
    "$(jq -r '.y // 0' <<<"$monitor")" \
    "$(jq -r '.width // 0' <<<"$monitor")" \
    "$(jq -r '.height // 0' <<<"$monitor")" \
    "$(jq -r '.scale // 1' <<<"$monitor")" \
    "$reserved_top" \
    "$reserved_right" \
    "$reserved_bottom" \
    "$reserved_left"
}

hypr_focused_monitor_usable_geom() {
  # Prints: usable_x usable_y usable_width usable_height
  local info name x y w h scale r_top r_right r_bottom r_left
  info=$(hypr_focused_monitor_info) || return 1
  read -r name x y w h scale r_top r_right r_bottom r_left <<<"$info"
  printf '%s %s %s %s' \
    "$((x + r_left))" \
    "$((y + r_top))" \
    "$((w - r_left - r_right))" \
    "$((h - r_top - r_bottom))"
}

hypr_focused_monitor_corner_bounds() {
  # Usage: hypr_focused_monitor_corner_bounds [margin]
  # Prints: corner_left corner_right corner_top corner_bottom
  local margin="${1:-12}"
  local info name x y w h scale r_top r_right r_bottom r_left
  info=$(hypr_focused_monitor_info) || return 1
  read -r name x y w h scale r_top r_right r_bottom r_left <<<"$info"
  printf '%s %s %s %s' \
    "$((x + r_left + margin))" \
    "$((x + w - r_right - margin))" \
    "$((y + r_top + margin))" \
    "$((y + h - r_bottom - margin))"
}

hypr_waybar_geometry_for_monitor() {
  # Usage: hypr_waybar_geometry_for_monitor <monitor_name>
  # Prints: x y width height
  local monitor_name="$1"
  if [[ -z "$monitor_name" ]]; then
    log_dispatch "hypr_waybar_geometry_for_monitor called without monitor name"
    return 1
  fi

  local layers_json
  layers_json=$(hyprctl layers -j 2>/dev/null) || {
    log_dispatch "hyprctl layers failed while fetching waybar geometry"
    return 1
  }

  local candidates=()
  while IFS= read -r line; do
    candidates+=("$line")
  done < <(printf '%s' "$layers_json" \
    | jq -r --arg mon "$monitor_name" '
        .[$mon].levels // empty
        | to_entries | map(.value) | add // []
        | map(select(.namespace=="waybar"))
        | .[]? | "\(.x) \(.y) \(.w) \(.h)"')

  if ((${#candidates[@]} == 0)); then
    log_dispatch "no waybar layer candidates found for monitor=${monitor_name}"
    return 1
  fi

  local best="${candidates[0]}"
  local bar_x bar_y bar_w bar_h
  read -r bar_x bar_y bar_w bar_h <<<"$best"
  log_dispatch "waybar geometry monitor=${monitor_name} coords=${bar_x},${bar_y} size=${bar_w}x${bar_h}"
  printf '%s %s %s %s' "$bar_x" "$bar_y" "$bar_w" "$bar_h"
}

hypr_popup_position_for_size() {
  # Usage: hypr_popup_position_for_size <width> <height> [margin] [waybar_position]
  # Prints: abs_x abs_y pct_x pct_y
  local width="$1"
  local height="$2"
  local margin="${3:-12}"
  local waybar_position="${4:-${WAYBAR_POSITION:-bottom}}"

  if [[ -z "$width" || -z "$height" ]]; then
    log_dispatch "hypr_popup_position_for_size missing width/height"
    return 1
  fi

  local info name x y w h scale r_top r_right r_bottom r_left
  info=$(hypr_focused_monitor_info) || return 1
  read -r name x y w h scale r_top r_right r_bottom r_left <<<"$info"
  if [[ -z "$name" || -z "$w" || -z "$h" ]]; then
    return 1
  fi

  local corner_left corner_right corner_top corner_bottom
  read -r corner_left corner_right corner_top corner_bottom <<<"$(hypr_focused_monitor_corner_bounds_with_waybar "$margin" "$waybar_position")" || return 1

  local corner="br"
  case "$waybar_position" in
    top)
      corner="tr"
      ;;
    left)
      corner="tl"
      ;;
    right)
      corner="tr"
      ;;
    bottom|*)
      corner="br"
      ;;
  esac

  local target_x target_y
  read -r target_x target_y <<<"$(hypr_corner_target_for_size "$corner" "$width" "$height" "$margin" "$waybar_position")" || return 1

  local min_x=$corner_left
  local max_x=$((corner_right - width))
  local min_y=$corner_top
  local max_y=$((corner_bottom - height))

  ((target_x > max_x)) && target_x=$max_x
  ((target_x < min_x)) && target_x=$min_x
  ((target_y > max_y)) && target_y=$max_y
  ((target_y < min_y)) && target_y=$min_y

  local rel_x=$((target_x - x))
  local rel_y=$((target_y - y))
  local pct_x=$((rel_x * 100 / w))
  local pct_y=$((rel_y * 100 / h))

  printf '%s %s %s %s' "$target_x" "$target_y" "$pct_x" "$pct_y"
}

hypr_focused_monitor_corner_bounds_with_waybar() {
  # Usage: hypr_focused_monitor_corner_bounds_with_waybar [margin] [waybar_position]
  # Prints: corner_left corner_right corner_top corner_bottom
  local margin="${1:-12}"
  local waybar_position="${2:-${WAYBAR_POSITION:-bottom}}"
  local info name x y w h scale r_top r_right r_bottom r_left
  info=$(hypr_focused_monitor_info) || return 1
  read -r name x y w h scale r_top r_right r_bottom r_left <<<"$info"
  local margin_scaled="$margin"
  if [[ -n "$scale" && "$scale" != "0" && "$scale" != "1" ]]; then
    x=$(hypr_scale_value "$x" "$scale")
    y=$(hypr_scale_value "$y" "$scale")
    w=$(hypr_scale_value "$w" "$scale")
    h=$(hypr_scale_value "$h" "$scale")
    r_top=$(hypr_scale_value "$r_top" "$scale")
    r_right=$(hypr_scale_value "$r_right" "$scale")
    r_bottom=$(hypr_scale_value "$r_bottom" "$scale")
    r_left=$(hypr_scale_value "$r_left" "$scale")
    margin_scaled=$(hypr_scale_value "$margin" "$scale")
  fi

  local corner_left=$((x + r_left + margin_scaled))
  local corner_right=$((x + w - r_right - margin_scaled))
  local corner_top=$((y + r_top + margin_scaled))
  local corner_bottom=$((y + h - r_bottom - margin_scaled))

  local waybar_coords
  if waybar_coords=$(hypr_waybar_geometry_for_monitor "$name"); then
    local bar_x bar_y bar_w bar_h
    read -r bar_x bar_y bar_w bar_h <<<"$waybar_coords"
    case "$waybar_position" in
      top)
        corner_top=$((bar_y + bar_h + margin_scaled))
        ;;
      left)
        corner_left=$((bar_x + bar_w + margin_scaled))
        ;;
      right)
        corner_right=$((bar_x - margin_scaled))
        ;;
      bottom|*)
        corner_bottom=$((bar_y - margin_scaled))
        ;;
    esac
  fi

  printf '%s %s %s %s' "$corner_left" "$corner_right" "$corner_top" "$corner_bottom"
}

hypr_corner_target_for_size() {
  # Usage: hypr_corner_target_for_size <corner> <width> <height> [margin] [waybar_position]
  # Prints: target_x target_y
  local corner="$1"
  local width="$2"
  local height="$3"
  local margin="${4:-12}"
  local waybar_position="${5:-${WAYBAR_POSITION:-bottom}}"

  if [[ -z "$corner" || -z "$width" || -z "$height" ]]; then
    log_dispatch "hypr_corner_target_for_size missing args corner=${corner} width=${width} height=${height}"
    return 1
  fi

  local corner_left corner_right corner_top corner_bottom
  read -r corner_left corner_right corner_top corner_bottom <<<"$(hypr_focused_monitor_corner_bounds_with_waybar "$margin" "$waybar_position")" || return 1

  local target_x target_y
  case "$corner" in
    tl|top-left)
      target_x=$corner_left
      target_y=$corner_top
      ;;
    ct|top-center|top-centre)
      target_x=$((corner_left + (corner_right - corner_left - width) / 2))
      target_y=$corner_top
      ;;
    tr|top-right)
      target_x=$((corner_right - width))
      target_y=$corner_top
      ;;
    cl|center-left|centre-left|left-center|left-centre)
      target_x=$corner_left
      target_y=$((corner_top + (corner_bottom - corner_top - height) / 2))
      ;;
    bl|bottom-left)
      target_x=$corner_left
      target_y=$((corner_bottom - height))
      ;;
    cb|bottom-center|bottom-centre)
      target_x=$((corner_left + (corner_right - corner_left - width) / 2))
      target_y=$((corner_bottom - height))
      ;;
    br|bottom-right)
      target_x=$((corner_right - width))
      target_y=$((corner_bottom - height))
      ;;
    cr|center-right|centre-right|right-center|right-centre)
      target_x=$((corner_right - width))
      target_y=$((corner_top + (corner_bottom - corner_top - height) / 2))
      ;;
    cc|center|centre)
      target_x=$((corner_left + (corner_right - corner_left - width) / 2))
      target_y=$((corner_top + (corner_bottom - corner_top - height) / 2))
      ;;
    *)
      log_dispatch "hypr_corner_target_for_size unknown corner=${corner}"
      return 1
      ;;
  esac

  printf '%s %s' "$target_x" "$target_y"
}

hypr_scale_value() {
  # Usage: hypr_scale_value <value> <scale>
  local value="${1:-0}"
  local scale="${2:-1}"
  awk -v v="$value" -v s="$scale" 'BEGIN { if (s == 0) s = 1; printf "%d", (v / s) }'
}

hypr_active_window_geom() {
  # Prints: x y width height
  local window_json
  window_json=$(hyprctl activewindow -j 2>/dev/null) || return 1
  if [[ -z "$window_json" || "$window_json" == "null" ]]; then
    return 1
  fi
  printf '%s %s %s %s' \
    "$(jq -r '.at[0] // 0' <<<"$window_json")" \
    "$(jq -r '.at[1] // 0' <<<"$window_json")" \
    "$(jq -r '.size[0] // 0' <<<"$window_json")" \
    "$(jq -r '.size[1] // 0' <<<"$window_json")"
}

hypr_active_window_corners() {
  # Prints: tl_x tl_y tr_x tr_y bl_x bl_y br_x br_y
  local geom x y w h
  geom=$(hypr_active_window_geom) || return 1
  read -r x y w h <<<"$geom"
  printf '%s %s %s %s %s %s %s %s' \
    "$x" \
    "$y" \
    "$((x + w))" \
    "$y" \
    "$x" \
    "$((y + h))" \
    "$((x + w))" \
    "$((y + h))"
}

hypr_active_window_address() {
  # Prints: address
  local window_json
  window_json=$(hyprctl activewindow -j 2>/dev/null) || return 1
  if [[ -z "$window_json" || "$window_json" == "null" ]]; then
    return 1
  fi
  jq -r '.address // empty' <<<"$window_json"
}

hypr_active_window_class_title() {
  # Prints: class title
  local window_json
  window_json=$(hyprctl activewindow -j 2>/dev/null) || return 1
  if [[ -z "$window_json" || "$window_json" == "null" ]]; then
    return 1
  fi
  printf '%s %s' \
    "$(jq -r '.class // empty' <<<"$window_json")" \
    "$(jq -r '.title // empty' <<<"$window_json")"
}

hypr_client_size_by_address() {
  # Usage: hypr_client_size_by_address <address>
  # Prints: width height
  local address="$1"
  local clients_json
  clients_json=$(hyprctl clients -j 2>/dev/null) || return 1
  if [[ -z "$clients_json" || "$clients_json" == "null" ]]; then
    return 1
  fi
  printf '%s %s' \
    "$(jq -r --arg addr "$address" '.[] | select(.address==$addr) | .size[0] // empty' <<<"$clients_json")" \
    "$(jq -r --arg addr "$address" '.[] | select(.address==$addr) | .size[1] // empty' <<<"$clients_json")"
}

hypr_client_pid_by_address() {
  # Usage: hypr_client_pid_by_address <address>
  # Prints: pid
  local address="$1"
  local clients_json
  clients_json=$(hyprctl clients -j 2>/dev/null) || return 1
  if [[ -z "$clients_json" || "$clients_json" == "null" ]]; then
    return 1
  fi
  jq -r --arg addr "$address" '.[] | select(.address==$addr) | .pid // empty' <<<"$clients_json"
}

hypr_client_at_by_address() {
  # Usage: hypr_client_at_by_address <address>
  # Prints: x y
  local address="$1"
  local clients_json
  clients_json=$(hyprctl clients -j 2>/dev/null) || return 1
  if [[ -z "$clients_json" || "$clients_json" == "null" ]]; then
    return 1
  fi
  printf '%s %s' \
    "$(jq -r --arg addr "$address" '.[] | select(.address==$addr) | .at[0] // empty' <<<"$clients_json")" \
    "$(jq -r --arg addr "$address" '.[] | select(.address==$addr) | .at[1] // empty' <<<"$clients_json")"
}

hypr_wait_for_client_address_by_class_or_title() {
  # Usage: hypr_wait_for_client_address_by_class_or_title <class> [title_regex] [timeout_seconds] [interval_seconds]
  local class="$1"
  local title_regex="${2:-}"
  local timeout_seconds="${3:-3}"
  local interval_seconds="${4:-0.05}"
  local elapsed=0

  if [[ -z "$class" ]]; then
    return 1
  fi

  while (( $(awk -v e="$elapsed" -v t="$timeout_seconds" 'BEGIN { print (e < t) ? 1 : 0 }') )); do
    local address
    address=$(hypr_find_client_address_by_class_or_title "$class" "$title_regex" || true)
    if [[ -n "$address" && "$address" != "null" ]]; then
      printf '%s' "$address"
      return 0
    fi
    sleep "$interval_seconds"
    elapsed=$(awk -v e="$elapsed" -v i="$interval_seconds" 'BEGIN { printf "%.2f", (e + i) }')
  done
  return 1
}

hypr_close_client_by_address() {
  # Usage: hypr_close_client_by_address <address>
  local address="$1"
  if [[ -z "$address" ]]; then
    return 1
  fi
  if ! hyprctl dispatch closewindow address:"$address" >/dev/null 2>&1; then
    log_dispatch "closewindow failed for address=${address}, trying killwindow"
    hyprctl dispatch killwindow address:"$address" >/dev/null 2>&1 || true
  fi
  local client_pid
  client_pid=$(hypr_client_pid_by_address "$address" || true)
  if [[ -n "$client_pid" ]]; then
    log_dispatch "sending SIGTERM to pid=${client_pid} for address=${address}"
    kill "$client_pid" >/dev/null 2>&1 || true
  fi
}

hypr_close_client_by_class_or_title() {
  # Usage: hypr_close_client_by_class_or_title <class> [title_regex]
  local class="$1"
  local title_regex="${2:-}"
  local address
  address=$(hypr_find_client_address_by_class_or_title "$class" "$title_regex" || true)
  if [[ -n "$address" && "$address" != "null" ]]; then
    hypr_close_client_by_address "$address"
    return 0
  fi
  return 1
}

hypr_client_exists_by_address() {
  # Usage: hypr_client_exists_by_address <address>
  # Returns: 0 if found, 1 otherwise
  local address="$1"
  local clients_json
  clients_json=$(hyprctl clients -j 2>/dev/null) || return 1
  if [[ -z "$clients_json" || "$clients_json" == "null" ]]; then
    return 1
  fi
  jq -e --arg addr "$address" '.[] | select(.address==$addr) | .address' <<<"$clients_json" >/dev/null 2>&1
}

hypr_find_client_address_by_class_or_title() {
  # Usage: hypr_find_client_address_by_class_or_title <class> [title_regex]
  # Prints: address
  local class="$1"
  local title_regex="${2:-}"
  local clients_json
  clients_json=$(hyprctl clients -j 2>/dev/null) || return 1
  if [[ -z "$clients_json" || "$clients_json" == "null" ]]; then
    return 1
  fi
  jq -r --arg cls "$class" --arg re "$title_regex" '
    .[]
    | select((.class==$cls) or (.initialClass==$cls) or (.title // "" | test(($re | select(. != "")) // $cls; "i")))
    | .address' <<<"$clients_json" | tail -n1
}

hypr_layer_namespace_for_monitor() {
  # Usage: hypr_layer_namespace_for_monitor <monitor_name> <namespace>
  # Prints: x y width height
  local monitor_name="$1"
  local namespace="$2"
  local layers_json
  layers_json=$(hyprctl layers -j 2>/dev/null) || return 1
  if [[ -z "$layers_json" || "$layers_json" == "null" ]]; then
    return 1
  fi
  printf '%s' "$layers_json" \
    | jq -r --arg mon "$monitor_name" --arg ns "$namespace" '
        .[$mon].levels // empty
        | to_entries | map(.value) | add // []
        | map(select(.namespace==$ns))
        | .[0] // empty
        | "\(.x) \(.y) \(.w) \(.h)"'
}

hypr_dispatch_movewindowpixel_exact() {
  # Usage: hypr_dispatch_movewindowpixel_exact <x> <y> <address>
  local x="$1"
  local y="$2"
  local address="$3"
  hyprctl dispatch movewindowpixel exact "$x" "$y",address:"$address" >/dev/null 2>&1
}

hypr_move_window() {
  # Usage: hypr_move_window <x> <y> [address]
  local x="$1"
  local y="$2"
  local address="${3:-}"
  if [[ -z "$address" ]]; then
    address=$(hypr_active_window_address) || return 1
  fi
  hypr_dispatch_movewindowpixel_exact "$x" "$y" "$address"
}

hypr_resize_window() {
  # Usage: hypr_resize_window <width> <height> [address]
  local width="$1"
  local height="$2"
  local address="${3:-}"
  if [[ -z "$address" ]]; then
    address=$(hypr_active_window_address) || return 1
  fi
  hyprctl dispatch resizewindowpixel exact "$width" "$height",address:"$address" >/dev/null 2>&1
}

hypr_dispatch_focuswindow_address() {
  # Usage: hypr_dispatch_focuswindow_address <address>
  local address="$1"
  hyprctl dispatch focuswindow address:"$address" >/dev/null 2>&1
}

hypr_dispatch_focuswindow_class() {
  # Usage: hypr_dispatch_focuswindow_class <class>
  local class="$1"
  hyprctl dispatch focuswindow "class:${class}" >/dev/null 2>&1
}

hypr_start_focus_watchdog() {
  # Usage: hypr_start_focus_watchdog <class> <title> [enabled] [delay_seconds] [close_address]
  # Kills the parent process after the active window is not the target for delay_seconds.
  # If title is empty, match on class only.
  local target_class="$1"
  local target_title="$2"
  local enabled="${3:-1}"
  local delay_seconds="${4:-2}"
  local close_address="${5:-}"

  if [[ "$enabled" != "1" ]]; then
    return 0
  fi

  local self_pid="$$"
  local tick_seconds=0.2
  local threshold_ticks
  threshold_ticks=$(awk -v d="$delay_seconds" -v t="$tick_seconds" 'BEGIN { if (d <= 0) d = 0.2; printf "%d", (d / t + 0.5) }')

  (
    local unfocused_ticks=0
    while sleep "$tick_seconds"; do
      local active_class active_title
      read -r active_class active_title <<<"$(hypr_active_window_class_title)" || continue
      local matches=0
      if [[ -n "$target_title" ]]; then
        if [[ "$active_class" == "$target_class" && "$active_title" == "$target_title" ]]; then
          matches=1
        fi
      else
        if [[ "$active_class" == "$target_class" ]]; then
          matches=1
        fi
      fi
      if [[ "$matches" != "1" ]]; then
        unfocused_ticks=$((unfocused_ticks + 1))
        if ((unfocused_ticks >= threshold_ticks)); then
          log_dispatch "focus lost for ${target_class}${target_title:+:${target_title}}; closing after ${delay_seconds}s"
          if [[ -n "$close_address" ]]; then
            hypr_close_client_by_address "$close_address"
            exit 0
          fi
          kill "$self_pid" 2>/dev/null
          exit 0
        fi
      else
        unfocused_ticks=0
      fi
    done
  ) &
  WATCHDOG_PID=$!
  trap '[[ -n "${WATCHDOG_PID:-}" ]] && kill "$WATCHDOG_PID" 2>/dev/null' EXIT
}

hypr_start_focus_watchdog_address() {
  # Usage: hypr_start_focus_watchdog_address <address> [enabled] [delay_seconds] [close_address]
  # Kills the parent process after the active window is not the target for delay_seconds.
  local target_address="$1"
  local enabled="${2:-1}"
  local delay_seconds="${3:-2}"
  local close_address="${4:-$target_address}"

  if [[ "$enabled" != "1" || -z "$target_address" ]]; then
    return 0
  fi

  local self_pid="$$"
  local tick_seconds=0.2
  local threshold_ticks
  threshold_ticks=$(awk -v d="$delay_seconds" -v t="$tick_seconds" 'BEGIN { if (d <= 0) d = 0.2; printf "%d", (d / t + 0.5) }')

  (
    local unfocused_ticks=0
    while sleep "$tick_seconds"; do
      local active_address
      active_address=$(hypr_active_window_address) || continue
      if [[ "$active_address" != "$target_address" ]]; then
        unfocused_ticks=$((unfocused_ticks + 1))
        if ((unfocused_ticks >= threshold_ticks)); then
          log_dispatch "focus lost for address=${target_address}; closing after ${delay_seconds}s"
          if [[ -n "$close_address" ]]; then
            hypr_close_client_by_address "$close_address"
            exit 0
          fi
          kill "$self_pid" 2>/dev/null
          exit 0
        fi
      else
        unfocused_ticks=0
      fi
    done
  ) &
  WATCHDOG_PID=$!
  trap '[[ -n "${WATCHDOG_PID:-}" ]] && kill "$WATCHDOG_PID" 2>/dev/null' EXIT
}
