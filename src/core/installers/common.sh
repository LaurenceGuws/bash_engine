#!/bin/bash
#
# dependencies.sh
#
# Description:
# - This script installs or updates essential packages required for the project.
# - It checks if each package is installed and up-to-date.
# - Utilizes `nala` if available for package management; otherwise, falls back to `apt-get`.
# - Cleans up package lists after installation to save space.

# Exit immediately if a command exits with a non-zero status
set -e

# =============================
# Configuration
# =============================

# List of packages to install or update
PACKAGES=("nala" "curl" "gnupg" "unzip" "jq" "bat" "git" "kitty" "wget")

# =============================
# Functions
# =============================

# Function to check if a package is installed
# Arguments:
#   $1 - Package name
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to install a package using the specified package manager
# Arguments:
#   $1 - Package name
install_package() {
    local package="$1"
    echo "Installing $package..."
    $INSTALL_CMD "$package"
}

# Function to update the package manager
update_package_manager() {
    echo "Updating package manager..."
    apt-get update -qq
}

# Function to determine which package manager to use
determine_package_manager() {
    if is_installed "nala"; then
        echo "Nala is installed. Using nala for package installation and updates..."
        INSTALL_CMD="nala install -y"
    else
        echo "Nala is not installed. Using apt-get for package installation and updates..."
        INSTALL_CMD="apt-get install -y --no-install-recommends"
    fi
}

# Function to install or update packages
install_or_update_packages() {
    for package in "${PACKAGES[@]}"; do
        if is_installed "$package"; then
            if [[ "$INSTALL_CMD" == *"nala"* ]]; then
                # Check if the package is already up-to-date using nala
                if nala show "$package" | grep -q "is already at the latest version"; then
                    echo "$package is already up-to-date. Skipping."
                else
                    echo "$package is installed but outdated. Updating..."
                    install_package "$package"
                fi
            else
                # Check if the package is already up-to-date using apt-get
                if apt-get install -y --only-upgrade "$package" > /dev/null 2>&1; then
                    echo "$package is already up-to-date. Skipping."
                else
                    echo "$package is installed but outdated. Updating..."
                    install_package "$package"
                fi
            fi
        else
            echo "$package is not installed. Installing..."
            install_package "$package"
        fi
    done
}

# Function to clean up after installation
cleanup() {
    echo "Cleaning up..."
    apt-get clean
    rm -rf /var/lib/apt/lists/*
}

# =============================
# Main Execution
# =============================

# Update the package manager
update_package_manager

# Determine which package manager to use
determine_package_manager

# Install or update the listed packages
install_or_update_packages

# Clean up package lists to save space
cleanup

echo "All specified packages are installed and up-to-date."
