#!/usr/bin/env bash
set -euo pipefail

SELF="$(realpath "$0")"

### ────────────────── Scratch-pad wrapper ──────────────────
if [[ -z "${RECORD_SCR_POPUP:-}" ]]; then
  hyprctl dispatch exec \
    "[float; size 800 400] kitty --class record-popup \
     --title 'Screen Recorder' bash -c 'RECORD_SCR_POPUP=1 \"$SELF\"'"
  exit 0
fi

### ────────────────── Stop if already recording ────────────
if pgrep -x wf-recorder &>/dev/null; then
  pkill -INT -x wf-recorder
  LAST=$(< /tmp/recording.txt 2>/dev/null || true)
  notify-send "🎥 Recording stopped" "${LAST:-Unknown file}"
  [[ -f $LAST ]] && wl-copy < "$LAST"
  exit 0
fi

### ────────────────── Discover outputs ─────────────────────
MON_JSON=$(hyprctl -j monitors) || { notify-send "Hyprctl error"; exit 1; }
mapfile -t MONITORS < <(jq -r '.[].name' <<<"$MON_JSON")

### ────────────────── Interactive menus (full height) ──────
TARGET=$(printf '%s\n' region "${MONITORS[@]}" "all outputs" |
         fzf --prompt="󰄀 Target ▶ " --height=100% --border) || exit 0

MODE=$(printf '%s\n' "video only" "video + audio" |
       fzf --prompt="󰄀 Audio ▶ " --height=100% --border) || exit 0

EXTRA=$(printf '%s\n' \
          "no-damage (--no-damage)" \
          "overwrite (-y)" |
        fzf --multi --prompt="󰄀 Options ▶ " --height=100% --border) || true

### ────────────────── Build wf-recorder args ───────────────
ARGS=()
[[ $MODE == *audio* ]] && ARGS+=( -a )

case "$TARGET" in
  region)             ARGS+=( -g "$(slurp)" ) ;;
  "all outputs")      ;;                        # whole layout
  *)                  ARGS+=( -o "$TARGET" ) ;;
esac

[[ $EXTRA == *no-damage* ]] && ARGS+=( --no-damage )
[[ $EXTRA == *overwrite*  ]] && ARGS+=( -y )

### ────────────────── Output file ──────────────────────────
OUTDIR="$HOME/Videos"
mkdir -p "$OUTDIR"
OUT="$OUTDIR/recording_$(date +%F_%H-%M-%S).mp4"
echo "$OUT" > /tmp/recording.txt

### ────────────────── Start recording ──────────────────────
notify-send "🎥 Recording started" "$TARGET | $MODE"
wf-recorder "${ARGS[@]}" -f "$OUT" &>/dev/null
