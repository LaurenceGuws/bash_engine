#!/bin/bash
narrate () {
    if [[ -t 0 ]]; then
        TEXT="$1"  # If input is from a terminal, use arguments
    else
        TEXT="$(cat)"  # If input is piped, read from stdin
    fi

    MODEL="/usr/local/bin/piper/models/en_GB-cori-high.onnx";
    CONFIG="/usr/local/bin/piper/models/en_GB-cori-high.onnx.json";
    OUTPUT="$HOME/outputfile.wav";

    # echo "got $TEXT";
    piper -m "$MODEL" -c "$CONFIG" --speaker 1 -f "$OUTPUT" <<< "$TEXT" > /dev/null 2>&1;
    piper -m "$MODEL" -c "$CONFIG" --speaker 1 -f "$OUTPUT" <<< "$TEXT" > /dev/null 2>&1;

    if [[ -f "$OUTPUT" ]]; then
        cvlc --quiet --play-and-exit "$OUTPUT" > /dev/null 2>&1;
        rm "$OUTPUT";
    else
        echo "Error: Output file not created!" 1>&2;
    fi
}
