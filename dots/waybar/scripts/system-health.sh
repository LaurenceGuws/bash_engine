#!/usr/bin/env bash
set -euo pipefail

# Compact/expanded toggleable health indicator for Waybar.
# Left click: toggle compact/expanded (handled in waybar config via --toggle + signal)
# Right click: handled in waybar config to open the popup.

STATE_FILE="/tmp/waybar_health_mode"
DEFAULT_MODE="compact"
SIGNAL_MODE="${WAYBAR_HEALTH_SIGNAL:-5}" # unused here but documented

mode="${DEFAULT_MODE}"
if [[ -f "$STATE_FILE" ]]; then
  mode=$(<"$STATE_FILE")
fi
if [[ "$mode" != "compact" && "$mode" != "expanded" ]]; then
  mode="$DEFAULT_MODE"
fi

if [[ "${1:-}" == "--toggle" ]]; then
  if [[ "$mode" == "compact" ]]; then
    echo "expanded" >"$STATE_FILE"
  else
    echo "compact" >"$STATE_FILE"
  fi
  exit 0
fi

set_state() {
  printf '%s\n' "$1" >"$STATE_FILE"
}

# CPU usage (simple delta)
cpu_stats() {
  awk '/^cpu / { idle=$5+$6; total=0; for(i=2;i<=NF;++i) total+=$i; print total, idle; exit }' /proc/stat
}
read -r prev_total prev_idle < <(cpu_stats)
sleep 0.3
read -r cur_total cur_idle < <(cpu_stats)
delta_total=$((cur_total - prev_total))
delta_idle=$((cur_idle - prev_idle))
cpu_usage=0
if (( delta_total > 0 )); then
  cpu_usage=$(( (delta_total - delta_idle) * 100 / delta_total ))
  ((cpu_usage < 0)) && cpu_usage=0
  ((cpu_usage > 100)) && cpu_usage=100
fi

# Memory usage
mem_total=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
mem_available=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
mem_usage=0
if [[ -n "$mem_total" && -n "$mem_available" && "$mem_total" -gt 0 ]]; then
  mem_used=$((mem_total - mem_available))
  mem_usage=$((mem_used * 100 / mem_total))
fi

# GPU usage (best-effort)
gpu_usage=""
if command -v nvidia-smi >/dev/null 2>&1; then
  gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d '[:space:]')
elif command -v amdgpu_top >/dev/null 2>&1; then
  gpu_usage=$(amdgpu_top -J -n 1 -s 500 2>/dev/null | jq -r '.devices[0].gpu_activity.GFX.value // .devices[0].GRBM."Graphics Pipe".value // empty' | head -n1)
fi
if [[ -n "$gpu_usage" && "$gpu_usage" =~ ^[0-9]+$ ]]; then
  ((gpu_usage>100)) && gpu_usage=100
else
  gpu_usage=""
fi

# Temperature
temp_c="--"
for zone in /sys/class/thermal/thermal_zone*; do
  [[ -r "$zone/temp" ]] || continue
  ztype=$(<"$zone/type" 2>/dev/null | tr '[:upper:]' '[:lower:]')
  if [[ "$ztype" == *cpu* || "$ztype" == *package* || "$ztype" == *coretemp* ]]; then
    raw=$(<"$zone/temp")
    [[ "$raw" =~ ^[0-9]+$ ]] && temp_c=$(( raw / 1000 )) && break
  fi
done

health_class="health-green"
severity=0

if (( cpu_usage >= 85 )) || (( mem_usage >= 90 )) || { [[ "$temp_c" != "--" ]] && (( temp_c >= 80 )); } || { [[ -n "$gpu_usage" ]] && (( gpu_usage >= 85 )); }; then
  health_class="health-red"; severity=2
elif (( cpu_usage >= 65 )) || (( mem_usage >= 75 )) || { [[ "$temp_c" != "--" ]] && (( temp_c >= 70 )); } || { [[ -n "$gpu_usage" ]] && (( gpu_usage >= 65 )); }; then
  health_class="health-yellow"; severity=1
fi

compact_text="  󰾲"
if [[ -n "$gpu_usage" ]]; then
  expanded_text=$(printf " %s%% /  %s%% / 󰾲 %s%% /  %s°C" "$cpu_usage" "$mem_usage" "$gpu_usage" "${temp_c}")
else
  expanded_text=$(printf " %s%% /  %s%% /  %s°C" "$cpu_usage" "$mem_usage" "${temp_c}")
fi
text="$compact_text"
[[ "$mode" == "expanded" ]] && text="$expanded_text"

tooltip=$(printf "CPU: %s%%\nRAM: %s%%\nTemp: %s°C" "$cpu_usage" "$mem_usage" "$temp_c")
if [[ -n "$gpu_usage" ]]; then
  tooltip=$(printf "CPU: %s%%\nRAM: %s%%\nGPU: %s%%\nTemp: %s°C" "$cpu_usage" "$mem_usage" "$gpu_usage" "$temp_c")
fi
# Escape backslashes and newlines for valid JSON
tooltip=${tooltip//\\/\\\\}
tooltip=${tooltip//$'\n'/\\n}

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$text" "$health_class" "$tooltip"
