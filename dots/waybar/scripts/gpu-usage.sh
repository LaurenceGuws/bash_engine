#!/usr/bin/env bash
set -euo pipefail

LAST_ERROR=""

output() {
    local usage=$1
    local temp=$2
    local mem_percent=$3
    local tooltip=$4
    local css_class=$5
    local icon="󰾲"
    local alt_text
    alt_text=$(printf "%s %s%%/%s°C/ %s%%" "$icon" "$usage" "$temp" "$mem_percent")
    printf '{"text": "%s", "alt": "%s", "tooltip": "%s", "class": "gpu-%s"}\n' \
        "$icon" "$alt_text" "$tooltip" "$css_class"
}

percent() {
    local num=$1
    local den=$2
    if [[ -n "$den" ]] && (( den > 0 )); then
        printf '%d' $(( num * 100 / den ))
    else
        printf '0'
    fi
}

handle_nvidia() {
    local data
    if ! data=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu --format=csv,noheader,nounits 2>&1); then
        LAST_ERROR="nvidia-smi: $(head -n1 <<< "$data")"
        return 1
    fi
    IFS=',' read -r usage mem_used mem_total temp <<< "$data"
    usage=${usage//[[:space:]]/}
    mem_used=${mem_used//[[:space:]]/}
    mem_total=${mem_total//[[:space:]]/}
    temp=${temp//[[:space:]]/}

    if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
        return 1
    fi
    [[ "$mem_used" =~ ^[0-9]+$ ]] || mem_used=0
    [[ "$mem_total" =~ ^[0-9]+$ ]] || mem_total=0
    if [[ ! "$temp" =~ ^[0-9]+$ ]]; then
        temp="--"
    fi

    local css_class=$(( (usage / 10) * 10 ))
    local mem_percent
    mem_percent=$(percent "$mem_used" "$mem_total")
    local tooltip="GPU Usage: ${usage}%\nVRAM: ${mem_used}/${mem_total} MB\nTemperature: ${temp}°C"
    output "$usage" "$temp" "$mem_percent" "$tooltip" "$css_class"
}

handle_amdgpu() {
    local json
    json=$(amdgpu_top -J -s 1000 -n 1 2>/dev/null) || return 1
    local usage
    usage=$(echo "$json" | jq -r '.devices[0].gpu_activity.GFX.value // .devices[0].GRBM."Graphics Pipe".value // 0')
    local vram_used
    vram_used=$(echo "$json" | jq -r '.devices[0].VRAM."Total VRAM Usage".value // 0')
    local vram_total
    vram_total=$(echo "$json" | jq -r '.devices[0].VRAM."Total VRAM".value // 0')
    local temp
    temp=$(echo "$json" | jq -r '.devices[0].Sensors."Edge Temperature".value // .devices[0].gpu_metrics.temperature_gfx // 0')
    if [[ "$temp" -gt 1000 ]]; then
        temp=$(( temp / 100 ))
    fi

    local css_class=$(( (usage / 10) * 10 ))
    local mem_percent
    mem_percent=$(percent "$vram_used" "$vram_total")
    local tooltip="GPU Usage: ${usage}%\nVRAM: ${vram_used}/${vram_total} MB\nTemperature: ${temp}°C\nDriver: AMDGPU"
    output "$usage" "$temp" "$mem_percent" "$tooltip" "$css_class"
}

handle_radeon() {
    local data
    data=$(timeout 3s radeontop -d - -l 1 2>/dev/null | tail -n 1)
    if [[ -n "$data" ]]; then
        local usage
        usage=$(echo "$data" | grep -oE '[0-9]+%' | head -n1 | tr -d '%')
        local css_class=$(( (usage / 10) * 10 ))
        local tooltip="GPU Usage: ${usage}%\nDriver: Radeon"
        output "$usage" "--" "0" "$tooltip" "$css_class"
    else
        printf '{"text": "󰾲", "alt": "N/A 󰾲", "tooltip": "GPU info unavailable", "class": "gpu-na"}\n'
    fi
}

if command -v nvidia-smi >/dev/null 2>&1 && handle_nvidia; then
    exit 0
fi

if command -v amdgpu_top >/dev/null 2>&1 && handle_amdgpu; then
    exit 0
fi

if command -v amdgpu_top >/dev/null 2>&1; then
    handle_radeon
    exit 0
fi

if command -v radeontop >/dev/null 2>&1; then
    handle_radeon
    exit 0
fi

if [[ -n "$LAST_ERROR" ]]; then
    printf '{"text": "󰾲", "alt": "N/A 󰾲", "tooltip": "%s", "class": "gpu-na"}\n' "$LAST_ERROR"
else
    printf '{"text": "󰾲", "alt": "N/A 󰾲", "tooltip": "No GPU monitoring tools available\nInstall nvidia-smi, amdgpu_top, or radeontop", "class": "gpu-na"}\n'
fi
