#!/bin/bash

timer() {
    
    # Start timer
    local start_time=$(date +%s%3N)
    source "$PROFILE_DIR/src/core/profile_flow.sh"
    source "$PROFILE_DIR/src/core/add_core.sh"

    profile_flow

    # Log the execution time
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    echo "profile loaded in ${duration}ms."
}

timer