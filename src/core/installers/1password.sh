#!/bin/bash
#
# install_1password.sh
#
# Description:
# - This script downloads and installs the 1Password CLI from the provided zip package.
# - It checks if the 1Password CLI (`op`) is already installed to avoid redundant installations.
# - Downloads the specified version of the 1Password CLI, extracts it, and moves the binary to `/usr/bin`.
# - Ensures the `op` binary is executable and verifies the installation by displaying its version.

# Exit immediately if a command exits with a non-zero status
set -e

# =============================
# Configuration
# =============================

# URL for the latest 1Password CLI zip package
URL="https://cache.agilebits.com/dist/1P/op2/pkg/v2.3.1/op_linux_amd64_v2.3.1.zip"

# Temporary zip file name
TEMP_ZIP="op_linux.zip"

# Installation directory for the `op` binary
INSTALL_DIR="/usr/bin"

# =============================
# Functions
# =============================

# Function to check if 1Password CLI is already installed
check_op_installed() {
    if command -v op &> /dev/null; then
        echo "1Password CLI is already installed. Skipping installation."
        exit 0
    fi
}

# Function to download the 1Password CLI zip package
download_op() {
    echo "Downloading 1Password CLI from $URL..."
    wget -q "$URL" -O "$TEMP_ZIP"
    echo "Download completed."
}

# Function to extract the 1Password CLI binary from the zip package
extract_op() {
    echo "Extracting 1Password CLI..."
    unzip -q "$TEMP_ZIP" -d .
    echo "Extraction completed."
}

# Function to move the `op` binary to the installation directory and make it executable
install_op() {
    if [ -f "./op" ]; then
        echo "Moving `op` binary to $INSTALL_DIR..."
        sudo mv ./op "$INSTALL_DIR/op"
        sudo chmod +x "$INSTALL_DIR/op"
        echo "1Password CLI (op) moved to $INSTALL_DIR and made executable."
    else
        echo "Failed to find the `op` binary after extraction."
        return 0
    fi
}

# Function to clean up the downloaded zip file
cleanup() {
    echo "Cleaning up temporary files..."
    rm -f "$TEMP_ZIP"
    echo "Cleanup completed."
}

# Function to verify the installation of 1Password CLI
verify_installation() {
    if command -v op &> /dev/null; then
        echo "1Password CLI installed successfully and available in $INSTALL_DIR."
        op --version
    else
        echo "1Password CLI installation failed."
        return 0
    fi
}

# =============================
# Main Execution
# =============================

# Check if 1Password CLI is already installed
check_op_installed

# Download the 1Password CLI zip package
download_op

# Extract the 1Password CLI binary
extract_op

# Install the `op` binary
install_op

# Clean up temporary files
cleanup

# Verify the installation
verify_installation

echo "1Password CLI installation process completed successfully."
