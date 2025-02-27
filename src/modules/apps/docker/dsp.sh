#!/bin/bash

# Define dsp function
dsp() {
  # Start the Docker container with any additional arguments provided
  echo "Starting Docker container for laurencegouws/dummy-ps on port 5000"
  docker run "$@" -p 5000:5000 laurencegouws/dummy-ps
}

# Usage example:
# dsp -d               # Run the container in detached mode
