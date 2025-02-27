#!/bin/bash
# Dynamically applies oh-my-posh themes using environment variables.

# Ensure THEME and THEME_DIR are set as environment variables
if [[ -z "$THEME" || -z "$THEME_DIR" ]]; then
    blog -l error "THEME or THEME_DIR environment variables are not set." 
    return
fi

# Add oh-my-posh to the PATH
export PATH=$PATH:$HOME/.local/bin

# Install oh-my-posh if not already installed
if ! command -v oh-my-posh &> /dev/null; then
    blog -l info "Installing oh-my-posh..." 
    curl -s https://ohmyposh.dev/install.sh | bash
fi

# Apply the selected theme
if [[ -f "$THEME_DIR/$THEME.omp.json" ]]; then
    blog -l info "Using theme: $THEME" 
    eval "$(oh-my-posh init bash --config "$THEME_DIR/$THEME.omp.json")"
else
    blog -l error "Theme file not found: $THEME_DIR/$THEME.omp.json" 
fi

