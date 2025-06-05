#!/data/data/com.termux/files/usr/bin/bash

# Safe ASCII decode using Perl (handles \NNN reliably)
decode_ascii() {
    echo "$1" | perl -pe 's/\\d{1,3})/chr($1)/ge'
}

# Recursive decode loop
recursive_decode() {
    local input="$1"
    local new_input
    local iterations=0

    while echo "$input" | grep -q 'loadstring(".*")()'; do
        encoded=$(echo "$input" | grep -oP 'loadstring"([^"]+)"' | head -n1 | cut -d'"' -f2)
        new_input=$(decode_ascii "$encoded")

        # Break if decoding stalls or is empty
        if [ "$new_input" == "$input" ] || [ -z "$new_input" ]; then
            break
        fi

        input="$new_input"
        iterations=$((iterations + 1))
    done

    echo "$input"
}

# Main loop to find and decode .lua files
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
