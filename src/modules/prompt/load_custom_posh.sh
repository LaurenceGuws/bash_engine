#!/usr/bin/bash

# Normalize paths to avoid double slashes
normalize_path() {
    echo "$1" | sed 's:/\+:/:g'
}

posh() {
    # Source and destination directories
    SRC_DIR=$(normalize_path "$PROFILE_DIR/dots/posh/")
    DEST_DIR=$(normalize_path "$THEME_DIR/")

    # Check if the source directory exists
    if [[ ! -d "$SRC_DIR" ]]; then
        blog -l error "Source directory '$SRC_DIR' does not exist." 
        return 1
    fi

    # Check if the destination directory exists
    if [[ ! -d "$DEST_DIR" ]]; then
        blog -l info "Destination directory '$DEST_DIR' does not exist. Creating it now..." 
        mkdir -p "$DEST_DIR" || {
            blog -l error "Failed to create destination directory." 
            return 1
        }
    fi

    # List files in the source directory
    blog -l info "Listing files in the source directory '$SRC_DIR'..." 
    files=("$SRC_DIR"*)
    if [[ ${#files[@]} -eq 0 ]]; then
        blog -l error "No files found in the source directory '$SRC_DIR'." 
        return 1
    fi
    for file in "${files[@]}"; do
        blog -l info "Found: $file" 
    done

    # Copy files from source to destination
    blog -l info "Copying files from '$SRC_DIR' to '$DEST_DIR'..." 
    cp -r "$SRC_DIR"* "$DEST_DIR" || {
        blog -l error "Failed to copy files from '$SRC_DIR' to '$DEST_DIR'." 
        return 1
    }

    # Confirm files exist in the destination
    blog -l info "Confirming copied files in '$DEST_DIR'..." 
    for file in "${files[@]}"; do
        file_name=$(basename "$file")
        target_file=$(normalize_path "$DEST_DIR/$file_name")
        if [[ -f "$target_file" ]]; then
            blog -l info "File confirmed in target: $target_file" 
        else
            blog -l error "File missing in target: $target_file" 
        fi
    done

    blog -l info "Files copied successfully from '$SRC_DIR' to '$DEST_DIR'." 
}

