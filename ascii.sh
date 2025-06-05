#!/data/data/com.termux/files/usr/bin/bash

# Function to decode \123\45 into characters
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Process all .lua files
find . -type f -name "*.lua" | while read -r file; do
    # Extract the line that contains loadstring("...")()
    target_line=$(grep 'loadstring(".*")()' "$file")

    if [ -n "$target_line" ]; then
        # Safely extract between the first pair of quotes
        encoded=$(echo "$target_line" | cut -d'"' -f2)

        # Decode the ASCII string
        decoded=$(decode_ascii "$encoded")

        # Replace the file with decoded result
        echo "$decoded" > "$file"
        echo "[+] Decrypted: $file"
    else
        echo "[ ] Skipped: $file (no matching loadstring)"
    fi
done
