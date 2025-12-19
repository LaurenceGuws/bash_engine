#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/tmp/waybar_popup.log"
log() {
    local timestamp
    timestamp=$(date --iso-8601=seconds)
    printf '%s %s\n' "$timestamp" "$*" >> "$LOG_FILE"
}

required_tools=(kitty fzf jq hyprctl)
missing=()
for tool in "${required_tools[@]}"; do
    command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done

if ((${#missing[@]})); then
    local msg="Install ${missing[*]} to use the quick menu."
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
        printf '10 760'
        return 0
    fi

    local monitor
    monitor=$(jq -r 'map(select(.focused == true))[0] // .[0]' <<<"$monitors_json")
    log "selected monitor name=$(jq -r '.name' <<<"$monitor") pos=$(jq -r '.x' <<<"$monitor"),$(jq -r '.y' <<<"$monitor") size=$(jq -r '.width' <<<"$monitor")x$(jq -r '.height' <<<"$monitor")"
    if [[ -z "$monitor" || "$monitor" == "null" ]]; then
        log "no focused monitor found in monitor list, using fallback coords"
        printf '10 760'
        return 0
    fi

    local mon_x mon_y mon_w mon_h reserved_bottom
    mon_x=$(jq -r '.x' <<<"$monitor")
    mon_y=$(jq -r '.y' <<<"$monitor")
    mon_w=$(jq -r '.width' <<<"$monitor")
    mon_h=$(jq -r '.height' <<<"$monitor")
    reserved_bottom=$(jq -r '.reserved[3]' <<<"$monitor")
    reserved_bottom=${reserved_bottom:-0}

    if [[ -z "$mon_x" || -z "$mon_y" || -z "$mon_w" || -z "$mon_h" || -z "$reserved_bottom" ]]; then
        printf '10 760'
        return 0
    fi

    local margin=12
    local target_x=$((mon_x + mon_w - 420 - margin))
    local target_y=$((mon_y + mon_h - reserved_bottom - 260 - margin))

    if ((target_x < mon_x + margin)); then
        target_x=$((mon_x + margin))
        log "popup X clamped to margin"
    fi
    if ((target_y < mon_y + margin)); then
        target_y=$((mon_y + margin))
        log "popup Y clamped to margin"
    fi

    local rel_x=$((target_x - mon_x))
    local rel_y=$((target_y - mon_y))
    local pct_x=$((rel_x * 100 / mon_w))
    local pct_y=$((rel_y * 100 / mon_h))

    log "computed popup coords: abs=${target_x},${target_y} pct=${pct_x}%,${pct_y}%"
    printf '%s %s %s %s' "$target_x" "$target_y" "$pct_x" "$pct_y"
}

run_popup() {
    log "showing popup options"
    local options=(
        "Open web browser"
        "Open terminal"
        "Show system info"
        "Restart Waybar"
    )
    local selected
    selected=$(printf '%s\n' "${options[@]}" \
        | fzf --layout=reverse --border --prompt=" " --header="Waybar Popup" --exit-0)

    if [[ -n "$selected" ]]; then
        log "selected option: $selected"
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Waybar popup" "Selected: $selected"
        else
            printf 'Waybar popup selected: %s\n' "$selected" >&2
        fi
        case "$selected" in
            "Restart Waybar")
                log "reloading Waybar"
                waybar --reload &
                ;;
            "Open terminal")
                log "launching terminal via hyprctl dispatch exec"
                hyprctl dispatch exec kitty &
                ;;
            "Open web browser")
                log "launching browser via hyprctl dispatch exec"
                hyprctl dispatch exec "$BROWSER" &
                ;;
            "Show system info")
                log "showing system info via hyprctl dispatch exec"
                hyprctl dispatch exec "$TERMINAL" -e neofetch &
                ;;
        esac
    fi
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

if [[ -z "${WAYBAR_POPUP_RUNNING:-}" ]]; then
    if pgrep -f "kitty --class waybar-popup --title 'Waybar Popup'" >/dev/null; then
        log "existing waybar-popup detected, killing before reopening"
        pkill -f "kitty --class waybar-popup --title 'Waybar Popup'"
        exit 0
    fi
    read -r abs_x abs_y pct_x pct_y <<< "$(popup_position)"
    log "popup position -> abs=${abs_x},${abs_y} pct=${pct_x}%,${pct_y}%"
    dispatch_cmd="[float; size 420 260]"
    log "hyprctl dispatch: ${dispatch_cmd}"
    log "launching popup via hyprctl exec"
    hyprctl dispatch exec "$dispatch_cmd kitty --detach --class waybar-popup --title 'Waybar Popup' bash -lc 'WAYBAR_POPUP_RUNNING=1 \"$SCRIPT_PATH\"'"
    if move_popup_to_abs "$abs_x" "$abs_y"; then
        log "popup manually moved to abs=${abs_x},${abs_y}"
    else
        log "failed to move popup after launch"
    fi
    exit 0
fi

run_popup
