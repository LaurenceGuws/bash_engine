#!/usr/bin/bash

CONFIG="$PROFILE_DIR/config"
SRC="$PROFILE_DIR/src"
SCRIPTS="$CONFIG/core/scripts.yaml"
find "$PROFILE_DIR" -type f -name "*.sh" -exec chmod +x {} +
source "$SRC/modules/utils/blog.sh"
source "$SRC/core/loaders/scripts.sh"
source "$SRC/core/profile_flow.sh"
