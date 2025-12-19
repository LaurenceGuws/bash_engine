#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <command> [args...]" >&2
    exit 1
fi

cmd=("$@")

launch() {
    local term=$1
    shift
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
    exit 0
}

for term in kitty alacritty foot wezterm gnome-terminal xfce4-terminal xterm; do
    if command -v "$term" >/dev/null 2>&1; then
        launch "$term"
    fi
done

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Waybar helper" "Install kitty, alacritty, foot, or xterm to run ${cmd[0]}."
fi
