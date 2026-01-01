#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/tmp/waybar_popup.log"
log() {
    local timestamp
    timestamp=$(date --iso-8601=seconds)
    printf '%s %s\n' "$timestamp" "$*" >> "$LOG_FILE"
}

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi
HYPR_FLOAT_PATH="$HOME/.config/hypr/scripts/hypr_float.sh"
if [[ -r "$HYPR_FLOAT_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$HYPR_FLOAT_PATH"
fi

required_tools=(kitty fzf jq hyprctl)
missing=()
for tool in "${required_tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done

if ((${#missing[@]})); then
    msg="Install ${missing[*]} to use the quick menu."
    log "missing tools: ${missing[*]}"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Waybar popup" "$msg"
    else
        printf 'Waybar popup: %s\n' "$msg" >&2
    fi
    exit 1
fi

TERMINAL=${TERMINAL:-kitty}
BROWSER=${BROWSER:-firefox}
GPU_LAUNCHER="$HOME/.config/waybar/scripts/gpu-launcher.sh"
NETWORK_MENU="$HOME/.config/waybar/scripts/network-menu.sh"
RUN_IN_TERMINAL="$HOME/.config/waybar/scripts/run-in-terminal.sh"
SWAYNC_HELPER="$HOME/.config/waybar/scripts/swaync-control.sh"
POPUP_WIDTH=400
POPUP_HEIGHT=460
POPUP_FONT_SIZE=18
WAYBAR_POSITION=${WAYBAR_POSITION:-bottom}
POPUP_MARGIN=12

LOG_FUNC=log

dispatch_helper() {
    if command -v hypr_exec >/dev/null 2>&1; then
        hypr_exec "$@"
        return $?
    fi
    log "dispatch helper command: $*"
    if hyprctl dispatch exec "$@" >/dev/null 2>&1; then
        log "hyprctl dispatch exec succeeded for helper"
        return 0
    fi
    log "hyprctl dispatch exec failed for helper, running command directly"
    if command -v setsid >/dev/null 2>&1; then
        setsid -f -- "$@" >/dev/null 2>&1 && return 0
    fi
    nohup "$@" >/dev/null 2>&1 &
}

launch_network_manager() {
    log "starting network manager helper"
    if [[ -x "$NETWORK_MENU" ]]; then
        dispatch_helper "$NETWORK_MENU"
        return 0
    fi
    log "no network manager helpers available (network_menu missing)"
    return 1
}
SCRIPT_PATH="${BASH_SOURCE[0]}"
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
    SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

popup_position() {
    if ! read -r abs_x abs_y pct_x pct_y <<<"$(hypr_popup_position_for_size "$POPUP_WIDTH" "$POPUP_HEIGHT" "$POPUP_MARGIN" "$WAYBAR_POSITION")"; then
        printf '10 760 0 0'
        return 0
    fi
    log "computed popup coords: abs=${abs_x},${abs_y} pct=${pct_x}%,${pct_y}%"
    printf '%s %s %s %s' "$abs_x" "$abs_y" "$pct_x" "$pct_y"
}

run_popup() {
    log "showing popup options"
    local options=(
        "󰀻  App launcher (Wofi)"
        "󰣇  App launcher (rich)"
        "  Window finder"
        "󰋜  Zoxide finder"
        "  Package search (pacseek)"
        "󰍹  Display settings"
        "  Toggle transparency"
        "󰕧  Toggle slideshow"
        "  Volume control"
        "  Network manager"
        "  System monitor (btop)"
        "󰾲  GPU monitor"
        "  Notifications panel"
        "  Clipboard manager"
        "  Restart Waybar"
        "  Power menu"
    )
    local selected
    selected=$(printf '%s\n' "${options[@]}" \
        | fzf --layout=reverse --border --prompt=" " --header="Waybar Popup" \
              --scroll-off=2 \
              --bind="double-click:accept" \
              --exit-0)

    if [[ -n "$selected" ]]; then
        log "selected option: $selected"
        case "$selected" in
            *"Restart Waybar")
                log "reloading Waybar"
                waybar --reload &
                ;;
            *"App launcher (rich)")
                log "launching rich app launcher"
                dispatch_helper "$RUN_IN_TERMINAL" "$HOME/.config/hypr/scripts/app-launcher.sh"
                ;;
            *"Window finder")
                log "launching window finder"
                dispatch_helper "$HOME/.config/hypr/scripts/window-finder.sh"
                ;;
            *"Zoxide finder")
                log "launching zoxide finder"
                dispatch_helper "$HOME/.config/hypr/scripts/zoxide-finder.sh"
                ;;
            *"Package search (pacseek)")
                log "launching pacseek"
                dispatch_helper "$HOME/.config/hypr/scripts/pacseek.sh"
                ;;
            *"Display settings")
                log "launching display settings"
                dispatch_helper wlrlui
                ;;
            *"Toggle transparency")
                log "toggling transparency"
                dispatch_helper "$HOME/.config/hypr/scripts/toggle-transparency.sh"
                ;;
            *"Toggle slideshow")
                log "toggling slideshow"
                dispatch_helper "$HOME/.config/hypr/scripts/toggle_slideshow.sh"
                ;;
            *"Volume control")
                log "launching volume control"
                dispatch_helper "$HOME/.config/waybar/scripts/volume-popup.sh"
                ;;
            *"GPU monitor")
                log "launching GPU monitor"
                dispatch_helper "$GPU_LAUNCHER"
                ;;
            *"System monitor (btop)")
                log "launching btop popup"
                dispatch_helper "$HOME/.config/hypr/scripts/btop-popup.sh"
                ;;
            *"Network manager")
                log "launching network manager"
                launch_network_manager
                ;;
            *"Power menu")
                log "launching power menu"
                dispatch_helper wlogout
                ;;
            *"Notifications panel")
                log "opening notification center"
                if [[ -x "$SWAYNC_HELPER" ]]; then
                    dispatch_helper "$SWAYNC_HELPER" toggle
                else
                    dispatch_helper swaync-client -t -sw
                fi
                ;;
            *"Clipboard manager")
                log "opening CopyQ"
                dispatch_helper copyq toggle
                ;;
            *"App launcher (Wofi)")
                log "launching Wofi drun"
                dispatch_helper "wofi --show drun"
                ;;
        esac
    fi
}

