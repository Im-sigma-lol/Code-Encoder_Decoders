#!/data/data/com.termux/files/usr/bin/bash

# Function to decode ASCII like \108\111\97 into real characters
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Process all .lua files
find . -type f -name "*.lua" | while read -r file; do
    # Read file line by line
    while IFS= read -r line; do
        # Match line with loadstring("...")()
        if echo "$line" | grep -q 'loadstring(".*")()'; then
            # Extract encoded string
            encoded=$(echo "$line" | sed -E 's/loadstring"([^"]+)"/\1/')
            decoded=$(decode_ascii "$encoded")
            echo "$decoded" > "$file"
            echo "[+] Decrypted: $file"
            break
        fi
    done < "$file"
done
