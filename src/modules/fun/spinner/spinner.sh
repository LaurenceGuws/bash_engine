#!/bin/bash

spinner(){
    jbang --quiet "$PROFILE_DIR/src/modules/tui/jbang/spinner/Spinner.java" "$@"
}

_spinner_completions() {
    local cur prev opts styles speeds colors

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Updated styles list
    styles="classic dots ball arrow braille pipe clock wave matrix runner pulse"

    # Speeds available for completion
    speeds="50 75 100 150 200"

    # Available color options
    colors="red green yellow blue magenta cyan white reset"

    case "$prev" in
        --style)
            COMPREPLY=( $(compgen -W "$styles" -- "$cur") )
            return 0
            ;;
        --speed)
            COMPREPLY=( $(compgen -W "$speeds" -- "$cur") )
            return 0
            ;;
        --color)
            COMPREPLY=( $(compgen -W "$colors" -- "$cur") )
            return 0
            ;;
        --message)
            COMPREPLY=() # Let user type freely
            return 0
            ;;
    esac

    # Updated available options
    opts="--help --style --speed --message --color --multi"
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
}

complete -F _spinner_completions spinner
