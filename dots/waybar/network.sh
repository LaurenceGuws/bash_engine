#!/bin/bash

# Get the primary interface
IFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')

if [ -z "$IFACE" ]; then
    echo '{"text": " No connection", "class": "disconnected"}'
    exit 0
fi

# Get initial values
R1=$(grep $IFACE /proc/net/dev | awk '{print $2}')
T1=$(grep $IFACE /proc/net/dev | awk '{print $10}')

# Sleep to measure difference
sleep 1

# Get final values
R2=$(grep $IFACE /proc/net/dev | awk '{print $2}')
T2=$(grep $IFACE /proc/net/dev | awk '{print $10}')

# Calculate speeds
SPEED_DOWN=$(( (R2 - R1) / 1024 ))
SPEED_UP=$(( (T2 - T1) / 1024 ))

# Format the output for waybar
if [ $SPEED_DOWN -gt 1024 ]; then
    SPEED_DOWN_FORMATTED="$(( SPEED_DOWN / 1024 ))M"
else
    SPEED_DOWN_FORMATTED="${SPEED_DOWN}K"
fi

if [ $SPEED_UP -gt 1024 ]; then
    SPEED_UP_FORMATTED="$(( SPEED_UP / 1024 ))M"
else
    SPEED_UP_FORMATTED="${SPEED_UP}K"
fi

# Check connection type and set connection icon
if [[ $IFACE == wl* ]]; then
    CLASS="wifi"
    CONN_ICON="󰖩"
else
    CLASS="ethernet"
    CONN_ICON="󰈀"
fi

# Download and upload icons
DOWN_ICON="󰇚"
UP_ICON="󰕒"

# Output JSON for waybar with icons
echo "{\"text\": \"${CONN_ICON}  ${DOWN_ICON} ${SPEED_DOWN_FORMATTED}  ${UP_ICON} ${SPEED_UP_FORMATTED}\", \"class\": \"${CLASS}\"}" 