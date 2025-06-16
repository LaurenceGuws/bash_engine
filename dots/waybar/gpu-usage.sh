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
    # Try to get AMD GPU info via amdgpu_top (preferred)
    if command -v amdgpu_top &> /dev/null; then
        # Get JSON data from amdgpu_top
        JSON_DATA=$(amdgpu_top -J -s 1000 -n 1 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$JSON_DATA" ]; then
            # Parse GPU usage from GRBM Graphics Pipe or total GFX activity
            GPU_USAGE=$(echo "$JSON_DATA" | jq -r '.devices[0].gpu_activity.GFX.value // .devices[0].GRBM."Graphics Pipe".value // 0')
            
            # Parse memory usage (VRAM used and total)
            VRAM_USED=$(echo "$JSON_DATA" | jq -r '.devices[0].VRAM."Total VRAM Usage".value // 0')
            VRAM_TOTAL=$(echo "$JSON_DATA" | jq -r '.devices[0].VRAM."Total VRAM".value // 0')
            
            # Parse temperature (Edge temperature from sensors)
            GPU_TEMP=$(echo "$JSON_DATA" | jq -r '.devices[0].Sensors."Edge Temperature".value // .devices[0].gpu_metrics.temperature_gfx // null')
            
            # Convert temperature from millicelsius to celsius if needed
            if [ "$GPU_TEMP" != "null" ] && [ "$GPU_TEMP" -gt 1000 ]; then
                GPU_TEMP=$((GPU_TEMP / 100))
            fi
            
            # Round usage to the nearest 10 for CSS class
            CSS_CLASS=$(( (${GPU_USAGE:-0} / 10) * 10 ))
            
            # Format the output
            if [ "$GPU_TEMP" != "null" ] && [ -n "$GPU_TEMP" ]; then
                echo "{\"text\": \"${GPU_USAGE}% 󰾲  | ${VRAM_USED}MB 󰍛  | ${GPU_TEMP}°C 󰔏\", \"tooltip\": \"GPU Usage: ${GPU_USAGE}%\\nVRAM: ${VRAM_USED}/${VRAM_TOTAL} MB\\nTemperature: ${GPU_TEMP}°C\\nDriver: AMDGPU\", \"class\": \"gpu-${CSS_CLASS}\"}"
            else
                echo "{\"text\": \"${GPU_USAGE}% 󰾲  | ${VRAM_USED}MB 󰍛\", \"tooltip\": \"GPU Usage: ${GPU_USAGE}%\\nVRAM: ${VRAM_USED}/${VRAM_TOTAL} MB\\nDriver: AMDGPU\", \"class\": \"gpu-${CSS_CLASS}\"}"
            fi
        else
            # Fallback to radeontop if amdgpu_top fails
            if command -v radeontop &> /dev/null; then
                # Use radeontop with better parsing
                GPU_DATA=$(timeout 3s radeontop -d - -l 1 2>/dev/null | tail -n 1)
                if [ -n "$GPU_DATA" ]; then
                    # Extract GPU usage percentage (first number followed by %)
                    GPU_USAGE=$(echo "$GPU_DATA" | grep -oE '[0-9]+%' | head -n 1 | sed 's/%//')
                    CSS_CLASS=$(( (${GPU_USAGE:-0} / 10) * 10 ))
                    echo "{\"text\": \"${GPU_USAGE}% 󰾲\", \"tooltip\": \"GPU Usage: ${GPU_USAGE}%\\nDriver: Radeon\", \"class\": \"gpu-${CSS_CLASS}\"}"
                else
                    echo "{\"text\": \"N/A 󰾲\", \"tooltip\": \"GPU info unavailable\", \"class\": \"gpu-na\"}"
                fi
            else
                # No AMD GPU monitoring tools available
                echo "{\"text\": \"N/A 󰾲\", \"tooltip\": \"No AMD GPU monitoring tools available\\nInstall amdgpu_top or radeontop\", \"class\": \"gpu-na\"}"
            fi
        fi
    elif command -v radeontop &> /dev/null; then
        # Use radeontop as fallback
        GPU_DATA=$(timeout 3s radeontop -d - -l 1 2>/dev/null | tail -n 1)
        if [ -n "$GPU_DATA" ]; then
            # Extract GPU usage percentage (first number followed by %)
            GPU_USAGE=$(echo "$GPU_DATA" | grep -oE '[0-9]+%' | head -n 1 | sed 's/%//')
            CSS_CLASS=$(( (${GPU_USAGE:-0} / 10) * 10 ))
            echo "{\"text\": \"${GPU_USAGE}% 󰾲\", \"tooltip\": \"GPU Usage: ${GPU_USAGE}%\\nDriver: Radeon\", \"class\": \"gpu-${CSS_CLASS}\"}"
        else
            echo "{\"text\": \"N/A 󰾲\", \"tooltip\": \"GPU info unavailable\", \"class\": \"gpu-na\"}"
        fi
    else
        # No GPU info available
        echo "{\"text\": \"N/A 󰾲\", \"tooltip\": \"No GPU monitoring tools available\\nInstall nvidia-smi, amdgpu_top, or radeontop\", \"class\": \"gpu-na\"}"
    fi
fi 
