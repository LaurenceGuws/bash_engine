#!/bin/bash

# Set your preferred default browser
default_browser="firefox"

# Override the docker command
docker() {
  if [ "$1" == "tags" ]; then
    shift
    local open_in_browser=false

    # Parse options for `tags`
    while getopts ":b" opt; do
      case $opt in
        b) open_in_browser=true ;;
        \?) echo "Invalid option: -$OPTARG"; return 1 ;;
      esac
    done
    shift $((OPTIND - 1))

    # Call the appropriate function based on the -b flag
    if [ "$open_in_browser" = true ]; then
      docker_tags_browser "$@"
    else
      docker_tags "$@"
    fi
  else
    # Call the actual docker command for other options
    command docker "$@"
  fi
}

docker_tags() {
  if [ -z "$1" ]; then
    echo "Usage: docker tags [-b] <image>"
    return 1
  fi

  local image=$1
  local url="https://registry.hub.docker.com/v2/repositories/$image/tags/"
  local page=1

  echo "Fetching tags for image: $image"
  
  while true; do
    response=$(curl -s "$url?page=$page")

    # Check for errors in the response
    if echo "$response" | jq -e '.errors' >/dev/null 2>&1; then
      echo "Error: Unable to fetch tags for '$image'. Please check the image name."
      return 1
    fi

    # Extract tags and ensure results are not null or empty
    tags=$(echo "$response" | jq -r '.results | select(. != null) | .[]["name"]')
    
    # Break the loop if no more tags are found
    if [ -z "$tags" ]; then
      echo "No more tags found."
      break
    fi

    echo "$tags"
    page=$((page + 1))
  done
}

docker_tags_browser() {
  if [ -z "$1" ]; then
    echo "Usage: docker tags -b <image>"
    return 1
  fi

  local image=$1
  local docker_url="https://hub.docker.com/r/$image/tags"

  echo "Opening Docker Hub page for image: $image"
  "$default_browser" "$docker_url" &>/dev/null &
}

# Test example
# docker tags -b wso2/wso2is
# docker tags wso2/wso2is
