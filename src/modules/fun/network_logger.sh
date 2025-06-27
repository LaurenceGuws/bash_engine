#!/bin/bash

network_logger() {
    # Temporarily enable logging if it is currently disabled.
    # Save the original value so it can be restored when the function returns.
    local _orig_blog_disabled="${BLOG_DISABLED:-}"

    # Always restore the original value of BLOG_DISABLED when the function exits (normal return or early exit)
    trap "export BLOG_DISABLED='${_orig_blog_disabled}'" RETURN

    # If logging was disabled (value was exactly "true"), enable it for the duration of this function
    if [[ "${_orig_blog_disabled}" == "true" ]]; then
        export BLOG_DISABLED="false"
    fi

    # Ensure speedtest-cli is installed via paru (or other package managers if needed)
    if ! command -v speedtest-cli &> /dev/null; then
        blog error "speedtest-cli is not installed. Installing..."
        paru -S speedtest-cli --noconfirm
    fi

    # Run the speed test and capture output (automatically selects the best server)
    local speedtest_output
    speedtest_output=$(speedtest-cli --simple)

    # Extract values
    local ping download upload
    ping=$(echo "$speedtest_output" | grep "Ping" | awk '{print $2}')
    download=$(echo "$speedtest_output" | grep "Download" | awk '{print $2}')
    upload=$(echo "$speedtest_output" | grep "Upload" | awk '{print $2}')

    # Check if values were extracted properly
    if [[ -z "$ping" || -z "$download" || -z "$upload" ]]; then
        blog error "Failed to fetch speed test results. Check your internet connection or speedtest-cli installation."
        return 1
    fi

    # Log results using your `blog` logger
    blog info "󰓅 Network Speed Test Results:"
    blog info "󱚸 Ping: ${ping} ms"
    blog info "󰇚 Download: ${download} Mbps"
    blog info "󰕒 Upload: ${upload} Mbps"
}


