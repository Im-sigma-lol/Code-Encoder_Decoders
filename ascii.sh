#!/data/data/com.termux/files/usr/bin/bash

# Clean decode: only convert \NNN (where N = 0–9)
decode_ascii() {
    echo "$1" | perl -CS -pe 's/\[0-9]{1,3})/chr($1)/ge'
}

# Recursively decode all layers
recursive_decode() {
    local input="$1"
    local iterations=0
    local new_input

    while echo "$input" | grep -q 'loadstring(".*")()'; do
        encoded=$(echo "$input" | grep -oP 'loadstring"([^"]+)"' | head -n 1 | cut -d'"' -f2)
        new_input=$(decode_ascii "$encoded")

        # Avoid infinite loop
        if [ "$new_input" == "$input" ] || [ -z "$new_input" ]; then
            break
        fi

        input="$new_input"
        iterations=$((iterations + 1))
    done

    echo "$input"
}

# Main decoding loop for all .lua files
find . -type f -name "*.lua" | while read -r file; do
    content=$(cat "$file")
    result=$(recursive_decode "$content")

    if [ -n "$result" ] && [ "$result" != "$content" ]; then
        echo "$result" > "$file"
        echo "[+] Decoded: $file"
    else
        echo "[ ] Skipped: $file (no change)"
    fi
done
