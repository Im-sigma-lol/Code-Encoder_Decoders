#!/bin/bash

# Function to decode an ASCII-encoded Lua string
decode_ascii() {
    local encoded="$1"
    echo -e "$encoded"
}

# Function to decode and replace in a file
process_file() {
    local file="$1"

    # Use Perl to extract all loadstring("\###...") matches
    grep -Poz '(?s)loadstring\s*"((\\\d{2,3})+)"\s*' "$file" | while IFS= read -r -d '' match; do
        encoded=$(echo "$match" | grep -oP '"\K(\\\d{2,3})+(?=")')
        if [[ -n "$encoded" ]]; then
            decoded=$(decode_ascii "$encoded")
            new_loadstring="loadstring(\"$decoded\")"
            # Escape for sed
            sed_safe_match=$(printf '%s\n' "$match" | sed -e 's/[\/&]/\\&/g')
            sed_safe_replacement=$(printf '%s\n' "$new_loadstring" | sed -e 's/[\/&]/\\&/g')
            # Replace in-place
            sed -i "s/$sed_safe_match/$sed_safe_replacement/" "$file"
            echo ">>> Replaced in: $file"
        fi
    done
}

# Main scan
scan_directory() {
    local dir="$1"
    find "$dir" -type f | while read -r file; do
        process_file "$file"
    done
}

# Entry point
TARGET_DIR="${1:-.}"  # Use current directory if none given
scan_directory "$TARGET_DIR"
