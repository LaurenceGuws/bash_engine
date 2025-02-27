#!/bin/bash

# Function to select and open a file
ec() {
    local file

    # Use the first argument as the file (if given), otherwise prompt with fzf
    if [[ -n "$1" ]]; then
        file="$CONFIG/$1"
    else
        file=$(find "$CONFIG" -maxdepth 1 -type f | fzf) || return
    fi

    # Open the selected file
    e "$file"
}

_ec_complete() {
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    # Suggest yaml files from config directory
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$(find "$CONFIG" -maxdepth 1 -type f -name "*.yaml" -exec basename {} \;)" -- "$cur"))
    fi
}

# Enable completion for 'ec'
complete -F _ec_complete ec

