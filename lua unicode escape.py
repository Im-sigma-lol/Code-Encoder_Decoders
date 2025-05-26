import re
import string

def is_printable(s, threshold=0.9):
    # Check if string is mostly printable
    printable = sum(1 for c in s if c in string.printable)
    return (printable / max(len(s), 1)) >= threshold

def decode_lua_string(s):
    try:
        decoded = bytes(s, "utf-8").decode("unicode_escape")
        if is_printable(decoded):
            return decoded
        else:
            return s  # skip decoding if looks like binary
    except:
        return s  # skip if decoding fails

def decode_strings_in_file(input_file="input.txt", output_file="output.txt"):
    with open(input_file, "r", encoding="utf-8") as f:
        content = f.read()

    def replacer(match):
        original = match.group(0)
        inner = match.group(1)
        decoded_inner = decode_lua_string(inner)
        return f'"{decoded_inner}"'

    pattern = r'"((?:[^"\\]|\\.)*?)"'
    new_content = re.sub(pattern, replacer, content)

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(new_content)

    print("[+] Strings decoded (safe mode). Output saved to:", output_file)

decode_strings_in_file()
