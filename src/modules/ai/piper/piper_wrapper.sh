#!/bin/bash

narrate () {
    if [[ -t 0 ]]; then
        TEXT="$1"  # If input is from a terminal, use arguments
    else
        TEXT="$(cat)"  # If input is piped, read from stdin
    fi

    if [[ -z "$TEXT" ]]; then
        echo "Error: No text provided to narrate." >&2
        return 1
    fi

    CONFIG="$HOME/.config/piper"
    MODEL="$CONFIG/ljspeech/en_US-ljspeech-high.onnx"
    MODEL_CONFIG="$CONFIG/ljspeech/en_US-ljspeech-high.onnx.json"
    OUTPUT="$(mktemp --suffix=.wav)"

    # Validate model files exist
    if [[ ! -f "$MODEL" ]]; then
        echo "Error: Model file not found: $MODEL" >&2
        return 2
    fi

    if [[ ! -f "$MODEL_CONFIG" ]]; then
        echo "Error: Model config file not found: $MODEL_CONFIG" >&2
        return 3
    fi

    # Validate required commands are available
    if ! command -v piper-tts > /dev/null; then
        echo "Error: piper-tts is not installed or not in PATH." >&2
        return 4
    fi

    if ! command -v cvlc > /dev/null; then
        echo "Error: cvlc (VLC command-line) is not installed or not in PATH." >&2
        return 5
    fi

    # Run Piper
    piper-tts -m "$MODEL" -c "$MODEL_CONFIG" --speaker 1 -f "$OUTPUT" <<< "$TEXT" > /dev/null 2>&1
    piper-tts -m "$MODEL" -c "$MODEL_CONFIG" --speaker 1 -f "$OUTPUT" <<< "$TEXT" > /dev/null 2>&1

    if [[ -f "$OUTPUT" ]]; then
        cvlc --quiet --play-and-exit "$OUTPUT" > /dev/null 2>&1
        rm -f "$OUTPUT"
    else
        echo "Error: Output file not created!" >&2
        return 6
    fi
}
