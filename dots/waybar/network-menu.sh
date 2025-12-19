#!/usr/bin/env bash
set -euo pipefail

# Helper that launches a command in the background without hanging the bar.
launch() {
    setsid "$@" >/dev/null 2>&1 &
}

if command -v nmtui >/dev/null 2>&1; then
    for term in kitty alacritty foot wezterm gnome-terminal xfce4-terminal xterm; do
        if command -v "$term" >/dev/null 2>&1; then
            launch "$term" -e nmtui
            exit 0
        fi
    done
    nmtui &
    exit 0
fi

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Network" "Install nmtui or a terminal to run it for managing connections."
fi
