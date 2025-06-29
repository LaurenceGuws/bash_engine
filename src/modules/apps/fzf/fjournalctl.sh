#!/usr/bin/env bash

# Bash completion for fjournalctl
_fjournalctl_completions() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    opts="
      -h --help
      -u --user
      -s --system
      -b --boot
      -p --priority
      -f --follow
      -r --reverse
      -n --lines
      --since
      --until
      --unit
      --grep
    "

    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
}

complete -F _fjournalctl_completions fjournalctl
complete -F _fjournalctl_completions fjournal
complete -F _fjournalctl_completions flog

fjournalctl() {
    help() {
        cat >&2 <<EOF
Usage: fjournalctl [options]
Interactive journalctl utility using fzf for log exploration.
If no options are given, fully interactive mode is launched.

Options:
    -u, --user          : show user journal logs
    -s, --system        : show system journal logs (default)
    -b, --boot          : show logs from specific boot
    -p, --priority      : filter by priority level
    -f, --follow        : follow logs in real-time
    -r, --reverse       : show newest entries first
    -n, --lines         : number of lines to show
    --since             : show logs since specific time
    --until             : show logs until specific time
    --unit              : show logs for specific unit
    --grep              : grep pattern in logs
    --help              : show this help message

Examples:
    fjournalctl                    : interactive mode
    fjournalctl -u                 : user logs
    fjournalctl --unit             : select specific unit
    fjournalctl -p                 : filter by priority
    fjournalctl --since            : logs since specific time
EOF
    }

    # Default values
    local mode="system"
    local interactive=true
    local follow=false
    local reverse=false
    local lines=""
    local since=""
    local until=""
    local unit=""
    local priority=""
    local grep_pattern=""
    local boot=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                help
                return 0
                ;;
            -u|--user)
                mode="user"
                shift
                ;;
            -s|--system)
                mode="system"
                shift
                ;;
            -b|--boot)
                shift
                if [[ -n "$1" && "$1" != -* ]]; then
                    boot="$1"
                    shift
                else
                    boot="select"
                fi
                interactive=false
                ;;
            -p|--priority)
                shift
                if [[ -n "$1" && "$1" != -* ]]; then
                    priority="$1"
                    shift
                else
                    priority="select"
                fi
                interactive=false
                ;;
            -f|--follow)
                follow=true
                interactive=false
                shift
                ;;
            -r|--reverse)
                reverse=true
                shift
                ;;
            -n|--lines)
                shift
                if [[ -z "$1" ]]; then
                    echo "Error: --lines requires a number" >&2
                    return 1
                fi
                lines="$1"
                interactive=false
                shift
                ;;
            --since)
                shift
                if [[ -z "$1" ]]; then
                    echo "Error: --since requires a time specification" >&2
                    return 1
                fi
                since="$1"
                interactive=false
                shift
                ;;
            --until)
                shift
                if [[ -z "$1" ]]; then
                    echo "Error: --until requires a time specification" >&2
                    return 1
                fi
                until="$1"
                interactive=false
                shift
                ;;
            --unit)
                unit="select"
                interactive=false
                shift
                ;;
            --grep)
                shift
                if [[ -z "$1" ]]; then
                    echo "Error: --grep requires a pattern" >&2
                    return 1
                fi
                grep_pattern="$1"
                interactive=false
                shift
                ;;
            *)
                echo "Unknown option: $1" >&2
                help
                return 1
                ;;
        esac
    done

    # Interactive mode selection
    if [[ "$interactive" == "true" ]]; then
        interactive_menu
    else
        execute_journalctl
    fi
}

interactive_menu() {
    # Define menu entries with Nerd Font icons (requires Nerd Font in terminal)
    local opt_browse=" Browse all logs"          # nf-fa-file-text-o
    local opt_unit=" Select specific unit"        # nf-fa-wrench
    local opt_priority=" Filter by priority"      # nf-fa-warning
    local opt_boot=" Select boot session"         # nf-fa-rocket
    local opt_since=" Logs since time"            # nf-fa-calendar
    local opt_until=" Logs until time"            # nf-fa-calendar
    local opt_grep=" Search with grep"            # nf-fa-search
    local opt_user=" User logs"                   # nf-fa-user
    local opt_follow=" Follow logs (tail -f)"     # nf-fa-play
    local opt_reverse=" Reverse chronological"    # nf-fa-refresh

    local choice
    choice=$(printf '%s\n' \
        "$opt_browse" \
        "$opt_unit" \
        "$opt_priority" \
        "$opt_boot" \
        "$opt_since" \
        "$opt_until" \
        "$opt_grep" \
        "$opt_user" \
        "$opt_follow" \
        "$opt_reverse" \
        | fzf --ansi --prompt="Select journal action: " --height=50% --border)

    case "$choice" in
        "$opt_browse")
            browse_all_logs
            ;;
        "$opt_unit")
            select_unit
            ;;
        "$opt_priority")
            select_priority
            ;;
        "$opt_boot")
            select_boot
            ;;
        "$opt_since")
            select_since_time
            ;;
        "$opt_until")
            select_until_time
            ;;
        "$opt_grep")
            search_with_grep
            ;;
        "$opt_user")
            mode="user"
            browse_all_logs
            ;;
        "$opt_follow")
            follow=true
            execute_journalctl
            ;;
        "$opt_reverse")
            reverse=true
            browse_all_logs
            ;;
        *)
            return 0
            ;;
    esac
}

