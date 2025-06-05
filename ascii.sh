#!/data/data/com.termux/files/usr/bin/bash

# Function to decode \123\45\67 into actual ASCII characters
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Find all .lua files and process each
find . -type f -name "*.lua" | while read -r file; do
    content=$(cat "$file")

    # Extract ASCII string between loadstring("...")() or loadstring('...')()
    encoded=$(echo "$content" | grep -oP 'loadstring["'\'']\0-9\*["'\'']' | grep -oP '\0-9\+')

    if [ -n "$encoded" ]; then
        # Decode the ASCII sequence
        decoded=$(decode_ascii "$encoded")

        # Replace the file content with decoded Lua
        echo "$decoded" > "$file"
        echo "[+] Decrypted: $file"
    else
        echo "[ ] Skipped (no encoded string): $file"
    fi
done
