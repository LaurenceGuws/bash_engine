#!/bin/bash

# Function to select and open a file
ec() {
    local folder file

    # Use the first argument as the folder (if given), otherwise prompt with fzf
    if [[ -n "$1" ]]; then
        folder="$CONFIG/$1"
    else
        folder=$(find "$CONFIG" -mindepth 1 -maxdepth 1 -type d | fzf) || return
    fi

    # Use the second argument as the file (if given), otherwise prompt with fzf
    if [[ -n "$2" ]]; then
        file="$folder/$2"
    else
        file=$(find "$folder" -maxdepth 1 -type f | fzf) || return
    fi

    # Open the selected file
    e "$file"
}
_ec_complete() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # First argument: suggest only subdirectories of $CONFIG (not $CONFIG itself)
    if [[ $COMP_CWORD -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$(find "$CONFIG" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)" -- "$cur"))

    # Second argument: suggest only files inside the selected folder
    elif [[ $COMP_CWORD -eq 2 ]]; then
        local selected_folder="$CONFIG/$prev"
        if [[ -d "$selected_folder" ]]; then
            COMPREPLY=($(compgen -W "$(find "$selected_folder" -maxdepth 1 -type f -exec basename {} \;)" -- "$cur"))
        fi
    fi
}

# Enable completion for 'ec'
complete -F _ec_complete ec

