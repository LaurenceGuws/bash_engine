#!/bin/bash

# Function to determine the system architecture
get_architecture() {
    case "$(uname -m)" in
        x86_64) echo "amd64" ;;
        aarch64 | arm64) echo "arm64" ;;
        *) echo "unsupported" ;;
    esac
}

# Function to determine the operating system
get_os() {
    uname -s | tr '[:upper:]' '[:lower:]'
}

# Ensure script is run as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (use sudo)."
    exit 1
fi

# Determine system architecture and OS
ARCH=$(get_architecture)
OS=$(get_os)

if [[ "$ARCH" == "unsupported" ]]; then
    echo "Unsupported architecture: $(uname -m). Cannot install yq."
    exit 1
fi

# Define yq binary URL
YQ_BINARY="yq_${OS}_${ARCH}"
YQ_URL="https://github.com/mikefarah/yq/releases/latest/download/${YQ_BINARY}"

echo "Downloading yq from $YQ_URL..."

# Download yq and install it properly
wget "$YQ_URL" -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq

if command -v yq > /dev/null; then
    echo "yq installed successfully."
else
    echo "yq installation failed."
    exit 1
fi
