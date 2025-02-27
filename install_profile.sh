#!/usr/bin/bash

add_to_bashrc() {
    PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local BASHRC="$HOME/.bashrc"
    local MARKER_START="# >>> add-to-profile.sh START >>>"
    local MARKER_END="# <<< add-to-profile.sh END <<<"

    if ! grep -Fq "$MARKER_START" "$BASHRC"; then
        echo -e "\n$MARKER_START\nexport PROFILE_DIR=\"$PROFILE_DIR\"\nsource \"\$PROFILE_DIR/src/core/core_init.sh\"\n$MARKER_END" >>"$BASHRC"
        echo "Added sourcing of core_init.sh to $BASHRC"
    else
        echo "Sourcing section already exists in $BASHRC"
    fi
}

add_to_bashrc
