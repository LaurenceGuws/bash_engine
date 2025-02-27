#!/bin/bash

permissions(){

  # Set strict permissions for all directories
  find "$PROFILE_DIR" -type d -exec chmod 700 {} +

  # Set strict permissions for all scripts (*.sh)
  find "$PROFILE_DIR" -type f -name "*.sh" -exec chmod 700 {} +

  # Set strict permissions for all configuration files (*.yaml)
  find "$PROFILE_DIR" -type f -name "*.yaml" -exec chmod 600 {} +

  # Set strict permissions for all log files (*.log)
  find "$PROFILE_DIR" -type f -name "*.log" -exec chmod 600 {} +

  # Set strict permissions for all resources (e.g., images, temp files)
  find "$PROFILE_DIR" -type f -name "*.webp" -exec chmod 600 {} +
  find "$PROFILE_DIR" -type f -name "temp.md" -exec chmod 600 {} +

  # Optional: Provide feedback
  blog -l info "Permissions handled." 
}
permissions
