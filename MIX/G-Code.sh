#!/data/data/com.termux/files/usr/bin/bash

# G-Code mapping (partial — extend as needed)
declare -A gcode_encode=(
  ["\n"]="👇" [" "]="👉" ["!"]="⚠️" ['"']="🙌" ["#"]="🤬"
  ["0"]="💘" ["1"]="🤎" ["2"]="💙" ["3"]="🤍"
  ["A"]="😀" ["B"]="😃" ["C"]="😄" ["D"]="😁"
  ["a"]="😋" ["b"]="😛" ["c"]="😝" ["d"]="😜"
)

# Reverse table for decoding
declare -A gcode_decode
for key in "${!gcode_encode[@]}"; do
  gcode_decode["${gcode_encode[$key]}"]="$key"
done

# Function: Encode text
encode_text() {
  local input="$1"
  local output=""
  local i char encoded
  for ((i = 0; i < ${#input}; i++)); do
    char="${input:i:1}"
    encoded="${gcode_encode[$char]}"
    output+="${encoded:-$char} "
  done
  echo "$output"
}

# Function: Decode text
decode_text() {
  local input="$1"
  local output=""
  local emoji
  for emoji in $input; do
    output+="${gcode_decode[$emoji]:-$emoji}"
  done
  echo -e "$output"
}

# CLI parser
MODE=""
FILENAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -E) MODE="ENCODE" ;;
    -D) MODE="DECODE" ;;
    -F) shift; FILENAME="$1" ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
  shift
done

if [[ "$MODE" == "" ]]; then
  echo "Enter G-Code text (end with Ctrl+D):"
  user_input=$(cat)
  [[ -z "$user_input" ]] && { echo "No input provided."; exit 1; }
  if [[ "$user_input" == *[😀-🙏💘-🧿]* ]]; then
    decode_text "$user_input"
  else
    encode_text "$user_input"
  fi
  exit 0
fi

# Handle file input if provided
if [[ -n "$FILENAME" && -f "$FILENAME" ]]; then
  content=$(cat "$FILENAME")
else
  echo "Enter text (end with Ctrl+D):"
  content=$(cat)
fi

if [[ "$MODE" == "ENCODE" ]]; then
  encode_text "$content"
elif [[ "$MODE" == "DECODE" ]]; then
  decode_text "$content"
else
  echo "No mode selected."
  exit 1
fi
