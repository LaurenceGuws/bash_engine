#!/usr/bin/env bash
set -euo pipefail

HYPR_FLOAT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_PATH="${HYPR_FLOAT_DIR}/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
  # shellcheck source=/dev/null
  . "$UTILS_PATH"
fi

hypr_float_log() {
  local timestamp
  timestamp=$(date --iso-8601=seconds)
  if [[ -n "${LOG_FILE:-}" ]]; then
    printf '%s %s\n' "$timestamp" "$*" >> "$LOG_FILE"
    if [[ "${HYPR_FLOAT_QUIET:-0}" != "1" ]]; then
      printf '%s %s\n' "$timestamp" "$*" >&2
    fi
  else
    if [[ "${HYPR_FLOAT_QUIET:-0}" != "1" ]]; then
      printf '%s %s\n' "$timestamp" "$*" >&2
    fi
  fi
}

hypr_float_usage() {
  printf 'usage: %s --exec CMD [--class CLASS] [--title-regex REGEX] [--layer-namespace NAME] [--normal|--layer] [--watchdog|--no-watchdog] [--watchdog-delay SECONDS] [--watchdog-hold] [--no-restore-focus] [--size WxH|--size-pct WxH] [--width W --height H|--width-pct P --height-pct P] [--abs-x X --abs-y Y] [tl|tr|bl|br|ct|cb|cl|cr|cc|top-left|top-right|bottom-left|bottom-right|top-center|bottom-center|center-left|center-right|center]\n' "${0##*/}" >&2
}

