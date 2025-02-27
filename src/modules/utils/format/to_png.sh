#!/bin/bash

topng(){
  # Check if ImageMagick (convert) is installed
  if ! command -v convert &> /dev/null; then
      echo "Error: ImageMagick is not installed. Please install it and try again."
      return 1
  fi

  # Check if the user provided a directory
  if [[ -z "$1" ]]; then
      echo "Usage: $0 <target_directory>"
      return 1
  fi

  # Target directory
  target_dir="$1"

  # Ensure the target directory exists
  if [[ ! -d "$target_dir" ]]; then
      echo "Error: Directory '$target_dir' does not exist."
      return 1
  fi

  # Loop through all image files in the target directory
  find "$target_dir" -type f \( \
      -iname '*.webp' -o \
      -iname '*.jpg' -o \
      -iname '*.jpeg' -o \
      -iname '*.bmp' -o \
      -iname '*.tiff' -o \
      -iname '*.gif' \
  \) | while read -r file; do
      # Define output filename (same directory, .png extension)
      output_file="${file%.*}.png"

      # Check if the output file already exists
      if [[ -f "$output_file" ]]; then
          echo "Skipping $file (PNG already exists)"
          continue
      fi

      # Convert the file to PNG
      echo "Converting $file to $output_file..."
      convert "$file" "$output_file"

      # Check if the conversion was successful
      if [[ $? -eq 0 ]]; then
          echo "Converted: $file -> $output_file"
      else
          echo "Failed to convert: $file"
      fi
  done

  echo "Conversion complete."
}