browse_all_logs() {
    local cmd_args=()
    
    [[ "$mode" == "user" ]] && cmd_args+=(--user)
    [[ "$reverse" == "true" ]] && cmd_args+=(-r)
    [[ -n "$lines" ]] && cmd_args+=(-n "$lines")
    [[ -n "$since" ]] && cmd_args+=(--since="$since")
    [[ -n "$until" ]] && cmd_args+=(--until="$until")
    
    journalctl "${cmd_args[@]}" --no-pager | \
        fzf --ansi --multi --bind="ctrl-r:reload(journalctl ${cmd_args[*]} --no-pager)" \
            --header="Press CTRL-R to reload, TAB to select multiple lines" \
            --preview="echo {}" --preview-window=up:3:wrap
}

select_unit() {
    local selected_unit
    local unit_cmd=(systemctl)
    
    [[ "$mode" == "user" ]] && unit_cmd+=(--user)
    
    selected_unit=$("${unit_cmd[@]}" list-units --no-legend --type=service | \
        awk '{print $1}' | \
        fzf --prompt="Select unit: " --preview="systemctl ${mode} status {} --no-pager --lines=10")
    
    if [[ -n "$selected_unit" ]]; then
        unit="$selected_unit"
        execute_journalctl
    fi
}

select_priority() {
    local selected_priority
    selected_priority=$(printf '%s\n' \
        "0 - Emergency" \
        "1 - Alert" \
        "2 - Critical" \
        "3 - Error" \
        "4 - Warning" \
        "5 - Notice" \
        "6 - Info" \
        "7 - Debug" \
        | fzf --prompt="Select priority level: ")
    
    if [[ -n "$selected_priority" ]]; then
        priority="${selected_priority:0:1}"
        execute_journalctl
    fi
}

select_boot() {
    local selected_boot
    selected_boot=$(journalctl --list-boots --no-pager | \
        fzf --prompt="Select boot session: " --preview="journalctl -b {} --no-pager --lines=20")
    
    if [[ -n "$selected_boot" ]]; then
        boot=$(echo "$selected_boot" | awk '{print $1}')
        execute_journalctl
    fi
}

select_since_time() {
    local time_choice
    time_choice=$(printf '%s\n' \
        "1 hour ago" \
        "2 hours ago" \
        "6 hours ago" \
        "12 hours ago" \
        "1 day ago" \
        "2 days ago" \
        "1 week ago" \
        "Custom..." \
        | fzf --prompt="Select time period: ")
    
    if [[ "$time_choice" == "Custom..." ]]; then
        read -rp "Enter custom time (e.g., '2023-01-01 10:00:00'): " since
    else
        since="$time_choice"
    fi
    
    if [[ -n "$since" ]]; then
        execute_journalctl
    fi
}

select_until_time() {
    local time_choice
    time_choice=$(printf '%s\n' \
        "1 hour ago" \
        "2 hours ago" \
        "6 hours ago" \
        "12 hours ago" \
        "1 day ago" \
        "2 days ago" \
        "1 week ago" \
        "Custom..." \
        | fzf --prompt="Select until time: ")
    
    if [[ "$time_choice" == "Custom..." ]]; then
        read -rp "Enter custom time (e.g., '2023-01-01 10:00:00'): " until
    else
        until="$time_choice"
    fi
    
    if [[ -n "$until" ]]; then
        execute_journalctl
    fi
}

search_with_grep() {
    read -rp "Enter search pattern: " grep_pattern
    if [[ -n "$grep_pattern" ]]; then
        execute_journalctl
    fi
}

execute_journalctl() {
    local cmd_args=()
    
    # Build journalctl command
    [[ "$mode" == "user" ]] && cmd_args+=(--user)
    [[ "$follow" == "true" ]] && cmd_args+=(-f)
    [[ "$reverse" == "true" ]] && cmd_args+=(-r)
    [[ -n "$lines" ]] && cmd_args+=(-n "$lines")
    [[ -n "$since" ]] && cmd_args+=(--since="$since")
    [[ -n "$until" ]] && cmd_args+=(--until="$until")
    [[ -n "$unit" ]] && cmd_args+=(-u "$unit")
    [[ -n "$priority" ]] && cmd_args+=(-p "$priority")
    [[ -n "$boot" ]] && cmd_args+=(-b "$boot")
    
    # Add no-pager unless following
    [[ "$follow" != "true" ]] && cmd_args+=(--no-pager)
    
    # Execute command
    if [[ -n "$grep_pattern" ]]; then
        journalctl "${cmd_args[@]}" | grep --color=always "$grep_pattern" | less -R
    else
        journalctl "${cmd_args[@]}"
    fi
}

# Create shorter aliases
fjournal() { fjournalctl "$@"; }
flog() { fjournalctl "$@"; }

# Export the functions
export -f fjournalctl fjournal flog 