start_focus_watchdog() {
    if declare -F hypr_start_focus_watchdog >/dev/null 2>&1; then
        if declare -F hypr_start_focus_watchdog_address >/dev/null 2>&1; then
            local address
            address=$(hypr_find_client_address_by_class_or_title "waybar-popup" "Waybar Popup" || true)
            if [[ -n "$address" && "$address" != "null" ]]; then
                hypr_start_focus_watchdog_address "$address" "1" "2" "$address"
                return 0
            fi
        fi
        hypr_start_focus_watchdog "waybar-popup" "Waybar Popup" "1" "2"
        return 0
    fi
    local self_pid="$$"
    local unfocused_ticks=0
    local threshold_ticks=10  # 10 * 0.2s = 2s grace period
    (
        while sleep 0.2; do
            local active_json
            active_json=$(hyprctl activewindow -j 2>/dev/null) || continue
            local active_class active_title
            active_class=$(jq -r '.class // empty' <<<"$active_json")
            active_title=$(jq -r '.title // empty' <<<"$active_json")
            if [[ "$active_class" != "waybar-popup" || "$active_title" != "Waybar Popup" ]]; then
                unfocused_ticks=$((unfocused_ticks + 1))
                if ((unfocused_ticks >= threshold_ticks)); then
                    log "focus lost (>${threshold_ticks} ticks) to class=${active_class:-unset} title=${active_title:-unset}, closing popup"
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

close_existing_popup() {
    if hypr_close_client_by_class_or_title "waybar-popup" "Waybar Popup"; then
        log "closed existing waybar-popup via hyprctl"
        return 0
    fi
    local popup_pattern="kitty --class waybar-popup --title 'Waybar Popup'"
    if pgrep -f "$popup_pattern" >/dev/null; then
        log "pgrep found waybar-popup kitty instance, killing it"
        pkill -f "$popup_pattern"
        return 0
    fi
    return 1
}

if [[ -z "${WAYBAR_POPUP_RUNNING:-}" ]]; then
    if close_existing_popup; then
        exit 0
    fi
    read -r abs_x abs_y pct_x pct_y <<< "$(popup_position)"
    log "popup position -> abs=${abs_x},${abs_y} pct=${pct_x}%,${pct_y}%"
    if declare -F hypr_float >/dev/null 2>&1; then
        float_exec="kitty -o confirm_os_window_close=0 --override font_size=${POPUP_FONT_SIZE} --detach --class waybar-popup --title 'Waybar Popup' bash -lc 'WAYBAR_POPUP_RUNNING=1 \"${SCRIPT_PATH}\"'"
        log "launching popup via hypr_float"
        HYPR_FLOAT_QUIET=1
        hypr_float --normal --no-watchdog --class "waybar-popup" --title-regex "Waybar Popup" --abs-x "$abs_x" --abs-y "$abs_y" --exec "$float_exec"
        exit 0
    fi
    dispatch_cmd="[float]"
    log "hyprctl dispatch: ${dispatch_cmd} (size handled by Hyprland window rules)"
    log "launching popup via hyprctl exec"
    hyprctl dispatch exec "$dispatch_cmd kitty -o confirm_os_window_close=0 --override font_size=${POPUP_FONT_SIZE} --detach --class waybar-popup --title 'Waybar Popup' bash -lc 'WAYBAR_POPUP_RUNNING=1 \"$SCRIPT_PATH\"'"
    address=$(hypr_wait_for_client_address_by_class_or_title "waybar-popup" "Waybar Popup" "3" "0.05" || true)
    if [[ -n "$address" && "$address" != "null" ]]; then
        if hypr_dispatch_movewindowpixel_exact "$abs_x" "$abs_y" "$address"; then
            log "popup manually moved to abs=${abs_x},${abs_y}"
        else
            log "failed to move popup after launch"
        fi
    else
        log "timed out waiting for waybar popup address"
    fi
    hyprctl dispatch focuswindow "class:waybar-popup" >/dev/null 2>&1 || true
    exit 0
fi

start_focus_watchdog
run_popup
