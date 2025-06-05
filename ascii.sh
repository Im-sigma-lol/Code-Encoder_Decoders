#!/data/data/com.termux/files/usr/bin/bash

# Function to decode ASCII escape sequences like \108\101 into readable text
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Recursively find all .lua files
find . -type f -name "*.lua" | while read -r file; do
    # Try to extract the loadstring line
    raw_line=$(grep -oP 'loadstring"([^"]+)"' "$file")

    if [ -n "$raw_line" ]; then
        # Extract the encoded string inside quotes
        encoded=$(echo "$raw_line" | cut -d'"' -f2)

        # Decode ASCII
        decoded=$(decode_ascii "$encoded")

        if [ -n "$decoded" ]; then
            echo "$decoded" > "$file"
            echo "[+] Decrypted: $file"
        else
            echo "[!] Failed to decode: $file"
        fi
    else
        echo "[ ] Skipped (no matching loadstring): $file"
    fi
done