hypr_float() {
  LOG_FILE="${LOG_FILE:-/tmp/hypr_float.log}"
  LOG_FUNC=hypr_float_log

  local corner_input="bottom-left"
  local use_normal_window=1
  local desired_w=""
  local desired_h=""
  local desired_w_pct=""
  local desired_h_pct=""
  local focus_watchdog=0
  local focus_delay=2
  local restore_focus=0
  local watchdog_hold=0
  local focus_by_class=1
  local focus_by_class_set=0
  local exec_cmd=""
  local window_class=""
  local title_regex=""
  local class_set=0
  local title_set=0
  local layer_namespace=""
  local abs_x=""
  local abs_y=""

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --exec)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        exec_cmd="$2"
        shift 2
        ;;
      --class)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        window_class="$2"
        class_set=1
        shift 2
        ;;
      --title-regex)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        title_regex="$2"
        title_set=1
        shift 2
        ;;
      --layer-namespace)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        layer_namespace="$2"
        shift 2
        ;;
      --abs-x)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        abs_x="$2"
        shift 2
        ;;
      --abs-y)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        abs_y="$2"
        shift 2
        ;;
      --layer)
        use_normal_window=0
        shift
        ;;
      --normal|--normal-window)
        use_normal_window=1
        shift
        ;;
      --watchdog)
        focus_watchdog=1
        shift
        ;;
      --no-watchdog)
        focus_watchdog=0
        shift
        ;;
      --watchdog-delay)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        focus_delay="$2"
        shift 2
        ;;
      --watchdog-hold)
        watchdog_hold=1
        shift
        ;;
      --no-restore-focus)
        restore_focus=0
        shift
        ;;
      --restore-focus)
        restore_focus=1
        shift
        ;;
      --focus-by-address)
        focus_by_class=0
        focus_by_class_set=1
        shift
        ;;
      --size)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        if [[ "$2" =~ ^[0-9]+x[0-9]+$ ]]; then
          desired_w="${2%x*}"
          desired_h="${2#*x}"
        elif [[ "$2" =~ ^[0-9]+%x[0-9]+%$ ]]; then
          desired_w_pct="${2%x*}"
          desired_h_pct="${2#*x}"
          desired_w_pct="${desired_w_pct%\%}"
          desired_h_pct="${desired_h_pct%\%}"
        else
          printf 'invalid --size value: %s (expected WxH or W%%xH%%)\n' "$2" >&2
          return 1
        fi
        shift 2
        ;;
      --size-pct)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        if [[ "$2" =~ ^[0-9]+x[0-9]+$ ]]; then
          desired_w_pct="${2%x*}"
          desired_h_pct="${2#*x}"
        else
          printf 'invalid --size-pct value: %s (expected WxH as percent integers)\n' "$2" >&2
          return 1
        fi
        shift 2
        ;;
      --width)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        desired_w="$2"
        shift 2
        ;;
      --width-pct)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        desired_w_pct="$2"
        shift 2
        ;;
      --height)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        desired_h="$2"
        shift 2
        ;;
      --height-pct)
        if [[ "$#" -lt 2 ]]; then
          hypr_float_usage
          return 1
        fi
        desired_h_pct="$2"
        shift 2
        ;;
      tl|top-left|tr|top-right|bl|bottom-left|br|bottom-right|ct|top-center|top-centre|cb|bottom-center|bottom-centre|cl|center-left|centre-left|cr|center-right|centre-right|cc|center|centre)
        corner_input="$1"
        shift
        ;;
      *)
        hypr_float_usage
        return 1
        ;;
    esac
  done

  if [[ -z "$exec_cmd" ]]; then
    hypr_float_log "missing --exec command"
    hypr_float_usage
    return 1
  fi

  if [[ -n "$abs_x" || -n "$abs_y" ]]; then
    if [[ -z "$abs_x" || -z "$abs_y" ]]; then
      printf 'both --abs-x and --abs-y are required\n' >&2
      return 1
    fi
    if [[ ! "$abs_x" =~ ^-?[0-9]+$ || ! "$abs_y" =~ ^-?[0-9]+$ ]]; then
      printf 'invalid --abs-x/--abs-y values: %s %s\n' "$abs_x" "$abs_y" >&2
      return 1
    fi
  fi

  if [[ -n "$desired_w" || -n "$desired_h" || -n "$desired_w_pct" || -n "$desired_h_pct" ]]; then
    if [[ -n "$desired_w" || -n "$desired_h" ]]; then
      if [[ -n "$desired_w_pct" || -n "$desired_h_pct" ]]; then
        printf 'use either pixel size or percent size, not both\n' >&2
        return 1
      fi
    fi
    if [[ -z "$desired_w" || -z "$desired_h" ]]; then
      if [[ -z "$desired_w_pct" || -z "$desired_h_pct" ]]; then
        printf 'both width and height are required (use --size WxH/--size-pct WxH or --width/--height)\n' >&2
        return 1
      fi
    fi
    if [[ -n "$desired_w" || -n "$desired_h" ]]; then
      if [[ ! "$desired_w" =~ ^[0-9]+$ || ! "$desired_h" =~ ^[0-9]+$ ]]; then
        printf 'invalid size: %sx%s\n' "$desired_w" "$desired_h" >&2
        return 1
      fi
    fi
    if [[ -n "$desired_w_pct" || -n "$desired_h_pct" ]]; then
      if [[ ! "$desired_w_pct" =~ ^[0-9]+$ || ! "$desired_h_pct" =~ ^[0-9]+$ ]]; then
        printf 'invalid percent size: %sx%s\n' "$desired_w_pct" "$desired_h_pct" >&2
        return 1
      fi
      if ((desired_w_pct <= 0 || desired_w_pct > 100 || desired_h_pct <= 0 || desired_h_pct > 100)); then
        printf 'percent size must be between 1 and 100\n' >&2
        return 1
      fi
    fi
  fi

  if [[ "$focus_watchdog" == "1" && ! "$focus_delay" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    printf 'invalid --watchdog-delay value: %s\n' "$focus_delay" >&2
    return 1
  fi

  local corner_label
  case "$corner_input" in
    tl|top-left)
      corner_label="top-left"
      ;;
    tr|top-right)
      corner_label="top-right"
      ;;
    bl|bottom-left)
      corner_label="bottom-left"
      ;;
    br|bottom-right)
      corner_label="bottom-right"
      ;;
    ct|top-center|top-centre)
      corner_label="top-center"
      ;;
    cb|bottom-center|bottom-centre)
      corner_label="bottom-center"
      ;;
    cl|center-left|centre-left)
      corner_label="center-left"
      ;;
    cr|center-right|centre-right)
      corner_label="center-right"
      ;;
    cc|center|centre)
      corner_label="center"
      ;;
  esac

  hypr_float_log "starting hypr_float (${corner_label})"

  if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    hypr_float_log "missing hyprctl or jq"
    return 1
  fi

  read -r mon_name mon_x mon_y mon_w mon_h mon_scale r_top r_right r_bottom r_left <<<"$(hypr_focused_monitor_info)"
  if [[ -z "$mon_name" ]]; then
    hypr_float_log "failed to read monitor info"
    return 1
  fi
  hypr_float_log "monitor info name=${mon_name} geom=${mon_x},${mon_y}+${mon_w}x${mon_h} scale=${mon_scale} reserved=${r_top},${r_right},${r_bottom},${r_left}"

  local prev_focus
  prev_focus=$(hypr_active_window_address || true)
  hypr_float_log "previous focus address=${prev_focus:-unset}"

  local margin=12
  local corner_left corner_right corner_top corner_bottom
  read -r corner_left corner_right corner_top corner_bottom <<<"$(hypr_focused_monitor_corner_bounds_with_waybar "$margin")"
  hypr_float_log "monitor corner bounds (waybar-aware) left=${corner_left} right=${corner_right} top=${corner_top} bottom=${corner_bottom} margin=${margin}"

  if [[ -n "$desired_w_pct" && -n "$desired_h_pct" ]]; then
    local avail_w avail_h
    avail_w=$((corner_right - corner_left))
    avail_h=$((corner_bottom - corner_top))
    desired_w=$((avail_w * desired_w_pct / 100))
    desired_h=$((avail_h * desired_h_pct / 100))
    hypr_float_log "percent size ${desired_w_pct}x${desired_h_pct} -> ${desired_w}x${desired_h} (avail ${avail_w}x${avail_h})"
  fi

  local wofi_size_args=()
  if [[ -n "$desired_w" && -n "$desired_h" ]]; then
    wofi_size_args=(--width "$desired_w" --height "$desired_h")
    hypr_float_log "size override ${desired_w}x${desired_h}"
  fi

  if [[ "$use_normal_window" == "1" ]]; then
    hypr_float_log "launching command for ${corner_label}"
    hypr_exec "[float] ${exec_cmd}"
  else
    if [[ -z "$layer_namespace" ]]; then
      hypr_float_log "missing --layer-namespace for layer mode"
      return 1
    fi
    hypr_float_log "launching command for ${corner_label} (layer mode)"
    hypr_exec "[float] ${exec_cmd}"
  fi

  sleep 0.2

  if [[ "$use_normal_window" == "1" ]]; then
    local address="" win_w="" win_h=""
    local active_class active_title active_address
    read -r active_class active_title <<<"$(hypr_active_window_class_title)"
    active_address=$(hypr_active_window_address || true)
    if [[ "$class_set" == "0" && -n "$active_class" ]]; then
      window_class="$active_class"
    fi
    if [[ "$title_set" == "0" && -n "$active_title" ]]; then
      title_regex="$active_title"
    fi
    if [[ "$focus_by_class_set" == "0" ]]; then
      focus_by_class=0
    fi
    for _ in $(seq 1 20); do
      address=$(hypr_find_client_address_by_class_or_title "$window_class" "$title_regex")
      if [[ -n "$address" && "$address" != "null" ]]; then
        read -r win_w win_h <<<"$(hypr_client_size_by_address "$address")"
        break
      fi
      sleep 0.05
    done

    if [[ -n "$active_address" && "$active_address" != "null" ]]; then
      if [[ -z "$address" || "$address" == "null" || "$address" == "$prev_focus" ]]; then
        address="$active_address"
        read -r win_w win_h <<<"$(hypr_client_size_by_address "$address")"
        hypr_float_log "using active window address=${address} class=${active_class:-unset} title=${active_title:-unset}"
      fi
    fi

    if [[ -z "$address" || "$address" == "null" ]]; then
      hypr_float_log "failed to resolve window address for class=${window_class:-unset}"
      return 1
    fi
    hypr_float_log "window address=$address size=${win_w}x${win_h}"
    if [[ -n "$desired_w" && -n "$desired_h" ]]; then
      hypr_resize_window "$desired_w" "$desired_h" "$address" || true
      sleep 0.05
      read -r win_w win_h <<<"$(hypr_client_size_by_address "$address")"
      hypr_float_log "window resized to ${win_w}x${win_h}"
    fi
    if [[ "$focus_by_class" == "1" ]]; then
      hypr_dispatch_focuswindow_class "$window_class" || true
      hypr_float_log "focused window class=${window_class}"
    else
      hypr_dispatch_focuswindow_address "$address" || true
      hypr_float_log "focused window address=${address}"
    fi
    sleep 0.15
    read -r active_class active_title <<<"$(hypr_active_window_class_title)"
    active_address=$(hypr_active_window_address || true)
    hypr_float_log "after focus active class=${active_class:-unset} title=${active_title:-unset} address=${active_address:-unset}"

    if [[ "$focus_watchdog" == "1" ]]; then
      local target_class="${active_class:-$window_class}"
      if [[ "$focus_by_class" == "0" ]]; then
        hypr_float_log "starting focus watchdog for address=${address} delay=${focus_delay}s"
        hypr_start_focus_watchdog_address "$address" "1" "$focus_delay" "$address"
      else
        hypr_float_log "starting focus watchdog for class=${target_class} (class-only) delay=${focus_delay}s"
        hypr_start_focus_watchdog "$target_class" "" "1" "$focus_delay" "$address"
      fi
    fi

    local target_x target_y
    if [[ -n "$abs_x" && -n "$abs_y" ]]; then
      target_x="$abs_x"
      target_y="$abs_y"
      hypr_float_log "moving window to abs=${target_x},${target_y}"
    else
      read -r target_x target_y <<<"$(hypr_corner_target_for_size "$corner_label" "$win_w" "$win_h" "$margin")"
      hypr_float_log "moving window to ${corner_label} at=${target_x},${target_y}"
    fi
    hypr_dispatch_movewindowpixel_exact "$target_x" "$target_y" "$address"

    sleep 0.2
    local after_x after_y after_w after_h
    read -r after_x after_y <<<"$(hypr_client_at_by_address "$address")"
    read -r after_w after_h <<<"$(hypr_client_size_by_address "$address")"
    hypr_float_log "window after move at=${after_x},${after_y} size=${after_w}x${after_h}"
    hypr_dispatch_focuswindow_address "$address" || true
    sleep 0.15
    read -r active_class active_title <<<"$(hypr_active_window_class_title)"
    hypr_float_log "after move focus class=${active_class:-unset} title=${active_title:-unset}"
  else
    if [[ -n "$desired_w" && -n "$desired_h" ]]; then
      hypr_float_log "size override requested (${desired_w}x${desired_h}) but layer mode does not support resizing"
    fi
    sleep 0.2
    local layer_geom
    layer_geom=$(hypr_layer_namespace_for_monitor "$mon_name" "$layer_namespace")

    if [[ -z "$layer_geom" || "$layer_geom" == "null" ]]; then
      hypr_float_log "layer namespace not found: ${layer_namespace}"
      return 1
    fi

    local layer_x layer_y layer_w layer_h
    read -r layer_x layer_y layer_w layer_h <<<"$layer_geom"
    hypr_float_log "layer at=${layer_x},${layer_y} size=${layer_w}x${layer_h}"

    local expected_x expected_y
    read -r expected_x expected_y <<<"$(hypr_corner_target_for_size "$corner_label" "$layer_w" "$layer_h" "$margin")"
    hypr_float_log "expected ${corner_label} at=${expected_x},${expected_y} (based on layer size)"
    if [[ "$focus_watchdog" == "1" ]]; then
      hypr_float_log "watchdog requested in layer mode; skipping (no focused client target)"
    fi
  fi

  if [[ "$restore_focus" == "1" && -n "$prev_focus" && "$prev_focus" != "null" ]]; then
    hypr_dispatch_focuswindow_address "$prev_focus" || true
    hypr_float_log "restored focus to address=${prev_focus}"
  fi

  if [[ "$focus_watchdog" == "1" && "$watchdog_hold" == "1" ]]; then
    hypr_float_log "watchdog hold enabled, waiting for focus loss"
    local hold_address
    hold_address=$(hypr_find_client_address_by_class_or_title "$window_class" "$title_regex" || true)
    while true; do
      if [[ -n "$hold_address" ]] && ! hypr_client_exists_by_address "$hold_address"; then
        hypr_float_log "window closed"
        return 0
      fi
      sleep 1
    done
  fi

  if [[ "$focus_watchdog" == "1" && "$watchdog_hold" == "0" && "$use_normal_window" == "1" ]]; then
    hypr_float_log "watchdog enabled; waiting for window to close"
    local wait_address
    wait_address=$(hypr_find_client_address_by_class_or_title "$window_class" "$title_regex" || true)
    if [[ -n "$wait_address" && "$wait_address" != "null" ]]; then
      for _ in $(seq 1 300); do
        if ! hypr_client_exists_by_address "$wait_address"; then
          hypr_float_log "window closed"
          return 0
        fi
        sleep 0.1
      done
      hypr_float_log "timeout waiting for window to close"
    fi
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  hypr_float "$@"
fi
