#!/bin/sh
DEFAULT_SOCKET="/tmp/nvidesocket"
SOCKET="${NVIM:-$DEFAULT_SOCKET}"

if [ -z "$NVIM" ]; then
  # Liveness check for the shared Neovide instance.
  if [ -S "$SOCKET" ] && nc -U "$SOCKET" -w 1 </dev/null 2>/dev/null; then
    :
  else
    rm -f "$SOCKET" 2>/dev/null
    nvim --listen "$SOCKET" --headless >/dev/null 2>&1 &
    sleep 0.1
    neovide --server "$SOCKET" >/dev/null 2>&1 &
    sleep 0.2
  fi
fi

# Handle +LINE filename rewrites so it opens as a buffer, not in a float
for arg in "$@"; do
  case "$arg" in
    +*)
      LINE="${arg#+}"
      SEND_LINE_CMD=":<cmd>call cursor(${LINE},1)\n"
      ;;
    *)
      FILE="$arg"
      ;;
  esac
done

if [ -n "$FILE" ]; then
  nvim --server "$SOCKET" --remote "$FILE" >/dev/null 2>&1
fi

if [ -n "$SEND_LINE_CMD" ]; then
  nvim --server "$SOCKET" --remote-send "$SEND_LINE_CMD" >/dev/null 2>&1
fi
