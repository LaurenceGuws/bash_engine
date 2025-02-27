#!/bin/bash

banner() {
    if [[ "$BANNER_DISABLED" != "true" ]]; then
        neofetch
    fi
}

