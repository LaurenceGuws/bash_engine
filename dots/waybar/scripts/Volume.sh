#!/bin/bash

# Simple script to control volume

# Set the amount to increment/decrement (percentage)
STEP=5

# Check if pamixer is installed
if ! command -v pamixer &> /dev/null; then
    # Just launch pavucontrol if pamixer isn't available
    if command -v pavucontrol &> /dev/null; then
        pavucontrol &
        exit 0
    else
        notify-send "Error" "Please install pamixer or pavucontrol"
        exit 1
    fi
fi

# Control functions
function volume_up() {
    pamixer -i ${STEP}
    notify_volume
}

function volume_down() {
    pamixer -d ${STEP}
    notify_volume
}

function volume_toggle() {
    pamixer -t
    if [ "$(pamixer --get-mute)" = "true" ]; then
        notify-send -t 1000 -h string:x-canonical-private-synchronous:volume "Volume: Muted" -i audio-volume-muted
    else
        notify_volume
    fi
}

function mic_toggle() {
    pamixer --default-source -t
    if [ "$(pamixer --default-source --get-mute)" = "true" ]; then
        notify-send -t 1000 -h string:x-canonical-private-synchronous:microphone "Microphone: Muted" -i microphone-sensitivity-muted
    else
        notify_mic
    fi
}

function mic_up() {
    pamixer --default-source -i ${STEP}
    notify_mic
}

function mic_down() {
    pamixer --default-source -d ${STEP}
    notify_mic
}

function notify_volume() {
    VOLUME=$(pamixer --get-volume || echo "0")
    
    if [ "${VOLUME}" -eq 0 ]; then
        ICON="audio-volume-low"
    elif [ "${VOLUME}" -lt 30 ]; then
        ICON="audio-volume-low"
    elif [ "${VOLUME}" -lt 70 ]; then
        ICON="audio-volume-medium"
    else
        ICON="audio-volume-high"
    fi
    notify-send -t 1000 -h string:x-canonical-private-synchronous:volume "Volume: ${VOLUME}%" -h int:value:${VOLUME} -i "${ICON}"
}

function notify_mic() {
    VOLUME=$(pamixer --default-source --get-volume || echo "0")
    notify-send -t 1000 -h string:x-canonical-private-synchronous:microphone "Microphone: ${VOLUME}%" -h int:value:${VOLUME} -i microphone-sensitivity-high
}

# Parse arguments
case "$1" in
  --inc)
    volume_up
    ;;
  --dec)
    volume_down
    ;;
  --toggle)
    volume_toggle
    ;;
  --toggle-mic)
    mic_toggle
    ;;
  --mic-inc)
    mic_up
    ;;
  --mic-dec)
    mic_down
    ;;
  *)
    echo "Usage: $0 [--inc|--dec|--toggle|--toggle-mic|--mic-inc|--mic-dec]"
    exit 1
    ;;
esac

exit 0 