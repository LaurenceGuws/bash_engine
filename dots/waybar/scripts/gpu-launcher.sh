#!/usr/bin/env bash
set -euo pipefail

UTILS_PATH="$HOME/.config/hypr/scripts/utils.sh"
if [[ -r "$UTILS_PATH" ]]; then
    # shellcheck source=/dev/null
    . "$UTILS_PATH"
fi

POPUP_CLASS="gpu-monitor"
POPUP_TITLE="GPU Monitor"
ENV_FLAG="GPU_MONITOR_RUNNING"

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

SCRIPT_PATH="$0"
if command -v realpath >/dev/null 2>&1; then
    SCRIPT_PATH="$(realpath "$SCRIPT_PATH")"
elif command -v readlink >/dev/null 2>&1; then
    SCRIPT_PATH="$(readlink -f "$SCRIPT_PATH")"
fi

run_gpu_monitor() {
    "$monitor_cmd"
}

if command -v hypr_popup_run >/dev/null 2>&1; then
    hypr_popup_run "$ENV_FLAG" "$POPUP_CLASS" "$POPUP_TITLE" \
        "kitty --detach --class ${POPUP_CLASS} --app-id ${POPUP_CLASS} --title '${POPUP_TITLE}' bash -lc '${ENV_FLAG}=1 \"${SCRIPT_PATH}\"'" \
        run_gpu_monitor \
        br
    exit 0
fi

if command -v run_in_terminal >/dev/null 2>&1; then
    run_in_terminal "$monitor_cmd"
    exit 0
fi

printf 'GPU monitor: no terminal available to launch %s\n' "$monitor_cmd" >&2
