#!/bin/bash

# Simple script to manage Hypridle (idle daemon for Hyprland)

# Configuration
HYPRIDLE_CONF="$HOME/.config/hypr/hypridle.conf"
HYPRIDLE_STATUS_FILE="/tmp/hypridle_status"

# Function to check if hypridle is running
is_hypridle_running() {
    pgrep -x "hypridle" >/dev/null
    return $?
}

# Function to start hypridle
start_hypridle() {
    if ! is_hypridle_running; then
        # Check if config exists
        if [ ! -f "$HYPRIDLE_CONF" ]; then
            notify-send "Error" "hypridle.conf not found at $HYPRIDLE_CONF"
            return 1
        fi
        
        # Start hypridle
        hypridle -c "$HYPRIDLE_CONF" &
        
        # Update status
        echo "enabled" > "$HYPRIDLE_STATUS_FILE"
        
        notify-send "Hypridle" "Started"
    else
        notify-send "Hypridle" "Already running"
    fi
}

# Function to stop hypridle
stop_hypridle() {
    if is_hypridle_running; then
        # Kill hypridle
        pkill -x "hypridle"
        
        # Update status
        echo "disabled" > "$HYPRIDLE_STATUS_FILE"
        
        notify-send "Hypridle" "Stopped"
    else
        notify-send "Hypridle" "Not running"
    fi
}

# Function to toggle hypridle
toggle_hypridle() {
    if is_hypridle_running; then
        stop_hypridle
    else
        start_hypridle
    fi
}

# Function to check status
status_hypridle() {
    if is_hypridle_running; then
        echo "Hypridle is running"
        notify-send "Hypridle" "Running"
    else
        echo "Hypridle is not running"
        notify-send "Hypridle" "Not running"
    fi
}

# Main
case "$1" in
    status)
        status_hypridle
        ;;
    toggle)
        toggle_hypridle
        ;;
    start)
        start_hypridle
        ;;
    stop)
        stop_hypridle
        ;;
    *)
        echo "Usage: $0 {status|toggle|start|stop}"
        exit 1
        ;;
esac

exit 0 