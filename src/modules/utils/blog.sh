#!/usr/bin/env bash
#
# blog.sh - A single-file CLI logger with:
#   - The "blog" function
#   - Bash completion for "blog"
#   - 6 log levels: trace, debug, info, warning, error, fatal
#   - Color toggles (on by default, can be disabled with -n/--no-color)
#   - Emoji toggles (on by default, can be disabled with -e/--no-emoji)
#   - JSON output
#   - Mask mode (none|filename|location)
#   - Timestamps, custom formatting
#   - Execution of commands and logging their outputs
#   - Output mode (stdout, file, both) + optional file path
#
# Example usages:
#   blog "hello world"
#   blog -l warning "something's off"
#   blog fatal "unexpected crash"
#   blog -x "ls -la" "listing directory..."
#   blog -m filename "paths replaced by just the filename"
#   blog -o both -f /tmp/logs.txt "log to stdout and file"
#   blog --json -l debug "detailed debug information"
#   blog -e -n "disable emoji and color"
#

##############################################################################
# 1) Bash Completion for 'blog'
##############################################################################
_blog_completions() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Keep in sync with actual flags
    opts="
      -h --help
      -l --level
      -n --no-color
      -e --no-emoji
      -t --timestamp-format
      -u --no-timestamp
      -b --no-border
      -m --mask
      -j --json
      -x --exec
      -o --output
      -f --file
    "

    COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
    return 0
}

complete -F _blog_completions blog

