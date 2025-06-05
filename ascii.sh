#!/data/data/com.termux/files/usr/bin/bash

# Decode ASCII like \108\111\97 into real characters
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Find all .lua files and process each
find . -type f -name "*.lua" | while read -r file; do
    line=$(cat "$file")

    # Extract the contents inside loadstring("...") or loadstring('...')
    encoded=$(echo "$line" | sed -n 's/loadstring([\"\x27]\\.*\\[\"\x27])()/\1/p')

    if [ -n "$encoded" ]; then
        decoded=$(decode_ascii "$encoded")
        echo "$decoded" > "$file"
        echo "[+] Decrypted: $file"
    else
        echo "[ ] Skipped: $file"
    fi
done
