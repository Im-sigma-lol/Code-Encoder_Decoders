#!/data/data/com.termux/files/usr/bin/bash

# Decode \123\45 into actual characters
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Find all .lua files and process them
find . -type f -name "*.lua" | while read -r file; do
    line=$(cat "$file")

    # Extract between the quotes: loadstring("...")()
    encoded=$(echo "$line" | grep -oP 'loadstring"([^"]+)"' | sed -E 's/loadstring"([^"]+)"/\1/')

    if [ -n "$encoded" ]; then
        decoded=$(decode_ascii "$encoded")
        echo "$decoded" > "$file"
        echo "[+] Decrypted: $file"
    else
        echo "[ ] Skipped: $file (no valid encoded data)"
    fi
done
