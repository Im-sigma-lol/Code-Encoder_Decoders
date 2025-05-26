import re
import string

input_file = "input.txt"
output_file = "output.txt"

def decode_lua_string(s):
    # Decode octal escape sequences: \ddd
    def decode_octal(match):
        val = int(match.group(1))
        return chr(val) if val < 256 else match.group(0)

    s = re.sub(r'\\d{1,3})', decode_octal, s)

    # Decode hex escape sequences: \xHH
    s = re.sub(r'\\x([0-9A-Fa-f]{2})', lambda m: chr(int(m.group(1), 16)), s)

    try:
        decoded = bytes(s, "utf-8").decode("unicode_escape")
    except:
        decoded = s

    # Skip binary-like results
    printable_ratio = sum(c in string.printable for c in decoded) / max(len(decoded), 1)
    if printable_ratio < 0.9:
        return None

    return decoded

# Regex to find Lua string literals ("..." and '...')
string_pattern = re.compile(r'(["\'])(.*?)(?<!\\1', re.DOTALL)

with open(input_file, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

def replacer(match):
    quote = match.group(1)
    original = match.group(2)
    decoded = decode_lua_string(original)
    if decoded is None or decoded == original:
        return match.group(0)
    return quote + decoded + quote

updated_content = string_pattern.sub(replacer, content)

with open(output_file, "w", encoding="utf-8") as f:
    f.write(updated_content)

print(f"[+] Decoding complete. Output written to {output_file}")
