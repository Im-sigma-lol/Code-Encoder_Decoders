#!/data/data/com.termux/files/usr/bin/bash

# --- Emoji G-Code Mappings ---
declare -A gcode_encode=(
  ["\n"]="👇" [" "]="👉" ["!"]="⚠️" ['"']="🙌" ["#"]="🤬" ["$"]="🤑" ["%"]="🗝️" ["&"]="🫂"
  ["'"]="👐" ["("]="🌜" [")"]="🌛" ["*"]="✖️" ["+"]="➕" [","]="🐊" ["-"]="➖" ["."]="👆"
  ["/"]="➗" ["0"]="💘" ["1"]="🤎" ["2"]="💙" ["3"]="🤍" ["4"]="❤️" ["5"]="💚" ["6"]="🧡"
  ["7"]="💜" ["8"]="💛" ["9"]="🖤" [":"]="↕️️" [";"]="↩️" ["<"]="🌘" ["="]="🌗" [">"]="🌖"
  ["?"]="❓" ["@"]="🅰️" ["A"]="😀" ["B"]="😃" ["C"]="😄" ["D"]="😁" ["E"]="😆" ["F"]="😅"
  ["G"]="😂" ["H"]="🤣" ["I"]="😭" ["J"]="😉" ["K"]="😗" ["L"]="😙" ["M"]="😚" ["N"]="😘"
  ["O"]="🥰" ["P"]="😍" ["Q"]="🤩" ["R"]="🥳" ["S"]="🙃" ["T"]="🙂" ["U"]="🥲" ["V"]="😊"
  ["W"]="☺️" ["X"]="😌" ["Y"]="😏" ["Z"]="🤤" ["["]="📬" ["\\"]="↘️" ["]"]="📫" ["^"]="🔼"
  ["_"]="🔜" ["`"]="↖️" ["a"]="😋" ["b"]="😛" ["c"]="😝" ["d"]="😜" ["e"]="🤪" ["f"]="🥴"
  ["g"]="😔" ["h"]="🥺" ["i"]="😬" ["j"]="😑" ["k"]="😐" ["l"]="😶" ["m"]="🤐" ["n"]="🤔"
  ["o"]="🤫" ["p"]="🤭" ["q"]="🥱" ["r"]="🤗" ["s"]="😱" ["t"]="🤨" ["u"]="🧐" ["v"]="😒"
  ["w"]="🙄" ["x"]="😤" ["y"]="😠" ["z"]="😡" ["{"]="📈" ["|"]="🚦" ["}"]="📉" ["~"]="🚫"
)

declare -A gcode_decode
for k in "${!gcode_encode[@]}"; do
  gcode_decode["${gcode_encode[$k]}"]="$k"
done

# --- Functions ---
encrypt() {
  local input="$1"
  local output=""
  for ((i=0; i<${#input}; i++)); do
    c="${input:i:1}"
    output+="${gcode_encode[$c]:-$c}"
  done
  echo "$output"
}

decrypt() {
  local input="$1"
  local output=""
  local i=0
  while [[ $i -lt ${#input} ]]; do
    match=0
    for emoji in "${!gcode_decode[@]}"; do
      if [[ "${input:$i:${#emoji}}" == "$emoji" ]]; then
        output+="${gcode_decode[$emoji]}"
        ((i+=${#emoji}))
        match=1
        break
      fi
    done
    if [[ $match -eq 0 ]]; then
      output+="${input:$i:1}"
      ((i++))
    fi
  done
  echo "$output"
}

show_help() {
  echo "Usage: $0 -E|-D [-F file] [-DIR path] [-A] [-O] [-N] [-U] [-V]"
}

process_file() {
  local file="$1"
  [[ $VERBOSE == true ]] && echo "[*] Processing: $file"
  [[ "$MODE" == "ENC" ]] && result=$(encrypt "$(cat "$file")")
  [[ "$MODE" == "DEC" ]] && result=$(decrypt "$(cat "$file")")
  if $OVERWRITE; then
    echo "$result" > "$file"
  elif $RENAME; then
    ext="${MODE,,}"
    echo "$result" > "${file}.${ext}"
  else
    echo "$result"
  fi
}

# --- Default values ---
MODE=""
FILE=""
DIR=""
ALL=false
OVERWRITE=false
RENAME=false
FORCE=false
VERBOSE=false

# --- Flag parser ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    -E) MODE="ENC" ;;
    -D) MODE="DEC" ;;
    -F) FILE="$2"; shift ;;
    -DIR) DIR="$2"; shift ;;
    -A) ALL=true ;;
    -O) OVERWRITE=true ;;
    -N) RENAME=true ;;
    -U) FORCE=true ;;
    -V) VERBOSE=true ;;
    -h|--help) show_help; exit 0 ;;
    *) break ;;
  esac
  shift
done

# --- Action selector ---
if [[ -n "$FILE" ]]; then
  process_file "$FILE"
elif [[ -n "$DIR" && $ALL == true ]]; then
  find "$DIR" -type f | while read -r f; do process_file "$f"; done
elif [[ -n "$DIR" ]]; then
  for f in "$DIR"/*; do [[ -f "$f" ]] && process_file "$f"; done
elif [[ "$MODE" == "ENC" || "$MODE" == "DEC" ]]; then
  echo -n "Input: "
  read -r line
  [[ "$MODE" == "ENC" ]] && encrypt "$line"
  [[ "$MODE" == "DEC" ]] && decrypt "$line"
else
  show_help
fi
