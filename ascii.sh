#!/data/data/com.termux/files/usr/bin/bash

# Decode one level of ASCII
decode_ascii() {
    echo -e "$1" | sed 's/\\[0-9]\{1,3\}/\\x\1/g' | xargs -0 printf "%b"
}

# Recursively decode until no loadstring("...")() is found
recursive_decode() {
    local input="$1"
    local decoded

    while echo "$input" | grep -q 'loadstring(".*")()'; do
        encoded=$(echo "$input" | grep -oP 'loadstring"([^"]+)"' | head -n 1 | cut -d'"' -f2)
        decoded=$(decode_ascii "$encoded")

        # If decoding fails or doesn't change, break to prevent infinite loop
        if [ "$decoded" == "$input" ] || [ -z "$decoded" ]; then
            break
        fi

        input="$decoded"
    done

    echo "$input"
}

# Process all .lua files recursively
find . -type f -name "*.lua" | while read -r file; do
    original=$(cat "$file")

    # Start recursive decoding
    result=$(recursive_decode "$original")

    if [ -n "$result" ] && [ "$result" != "$original" ]; then
        echo "$result" > "$file"
        echo "[+] Fully Decoded: $file"
    else
        echo "[ ] Skipped or already decoded: $file"
    fi
done
