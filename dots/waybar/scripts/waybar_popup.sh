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
waybar_geometry_for_monitor() {
    local monitor_name="$1"
    if [[ -z "$monitor_name" ]]; then
        log "waybar_geometry_for_monitor called without monitor name"
        return 1
    fi

    local layers_json
    if ! layers_json=$(hyprctl layers -j 2>/dev/null); then
        log "hyprctl layers failed while fetching waybar geometry"
        return 1
    fi

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
        log "no waybar layer candidates found for monitor=${monitor_name}"
        return 1
    fi

    log "waybar layer candidates for ${monitor_name}: ${candidates[*]}"

    local best="${candidates[0]}"
    local bar_x bar_y bar_w bar_h
    read -r bar_x bar_y bar_w bar_h <<<"$best"
    log "waybar_geometry result monitor=${monitor_name} coords=${bar_x},${bar_y} size=${bar_w}x${bar_h}"
    printf '%s %s %s %s' "$bar_x" "$bar_y" "$bar_w" "$bar_h"
}
SCRIPT_PATH="${BASH_SOURCE[0]}"
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
    SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

popup_position() {
    local monitors_json
    monitors_json=$(hyprctl monitors -j 2>/dev/null)
    log "monitors json length=$(printf '%s' "$monitors_json" | wc -c)"
    if [[ -z "$monitors_json" ]]; then
        log "hyprctl monitors returned empty response, using fallback coords"
        printf '10 760 0 0'
        return 0
    fi

    local monitor
    monitor=$(jq -r 'map(select(.focused == true))[0] // .[0]' <<<"$monitors_json")
    local monitor_name
    monitor_name=$(jq -r '.name' <<<"$monitor")
    log "selected monitor name=$monitor_name pos=$(jq -r '.x' <<<"$monitor"),$(jq -r '.y' <<<"$monitor") size=$(jq -r '.width' <<<"$monitor")x$(jq -r '.height' <<<"$monitor")"
    if [[ -z "$monitor" || "$monitor" == "null" ]]; then
        log "no focused monitor found in monitor list, using fallback coords"
        printf '10 760 0 0'
        return 0
    fi

    local mon_x mon_y mon_w mon_h reserved_top reserved_right reserved_bottom reserved_left
    mon_x=$(jq -r '.x' <<<"$monitor")
    mon_y=$(jq -r '.y' <<<"$monitor")
    mon_w=$(jq -r '.width' <<<"$monitor")
    mon_h=$(jq -r '.height' <<<"$monitor")
    reserved_top=$(jq -r '.reserved[0] // 0' <<<"$monitor")
    reserved_right=$(jq -r '.reserved[1] // 0' <<<"$monitor")
    reserved_bottom=$(jq -r '.reserved[2] // 0' <<<"$monitor")
    reserved_left=$(jq -r '.reserved[3] // 0' <<<"$monitor")

    if [[ -z "$mon_x" || -z "$mon_y" || -z "$mon_w" || -z "$mon_h" ]]; then
        printf '10 760'
        return 0
    fi

    local margin=12
    local target_x target_y
    local placement_source="monitor-corner"
    local corner_left=$((mon_x + reserved_left + margin))
    local corner_right=$((mon_x + mon_w - reserved_right - margin))
    local corner_top=$((mon_y + reserved_top + margin))
    local corner_bottom=$((mon_y + mon_h - reserved_bottom - margin))
    local min_x=$corner_left
    local max_x=$((corner_right - POPUP_WIDTH))
    local min_y=$corner_top
    local max_y=$((corner_bottom - POPUP_HEIGHT))
    local waybar_coords
    if waybar_coords=$(waybar_geometry_for_monitor "$monitor_name"); then
        read -r bar_x bar_y bar_w bar_h <<<"$waybar_coords"
        log "waybar geometry monitor=${monitor_name} coords=${bar_x},${bar_y} size=${bar_w}x${bar_h}"
        case "$WAYBAR_POSITION" in
            top)
                target_y=$((bar_y + bar_h + margin))
                target_x=$((corner_right - POPUP_WIDTH))
                ;;
            left)
                target_x=$((bar_x + bar_w + margin))
                target_y=$corner_top
                ;;
            right)
                target_x=$((bar_x - POPUP_WIDTH - margin))
                target_y=$corner_top
                ;;
            bottom|*)
                target_y=$((bar_y - POPUP_HEIGHT - margin))
                target_x=$((corner_right - POPUP_WIDTH))
                ;;
        esac
        placement_source="waybar-corner"
    else
        case "$WAYBAR_POSITION" in
            top)
                target_x=$((corner_right - POPUP_WIDTH))
                target_y=$corner_top
                ;;
            left)
                target_x=$corner_left
                target_y=$corner_top
                ;;
            right)
                target_x=$((corner_right - POPUP_WIDTH))
                target_y=$corner_top
                ;;
            bottom|*)
                target_x=$((corner_right - POPUP_WIDTH))
                target_y=$((corner_bottom - POPUP_HEIGHT))
                ;;
        esac
    fi

    ((target_x > max_x)) && target_x=$max_x
    ((target_x < min_x)) && target_x=$min_x
    ((target_y > max_y)) && target_y=$max_y
    ((target_y < min_y)) && target_y=$min_y

    local rel_x=$((target_x - mon_x))
    local rel_y=$((target_y - mon_y))
    local pct_x=$((rel_x * 100 / mon_w))
    local pct_y=$((rel_y * 100 / mon_h))

    local offset_right=$((corner_right - target_x - POPUP_WIDTH))
    local offset_bottom=$((corner_bottom - target_y - POPUP_HEIGHT))
    log "monitor summary: name=$(jq -r '.name' <<<"$monitor") geom=${mon_x},${mon_y}+${mon_w}x${mon_h} reserved=${reserved_top},${reserved_right},${reserved_bottom},${reserved_left}"
    log "target offsets: right=${offset_right} bottom=${offset_bottom} margin=${margin} source=${placement_source}"

    log "computed popup coords: abs=${target_x},${target_y} pct=${pct_x}%,${pct_y}%"
    printf '%s %s %s %s' "$target_x" "$target_y" "$pct_x" "$pct_y"
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

