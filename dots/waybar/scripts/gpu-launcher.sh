#!/usr/bin/env bash
set -euo pipefail

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi

POPUP_CLASS="gpu-monitor"
POPUP_TITLE="GPU Monitor"

monitor_cmd=""
if command -v nvtop >/dev/null 2>&1; then
    monitor_cmd="nvtop"
elif command -v amdgpu_top >/dev/null 2>&1; then
    monitor_cmd="amdgpu_top"
fi

if [[ -z "$monitor_cmd" ]]; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "GPU monitor" "Install nvtop or amdgpu_top to view GPU stats."
    else
        printf 'GPU monitor: install nvtop or amdgpu_top\n' >&2
    fi
    exit 1
fi

if command -v launch_kitty_popup >/dev/null 2>&1; then
    launch_kitty_popup "$POPUP_CLASS" "$POPUP_TITLE" "" "$monitor_cmd" || true
    exit 0
fi

if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exec "[float] kitty --detach --class ${POPUP_CLASS} --app-id ${POPUP_CLASS} --title '${POPUP_TITLE}' bash -lc '${monitor_cmd}'"
    exit 0
fi

if command -v run_in_terminal >/dev/null 2>&1; then
    run_in_terminal "$monitor_cmd"
    exit 0
fi

printf 'GPU monitor: no terminal available to launch %s\n' "$monitor_cmd" >&2
