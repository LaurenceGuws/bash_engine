#!/usr/bin/env bash
set -euo pipefail

# Lightweight helper to keep swaync running and drive swaync-client actions.

ACTION="${1:-status}"
SWAYNC_BIN="$(command -v swaync || true)"
SWAYNC_CLIENT="$(command -v swaync-client || true)"

ensure_swaync_running() {
  if pgrep -u "$(id -u)" -x swaync >/dev/null 2>&1; then
    return 0
  fi

  if [[ -z "$SWAYNC_BIN" ]]; then
    printf 'swaync is not installed\n' >&2
    return 1
  fi

  "$SWAYNC_BIN" --reload >/dev/null 2>&1 || "$SWAYNC_BIN" >/dev/null 2>&1 &
  sleep 0.2
}

ensure_client_available() {
  if [[ -z "$SWAYNC_CLIENT" ]]; then
    printf 'swaync-client is not installed\n' >&2
    return 1
  fi
}

run_action() {
  case "$ACTION" in
    status)
      "$SWAYNC_CLIENT" -swb
      ;;
    toggle)
      "$SWAYNC_CLIENT" -t -sw
      ;;
    dismiss)
      "$SWAYNC_CLIENT" -d -sw
      ;;
    *)
      printf 'Usage: %s [status|toggle|dismiss]\n' "$0" >&2
      return 1
      ;;
  esac
}

ensure_client_available || exit 1
ensure_swaync_running || exit 1

run_action
