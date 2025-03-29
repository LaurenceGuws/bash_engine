#!/bin/bash

# Check if nvidia-smi is available
if command -v nvidia-smi &> /dev/null; then
    # Get GPU usage and memory info
    GPU_USAGE=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)
    GPU_MEMORY=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
    GPU_TOTAL_MEMORY=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits)
    GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    
    # Round to the nearest 10 for CSS class
    CSS_CLASS=$(( ($GPU_USAGE / 10) * 10 ))
    
    # Format the output with different icons - match waybar style
    echo "{\"text\": \"${GPU_USAGE}% 󰾲  | ${GPU_MEMORY}MB 󰍛  | ${GPU_TEMP}°C 󰔏\", \"tooltip\": \"GPU Usage: ${GPU_USAGE}%\\nMemory: ${GPU_MEMORY}/${GPU_TOTAL_MEMORY} MB\\nTemperature: ${GPU_TEMP}°C\", \"class\": \"gpu-${CSS_CLASS}\"}"
else
    # Try to get AMD GPU info via radeontop
    if command -v radeontop &> /dev/null; then
        GPU_USAGE=$(radeontop -d - -l 1 | grep gpu | awk '{print $2}' | sed 's/%//')
        CSS_CLASS=$(( ($GPU_USAGE / 10) * 10 ))
        echo "{\"text\": \"${GPU_USAGE}% 󰾲\", \"tooltip\": \"GPU Usage: ${GPU_USAGE}%\", \"class\": \"gpu-${CSS_CLASS}\"}"
    else
        # No GPU info available
        echo "{\"text\": \"N/A 󰾲\", \"tooltip\": \"No GPU info available\", \"class\": \"gpu-na\"}"
    fi
fi 