move_popup_to_abs() {
    local abs_x="$1"
    local abs_y="$2"
    local timeout=0
    local address
    local clients_json

    while ((timeout < 60)); do
        clients_json=$(hyprctl clients -j 2>/dev/null) || {
            log "hyprctl clients unavailable while waiting for popup ($timeout/60)"
            sleep 0.05
            timeout=$((timeout + 1))
            continue
        }
        address=$(printf '%s' "$clients_json" \
            | jq -r '.[] | select(.class=="waybar-popup" and .title=="Waybar Popup") | .address' \
            | tail -n1)

        if [[ -n "$address" && "$address" != "null" ]]; then
            log "moving popup address=$address to abs=${abs_x},${abs_y}"
            if hyprctl dispatch movewindowpixel exact "${abs_x}" "${abs_y}",address:"$address"; then
                return 0
            fi
            log "movewindowpixel failed for address=$address"
        fi

        sleep 0.05
        timeout=$((timeout + 1))
    done

    log "timed out waiting for waybar popup address"
    return 1
}

find_existing_popup_address() {
    local clients_json
    clients_json=$(hyprctl clients -j 2>/dev/null) || {
        log "hyprctl clients failed while checking for existing popup"
        return 1
    }
    local addresses
    mapfile -t addresses < <(printf '%s' "$clients_json" \
        | jq -r '.[] | select(.class=="waybar-popup" and .title=="Waybar Popup") | .address')
    if ((${#addresses[@]})); then
        log "found waybar-popup addresses=${addresses[*]}"
        printf '%s' "${addresses[0]}"
        return 0
    fi
    log "no waybar-popup clients found"
    return 1
}

close_existing_popup() {
    local address
    if address=$(find_existing_popup_address); then
        log "closing existing waybar-popup at address=${address}"
        if ! hyprctl dispatch closewindow address:"$address" >/dev/null 2>&1; then
            log "closewindow dispatcher failed for address=${address}, forcing killwindow"
            hyprctl dispatch killwindow address:"$address" >/dev/null 2>&1
        fi
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
    dispatch_cmd="[float]"
    log "hyprctl dispatch: ${dispatch_cmd} (size handled by Hyprland window rules)"
    log "launching popup via hyprctl exec"
    hyprctl dispatch exec "$dispatch_cmd kitty -o confirm_os_window_close=0 --override font_size=${POPUP_FONT_SIZE} --detach --class waybar-popup --title 'Waybar Popup' bash -lc 'WAYBAR_POPUP_RUNNING=1 \"$SCRIPT_PATH\"'"
    if move_popup_to_abs "$abs_x" "$abs_y"; then
        log "popup manually moved to abs=${abs_x},${abs_y}"
    else
        log "failed to move popup after launch"
    fi
    hyprctl dispatch focuswindow "class:waybar-popup" >/dev/null 2>&1 || true
    exit 0
fi

start_focus_watchdog
run_popup
