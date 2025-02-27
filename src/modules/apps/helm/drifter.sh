#!/bin/bash

drifter() {
    local input_file=""
    local output_file=""
    local help_flag=false

    # Function to display help message
    usage() {
    echo -e "\033[1;34mUsage:\033[0m drifter [--help] --file <diff-file> [--output <output-diff-file>]"
    echo ""
    echo -e "\033[1;33mOptions:\033[0m"
    echo -e "  \033[1;32m--help, -h     \033[0m Show this help message and return"
    echo -e "  \033[1;32m--file, -f     \033[0m Specify the input diff file (required)"
    echo -e "  \033[1;32m--output, -o   \033[0m Save extracted diff output to a file (optional)"
    echo ""
    return 0
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            help_flag=true
            shift
            ;;
        --file|-f)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                input_file="$2"
                shift 2
            else
                echo -e "\033[1;31m[ERROR]\033[0m --file requires an argument." >&2
                usage
                return 1
            fi
            ;;
        --output|-o)
            if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                output_file="$2"
                shift 2
            else
                echo -e "\033[1;31m[ERROR]\033[0m --output requires an argument." >&2
                usage
                return 1
            fi
            ;;
        *)
            echo -e "\033[1;31m[ERROR]\033[0m Invalid option: $1" >&2
            usage
            return 1
            ;;
    esac
done

    # Display help if requested
    if [[ "$help_flag" == true ]]; then
        usage
        return 1
    fi

    # Ensure an input file is provided
    if [[ -z "$input_file" ]]; then
        echo -e "\033[1;31m[ERROR]\033[0m Missing required input file (-f option)." >&2
        usage
    fi

    # If an output file is provided, extract the diff and save it without coloring
    if [[ -n "$output_file" ]]; then
        grep '^[-+]' "$input_file" | sed 's/\\n/\n/g' | sed 's/\\"/"/g' > "$output_file"
        echo "Diff output saved to: $output_file"
        return 0
    fi

    # Otherwise, process and colorize the output for terminal display
    grep '^[-+]' "$input_file" | \
        sed 's/^-/RED_STARTS_HERE&/; s/^+/GREEN_STARTS_HERE&/; s/$/RED_ENDS_HEREGREEN_ENDS_HERE/' | \
        sed 's/\\n/\n/g' | sed 's/\\"/"/g' | \
        sed ':a;N;$!ba;s/RED_STARTS_HERE/\x1b[31m/g; s/RED_ENDS_HERE/\x1b[0m/g; s/GREEN_STARTS_HERE/\x1b[32m/g; s/GREEN_ENDS_HERE/\x1b[0m/g'
}
_drifter_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--help --file --output -h -f -o"

    case "$prev" in
        --file|-f|--output|-o)
            # Suggest files only when --file or --output is used
            COMPREPLY=( $(compgen -f -- "$cur") )
            ;;
        *)
            # Suggest options
            COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
            ;;
    esac
}

# Register the completion function for drifter
complete -F _drifter_completions drifter

