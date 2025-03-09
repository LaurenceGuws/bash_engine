#!/bin/bash

# Simple script to launch wlogout with optional arguments

# You can customize this with additional options
WLOGOUT_ARGS="-p layer-shell"

# Check if wlogout is installed
if ! command -v wlogout >/dev/null 2>&1; then
    notify-send "Error" "wlogout is not installed"
    exit 1
fi

# Launch wlogout
wlogout ${WLOGOUT_ARGS}

exit 0 