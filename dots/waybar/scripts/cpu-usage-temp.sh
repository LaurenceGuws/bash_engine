#!/usr/bin/env bash
set -euo pipefail

cpu_stats() {
    awk '/^cpu / {
        total = 0
        for (i = 2; i <= NF; ++i) {
            total += $i
        }
        idle = $5 + $6
        printf "%d %d\n", total, idle
        exit
    }' /proc/stat
}

read -r prev_total prev_idle < <(cpu_stats)
sleep 0.4
read -r cur_total cur_idle < <(cpu_stats)

delta_total=$((cur_total - prev_total))
delta_idle=$((cur_idle - prev_idle))
usage=0
if (( delta_total > 0 )); then
    usage=$(( (delta_total - delta_idle) * 100 / delta_total ))
    ((usage < 0)) && usage=0
    ((usage > 100)) && usage=100
fi

temperature_file=""
temperature_candidate=""
for zone in /sys/class/thermal/thermal_zone*; do
    [[ -r "$zone/temp" ]] || continue
    zone_type=$(<"$zone/type" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    if [[ "$zone_type" == *cpu* || "$zone_type" == *package* || "$zone_type" == *coretemp* ]]; then
        temperature_file="$zone/temp"
        break
    fi
    temperature_candidate="$zone/temp"
done

if [[ -z "$temperature_file" && -n "$temperature_candidate" ]]; then
    temperature_file="$temperature_candidate"
fi

mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
mem_percent=0
if [[ -n "$mem_total" && -n "$mem_available" && "$mem_total" -gt 0 ]]; then
    mem_used=$((mem_total - mem_available))
    mem_percent=$((mem_used * 100 / mem_total))
    ((mem_percent < 0)) && mem_percent=0
    ((mem_percent > 100)) && mem_percent=100
fi
temperature_text="--"
if [[ -n "$temperature_file" ]]; then
    temp_value=$(<"$temperature_file" 2>/dev/null || true)
    if [[ "$temp_value" =~ ^[0-9]+$ ]]; then
        temperature_text=$((temp_value / 1000))
    fi
else
    if command -v sensors >/dev/null 2>&1; then
        sensors_temp=$(sensors 2>/dev/null | awk '
/Tctl|Package id 0|CPU Temp|Core 0/ {
    if (match($0, /\+([0-9]+(\.[0-9]+)?)°C/, m)) {
        printf "%.0f", m[1]
        exit
    }
}
')
        if [[ -n "$sensors_temp" ]]; then
            temperature_text="$sensors_temp"
        fi
    fi
fi

icon=""
tooltip="CPU usage: ${usage}%\nCPU temp: ${temperature_text}°C\nRAM usage: ${mem_percent}%"
printf '{"text": "%s %s%%/%s°C/ %s%%", "class": "hardware-module", "tooltip": "%s"}\n' \
    "$icon" "$usage" "$temperature_text" "$mem_percent" "$tooltip"
