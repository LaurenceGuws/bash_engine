#!/bin/bash

# Simple script to provide Cava audio visualizer output for Waybar

# Configuration
CAVA_CONFIG="$HOME/.config/cava/config"
CAVA_TEMP_CONFIG="/tmp/cava_waybar.config"
BARS=10  # Number of bars to display

# Check if cava is installed
if ! command -v cava >/dev/null 2>&1; then
    echo "cava not installed"
    exit 1
fi

# Create temporary cava config if it doesn't exist
if [ ! -f "$CAVA_TEMP_CONFIG" ]; then
    cat > "$CAVA_TEMP_CONFIG" << EOL
[general]
bars = $BARS
framerate = 60
sensitivity = 100
autosens = 1
overshoot = 0
lower_cutoff_freq = 50
higher_cutoff_freq = 10000

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOL
fi

# Function to generate the Cava output for Waybar
# This outputs bars as unicode characters that can be shown in Waybar
cava_output() {
    # Run cava with our temporary config
    cava -p "$CAVA_TEMP_CONFIG" | while read -r line; do
        # Convert raw cava output to unicode bars
        output=""
        for i in $(echo "$line" | grep -o "."); do
            case "$i" in
                "0") bar="▁" ;;
                "1") bar="▂" ;;
                "2") bar="▃" ;;
                "3") bar="▄" ;;
                "4") bar="▅" ;;
                "5") bar="▆" ;;
                "6") bar="▇" ;;
                "7") bar="█" ;;
                *) bar=" " ;;
            esac
            output="${output}${bar}"
        done
        
        # Output in a format that Waybar can use
        echo "{\"text\":\"$output\"}"
    done
}

# Main
cava_output

exit 0 