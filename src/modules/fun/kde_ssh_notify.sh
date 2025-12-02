### ----------------------------------------------------------
### sendher — KDE Wayland SSH notifier
### ----------------------------------------------------------

sendher() {
    local DEFAULT_USER="pup"
    local DEFAULT_HOST="pup"
    local DEFAULT_TITLE="Message from You ❤️"
    local DEFAULT_ICON="dialog-information"
    local DEFAULT_URGENCY="normal"

    local USER="$DEFAULT_USER"
    local HOST="$DEFAULT_HOST"
    local TITLE="$DEFAULT_TITLE"
    local ICON="$DEFAULT_ICON"
    local URGENCY="$DEFAULT_URGENCY"
    local ARGS=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
        --user)
            USER="$2"
            shift 2
            ;;
        --host)
            HOST="$2"
            shift 2
            ;;
        --title)
            TITLE="$2"
            shift 2
            ;;
        --icon)
            ICON="$2"
            shift 2
            ;;
        --urgency)
            URGENCY="$2"
            shift 2
            ;;
        --help)
            cat <<EOF
sendher flags:
  --user USER
  --host HOST
  --title TITLE
  --icon ICON
  --urgency {low|normal|critical}
EOF
            return 0
            ;;
        --*)
            echo "Unknown flag: $1"
            return 1
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
        esac
    done

    local MESSAGE="${ARGS[*]}"
    if [[ -z "$MESSAGE" ]]; then
        echo "Error: No message."
        return 1
    fi

    ssh "$USER@$HOST" '
PID=$(pgrep -u "$USER" plasmashell | head -n 1)
DBUS=$(tr "\0" "\n" < /proc/$PID/environ | grep DBUS_SESSION_BUS_ADDRESS | cut -d= -f2-)
export DBUS_SESSION_BUS_ADDRESS="$DBUS"

notify-send \
    --urgency="'"$URGENCY"'" \
    --icon="'"$ICON"'" \
    "'"$TITLE"'" \
    "'"$MESSAGE"'"
'

}

### ---------- COMPLETION (modeled after your spinner code) ----------
_sendher_completions() {
    local cur prev opts urgencies

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD - 1]}"

    urgencies="low normal critical"

    case "$prev" in
    --user)
        COMPREPLY=() # user-provided value
        return 0
        ;;
    --host)
        COMPREPLY=() # host value
        return 0
        ;;
    --title)
        COMPREPLY=()
        return 0
        ;;
    --icon)
        COMPREPLY=()
        return 0
        ;;
    --urgency)
        COMPREPLY=($(compgen -W "$urgencies" -- "$cur"))
        return 0
        ;;
    esac

    opts="--help --user --host --title --icon --urgency"
    COMPREPLY=($(compgen -W "$opts" -- "$cur"))
}

complete -F _sendher_completions sendher
