#!/usr/bin/env bash
set -euo pipefail

helper="$HOME/.config/waybar/run-in-terminal.sh"

if command -v nvtop >/dev/null 2>&1; then
    "$helper" nvtop
    exit 0
fi

if command -v amdgpu_top >/dev/null 2>&1; then
    "$helper" amdgpu_top
    exit 0
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "GPU monitor" "Install nvtop or amdgpu_top to view GPU stats."
fi
