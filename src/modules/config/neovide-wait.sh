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

# Open diffs in a single shared instance
FILE1=""
FILE2=""
COUNT=0
for arg in "$@"; do
  case "$arg" in
    +*) ;;
    *)
      COUNT=$((COUNT + 1))
      if [ "$COUNT" -eq 1 ]; then
        FILE1="$arg"
      elif [ "$COUNT" -eq 2 ]; then
        FILE2="$arg"
      fi
      ;;
  esac
done

escape_squote() {
  printf "%s" "$1" | sed "s/'/'\\\\''/g"
}

if [ "$COUNT" -eq 1 ]; then
  nvim --server "$SOCKET" --remote "$FILE1" >/dev/null 2>&1
elif [ "$COUNT" -ge 2 ]; then
  E1="$(escape_squote "$FILE1")"
  E2="$(escape_squote "$FILE2")"
  nvim --server "$SOCKET" --remote-send ":tabnew | edit '$E1' | vert diffsplit '$E2' | wincmd =\n" >/dev/null 2>&1
fi
