#!/bin/bash

# Directory where fonts are stored
FONT_DIR="/usr/share/figlet"

# Text to display
TEXT="Pussy/tits"

echo "Looping through toilet fonts..."
echo "Press Ctrl+C to stop."

# Loop through valid font files in the directory
for FONT in $(ls $FONT_DIR/*.flf 2>/dev/null); do
    FONT_NAME=$(basename "$FONT")  # Get the font file name
    echo "Font: $FONT_NAME"
    toilet -f "$FONT_NAME" "$TEXT"
    echo -e "\n"
    sleep 1  # Pause for 1 second before showing the next font
done

echo "No valid fonts found in $FONT_DIR"  # If no fonts are processed

