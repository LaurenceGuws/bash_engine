#!/usr/bin/bash

# Core initialization and timing
init_profile() {
    # Start timer
    local start_time=$(date +%s%3N)

    # Set up core variables
    export PROFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    export CONFIG="$PROFILE_DIR/config"
    export SRC="$PROFILE_DIR/src"
    export SCRIPTS="$CONFIG/scripts.yaml"

    # Make all scripts executable
    find "$PROFILE_DIR" -type f -name "*.sh" -exec chmod +x {} +

    # Source core utilities
    source "$SRC/modules/logging/blog.sh"
    source "$SRC/core/loaders/scripts.sh"

    # Load profile
    load_profile

    # Log execution time
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    echo "profile loaded in ${duration}ms."
}

init_profile 
