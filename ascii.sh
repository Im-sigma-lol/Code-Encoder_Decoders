#!/data/data/com.termux/files/usr/bin/bash

# Decode function
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Main loop
find . -type f -name "*.lua" | while read -r file; do
    raw_line=$(grep -oP 'loadstring"([^"]+)"' "$file")

    if [ -n "$raw_line" ]; then
        first=$(echo "$raw_line" | cut -d'"' -f2)
        decoded1=$(decode_ascii "$first")

        # Check if decoded1 contains another loadstring
        if echo "$decoded1" | grep -q 'loadstring(";'; then
            second=$(echo "$decoded1" | grep -oP 'loadstring"([^"]+)"' | cut -d'"' -f2)
            decoded2=$(decode_ascii "$second")
            final="$decoded2"
        else
            final="$decoded1"
        fi

        if [ -n "$final" ]; then
            echo "$final" > "$file"
            echo "[+] Decrypted (double): $file"
        else
            echo "[!] Failed to decode: $file"
        fi
    else
        echo "[ ] Skipped (no matching loadstring): $file"
    fi
done
