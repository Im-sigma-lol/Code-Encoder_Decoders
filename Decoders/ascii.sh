#!/data/data/com.termux/files/usr/bin/bash

# Decode only valid \NNN sequences (0–255), skip invalids
decode_ascii() {
    echo "$1" | perl -CS -pe '
        s{
            \[0-9]{1,3})     # Match \NNN
        }{
            $1 <= 255 ? chr($1) : "\\$1"
        }gex'
}

recursive_decode() {
    local input="$1"
    local new_input
    local max_depth=20
    local i=0

    while echo "$input" | grep -q 'loadstring(".*")()' && [ "$i" -lt "$max_depth" ]; do
        encoded=$(echo "$input" | grep -oP 'loadstring"([^"]+)"' | head -n1 | cut -d'"' -f2)
        new_input=$(decode_ascii "$encoded")

        if [ "$new_input" == "$input" ] || [ -z "$new_input" ]; then
            break
        fi

        input="$new_input"
        i=$((i + 1))
    done

    echo "$input"
}

# Process all Lua files
find . -type f -name "*.lua" | while read -r file; do
    original=$(cat "$file")
    result=$(recursive_decode "$original")

    if [ -n "$result" ] && [ "$result" != "$original" ]; then
        echo "$result" > "$file"
        echo "[+] Decoded ($file)"
    else
        echo "[ ] Skipped or already decoded: $file"
    fi
done
