#!/bin/bash
tts_file () {
    if [[ -t 0 ]]; then
        TEXT="$1"  # If input is from a terminal, use arguments
    else
        TEXT="$(cat)"  # If input is piped, read from stdin
    fi

    MODEL="/usr/local/bin/piper/models/en_US-lessac-high.onnx";
    CONFIG="/usr/local/bin/piper/models/en_US-lessac-high.onnx.json";
    OUTPUT="./outputfile.wav";

    # echo "got $TEXT";
    piper-tts -m "$MODEL" -c "$CONFIG" --speaker 1 -f "$OUTPUT" <<< "$TEXT" > /dev/null 2>&1;
    piper-tts -m "$MODEL" -c "$CONFIG" --speaker 1 -f "$OUTPUT" <<< "$TEXT" > /dev/null 2>&1;

    if [[ -f "$OUTPUT" ]]; then
        mpv "$OUTPUT";
    else
        echo "Error: Output file not created!" 1>&2;
    fi
}

