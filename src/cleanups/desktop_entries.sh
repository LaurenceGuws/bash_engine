#!/bin/bash

desktop_cleaner() {

    dirs=("/usr/share/applications" "$HOME/.local/share/applications")

    for dir in "${dirs[@]}"; do
        find "$dir" -name '*.desktop' | while read -r desktop_file; do
            # Extract the Exec line
            exec_line=$(grep -E '^Exec=' "$desktop_file" | head -n1 | cut -d= -f2)
            # Extract the command (first word)
            cmd=$(echo "$exec_line" | awk '{print $1}')
            # Skip if cmd is empty
            [[ -z "$cmd" ]] && continue
            # Check if command exists
            if ! command -v "$cmd" &>/dev/null; then
                echo "Stale .desktop file: $desktop_file (missing command: $cmd)"
            fi
        done
    done

}