##############################################################################
# 2) The 'blog' Function
##############################################################################
blog() {

    # Global switch off for logs
    # If BLOG_DISABLED is set to "true", the function will exit immediately.
    if [[ "${BLOG_DISABLED}" == "true" ]]; then
        return 0
    fi

    ##########################################################################
    # Default color variables (will be cleared if --no-color is used)
    ##########################################################################
    local COLOR_RESET='\033[0m'

    local COLOR_BORDER='\033[1;34m'
    local COLOR_TIMESTAMP='\033[0;36m'
    local COLOR_INFO='\033[0;32m'
    local COLOR_WARNING='\033[1;33m'
    local COLOR_ERROR='\033[0;31m'
    local COLOR_FATAL='\033[1;35m'
    local COLOR_DEBUG='\033[0;34m'
    local COLOR_TRACE='\033[0;36m'
    local COLOR_SCRIPT='\033[0;34m'
    local COLOR_MESSAGE=''  # default to terminal color

    ##########################################################################
    # Default emojis (will be cleared if --no-emoji is used)
    ##########################################################################
    local EMOJI_TRACE="🔍"
    local EMOJI_DEBUG="🐛"
    local EMOJI_INFO="ℹ️"
    local EMOJI_WARNING="⚠️"
    local EMOJI_ERROR="❌"
    local EMOJI_FATAL="💥"

    ##########################################################################
    # Defaults
    ##########################################################################
    local log_level="info"
    local timestamp_format="%Y-%m-%d %H:%M:%S"
    local use_timestamp="true"
    local use_border="true"
    local use_emoji="true"
    local use_json="false"
    local color_enabled="true"

    local mask_mode="none"         # none, filename, location
    local output_mode="stdout"     # stdout, file, both
    local output_file=""           # path to file if output_mode=file/both

    ##########################################################################
    # Usage
    ##########################################################################
    usage() {
        cat <<EOF
usage: blog [options] [message]
   or: blog [options] [log_level] [message]

available log levels:
  trace, debug, info, warning, error, fatal

options:
  -h, --help                   show this help message
  -l, --level <level>          set log level (trace, debug, info, warning, error, fatal)

  -n, --no-color               disable color
  -e, --no-emoji               disable emojis

  -t, --timestamp-format <F>   set date format (default: "%Y-%m-%d %H:%M:%S")
  -u, --no-timestamp           omit timestamps entirely
  -b, --no-border              omit the border

  -m, --mask <mode>            mask file paths; mode = 'none', 'filename', or 'location'

  -j, --json                   output logs in json format (overrides color/emoji)
  -x, --exec <command>         execute a shell command and log its output at chosen level

  -o, --output <mode>          set output mode: 'stdout' (default), 'file', or 'both'
  -f, --file <path>            file path to write logs if output mode is 'file' or 'both'

examples:
  blog "hello world"
  blog -l warning "something's off"
  blog fatal "unexpected crash"
  blog -x "ls -la" "directory listing retrieved"
  blog -m filename "paths replaced by just the filename"
  blog -o both -f /tmp/logs.txt "logs go to stdout AND file"
  blog --json -l debug "detailed debug information"
  blog -e -n "disable emoji and color"
EOF
    }

    ##########################################################################
    # Parse Arguments
    ##########################################################################
    local args=()
    local exec_command=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                return 0
                ;;
            -l|--level)
                shift
                if [[ -z "$1" ]]; then
                    echo -e "\033[0;31merror: --level requires an argument (trace, debug, info, warning, error, fatal)\033[0m"
                    return 1
                fi
                case "${1,,}" in
                    trace|debug|info|warning|error|fatal)
                        log_level="${1,,}"
                        ;;
                    *)
                        echo -e "\033[0;31merror: unknown log level: $1\033[0m"
                        return 1
                        ;;
                esac
                shift
                ;;
            -n|--no-color)
                color_enabled="false"
                shift
                ;;
            -e|--no-emoji)
                use_emoji="false"
                shift
                ;;
            -t|--timestamp-format)
                shift
                if [[ -z "$1" ]]; then
                    echo -e "\033[0;31merror: --timestamp-format requires an argument\033[0m"
                    return 1
                fi
                timestamp_format="$1"
                shift
                ;;
            -u|--no-timestamp)
                use_timestamp="false"
                shift
                ;;
            -b|--no-border)
                use_border="false"
                shift
                ;;
            -m|--mask)
                shift
                if [[ -z "$1" ]]; then
                    echo -e "\033[0;31merror: --mask requires an argument (none, filename, location)\033[0m"
                    return 1
                fi
                case "${1,,}" in
                    none|filename|location)
                        mask_mode="${1,,}"
                        ;;
                    *)
                        echo -e "\033[0;31merror: unknown mask mode: $1\033[0m"
                        return 1
                        ;;
                esac
                shift
                ;;
            -j|--json)
                use_json="true"
                shift
                ;;
            -x|--exec)
                shift
                if [[ -z "$1" ]]; then
                    echo -e "\033[0;31merror: --exec requires a command argument\033[0m"
                    return 1
                fi
                exec_command="$1"
                shift
                ;;
            -o|--output)
                shift
                if [[ -z "$1" ]]; then
                    echo -e "\033[0;31merror: --output requires an argument (stdout, file, both)\033[0m"
                    return 1
                fi
                case "${1,,}" in
                    stdout|file|both)
                        output_mode="${1,,}"
                        ;;
                    *)
                        echo -e "\033[0;31merror: unknown output mode: $1\033[0m"
                        return 1
                        ;;
                esac
                shift
                ;;
            -f|--file)
                shift
                if [[ -z "$1" ]]; then
                    echo -e "\033[0;31merror: --file requires a path argument\033[0m"
                    return 1
                fi
                output_file="$1"
                shift
                ;;
            *)
                # everything else => message
                args+=("$1")
                shift
                ;;
        esac
    done

    # Combine leftover arguments into a single message
    local message="${args[*]}"

    # If user didn't specify --level, see if first arg is a known level
    # i.e., blog debug "details..."
    if [[ -n "${args[0]}" && -z "$exec_command" ]]; then
        local maybe_level="${args[0],,}"
        case "$maybe_level" in
            trace|debug|info|warning|error|fatal)
                log_level="$maybe_level"
                # shift out the first arg from message
                args=("${args[@]:1}")
                message="${args[*]}"
                ;;
        esac
    fi

    # If no message and no exec command, show usage
    if [[ -z "$message" && -z "$exec_command" ]]; then
        usage
        return 1
    fi

    # Validate output/file combos
    if [[ "$output_mode" == "file" || "$output_mode" == "both" ]]; then
        if [[ -z "$output_file" ]]; then
            echo -e "\033[0;31merror: --file <path> is required when --output is 'file' or 'both'\033[0m"
            return 1
        fi
    fi

    ##########################################################################
    # If color_enabled=false, clear all color codes
    ##########################################################################
    if [[ "$color_enabled" == "false" ]]; then
        COLOR_RESET=''
        COLOR_BORDER=''
        COLOR_TIMESTAMP=''
        COLOR_INFO=''
        COLOR_WARNING=''
        COLOR_ERROR=''
        COLOR_FATAL=''
        COLOR_DEBUG=''
        COLOR_TRACE=''
        COLOR_SCRIPT=''
        COLOR_MESSAGE=''
    fi

    ##########################################################################
    # If user executes a command, capture & append output
    ##########################################################################
    if [[ -n "$exec_command" ]]; then
        local command_output
        command_output="$(
            {
                echo "----- [$exec_command] -----"
                eval "$exec_command" 2>&1
            } || true
        )"
        if [[ -z "$message" ]]; then
            message="$command_output"
        else
            message="$message"$'\n'"$command_output"
        fi
    fi

    ##########################################################################
    # Masking
    ##########################################################################
    mask_message() {
        local original="$1"
        local masked=""
        while IFS= read -r line; do
            local words=($line)
            local new_line=""
            for w in "${words[@]}"; do
                if [[ "$w" == */* ]]; then
                    case "$mask_mode" in
                        filename)  new_line="$new_line $(basename "$w")";;
                        location)  new_line="$new_line $(dirname  "$w")";;
                        none)      new_line="$new_line $w";;
                    esac
                else
                    new_line="$new_line $w"
                fi
            done
            # Trim leading space
            masked="$masked${new_line#" "}"$'\n'
        done <<< "$original"
        echo -n "$masked"
    }

    if [[ "$mask_mode" != "none" ]]; then
        message="$(mask_message "$message")"
    fi

    ##########################################################################
    # Prepare final output string
    ##########################################################################
    local final_output=""

    ##########################################################################
    # JSON output
    ##########################################################################
    if [[ "$use_json" == "true" ]]; then
        # single-line JSON
        local timestamp_str=""
        if [[ "$use_timestamp" == "true" ]]; then
            timestamp_str="$(date +"$timestamp_format")"
        fi

        # Remove trailing newlines
        message="$(echo -n "$message")"

        # JSON-escape the message
        local escaped_message
        if command -v jq >/dev/null 2>&1; then
            escaped_message="$(echo -n "$message" | jq -Rsa .)"
        elif command -v python3 >/dev/null 2>&1; then
            escaped_message="$(echo "$message" | python3 -c \
                'import json,sys; print(json.dumps(sys.stdin.read().rstrip("\n")))' \
                2>/dev/null)"
        else
            # minimal fallback
            escaped_message="$(echo "$message" | sed 's/"/\\"/g' | tr -d '\n')"
            escaped_message="\"${escaped_message}\""
        fi

        # Find script path
        local script_path
        if [[ "${BASH_SOURCE[1]}" == /* ]]; then
            script_path="${BASH_SOURCE[1]}"
        else
            script_path="$(pwd)/${BASH_SOURCE[1]}"
        fi

        if [[ -n "$timestamp_str" ]]; then
            final_output="{ \"timestamp\": \"${timestamp_str}\", \"level\": \"${log_level}\", \"script\": \"${script_path}\", \"message\": ${escaped_message} }"
        else
            final_output="{ \"level\": \"${log_level}\", \"script\": \"${script_path}\", \"message\": ${escaped_message} }"
        fi
    else
        # Non-JSON => multiline text
        local chosen_color=''
        local level_text=''
        local level_emoji=''

        # 1) pick color
        if [[ "$color_enabled" == "true" ]]; then
            case "$log_level" in
                trace)   chosen_color="$COLOR_TRACE";   level_text="TRACE";;
                debug)   chosen_color="$COLOR_DEBUG";   level_text="DEBUG";;
                info)    chosen_color="$COLOR_INFO";    level_text="INFO";;
                warning) chosen_color="$COLOR_WARNING"; level_text="WARNING";;
                error)   chosen_color="$COLOR_ERROR";   level_text="ERROR";;
                fatal)   chosen_color="$COLOR_FATAL";   level_text="FATAL";;
                *)       chosen_color="$COLOR_INFO";    level_text="INFO";;
            esac
        else
            # no color => uppercase level
            level_text=$(echo "$log_level" | tr '[:lower:]' '[:upper:]')
        fi

        # 2) pick emoji
        if [[ "$use_emoji" == "true" ]]; then
            case "$log_level" in
                trace)   level_emoji="$EMOJI_TRACE";;
                debug)   level_emoji="$EMOJI_DEBUG";;
                info)    level_emoji="$EMOJI_INFO";;
                warning) level_emoji="$EMOJI_WARNING";;
                error)   level_emoji="$EMOJI_ERROR";;
                fatal)   level_emoji="$EMOJI_FATAL";;
                *)       level_emoji="💬";;
            esac
        else
            level_emoji=""
        fi

        # 3) timestamp
        local timestamp_str=''
        if [[ "$use_timestamp" == "true" ]]; then
            timestamp_str="$(date +"$timestamp_format")"
        fi

        # 4) script path
        local script_path
        if [[ "${BASH_SOURCE[1]}" == /* ]]; then
            script_path="${BASH_SOURCE[1]}"
        else
            script_path="$(pwd)/${BASH_SOURCE[1]}"
        fi

        # 5) maybe top border
        if [[ "$use_border" == "true" ]]; then
            final_output+="${COLOR_BORDER}==================================================${COLOR_RESET}\n"
        fi

        # 6) first line => [timestamp] emoji LEVEL [script]
        # e.g. [2025-02-01 12:34:56] 🐛 DEBUG [script]
        if [[ -n "$timestamp_str" ]]; then
            final_output+="${COLOR_TIMESTAMP}[${timestamp_str}]${COLOR_RESET} "
            final_output+="${level_emoji} ${chosen_color}${level_text}${COLOR_RESET} "
            final_output+="${COLOR_SCRIPT}[${script_path}]${COLOR_RESET}\n"
        else
            # e.g. 🐛 DEBUG [script]
            final_output+="${level_emoji} ${chosen_color}${level_text}${COLOR_RESET} "
            final_output+="${COLOR_SCRIPT}[${script_path}]${COLOR_RESET}\n"
        fi

        # 7) the message itself, line by line
        IFS=$'\n' read -rd '' -a message_lines <<< "$message"
        for line in "${message_lines[@]}"; do
            final_output+="${COLOR_MESSAGE}${line}${COLOR_RESET}\n"
        done
    fi

    ##########################################################################
    # Output to either stdout, file, or both
    ##########################################################################
    # Trim trailing blank lines
    final_output="$(echo -en "$final_output" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')"

    case "$output_mode" in
        stdout)
            echo -e "$final_output"
            ;;
        file)
            echo -e "$final_output" >> "$output_file"
            ;;
        both)
            echo -e "$final_output"
            echo -e "$final_output" >> "$output_file"
            ;;
    esac
}

##############################################################################
# 3) Export the 'blog' Function
##############################################################################
export -f blog

