#!/bin/bash

bassit() {
    TEXT="$1"

    # Ensure bot command exists
    if ! command -v bot &>/dev/null; then
        gum style --border double --border-foreground 1 "❌ Error: 'bot' command not found"
        return 1
    fi

    # Get bot response
    response="$(bot "$TEXT")"

    # Cleanup: Remove markdown and XML/HTML tags
    clean_response=$(echo "$response" | sed -E 's/<[^>]+>//g' | sed 's/```//g')

    # Ensure narrate exists
    if ! command -v narrate &>/dev/null; then
        gum style --border double --border-foreground 1 "❌ Error: 'narrate' command not found"
        return 1
    fi

    # Display chat-style bubble
    gum style --border normal --margin "1" --padding "1" --border-foreground 2 "🤖 $clean_response"

    # Speak response
    narrate "$clean_response"
}
