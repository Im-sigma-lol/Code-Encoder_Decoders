import re

def decode_escaped_bytestring(s):
    try:
        return bytes(s, "utf-8").decode("unicode_escape")
    except:
        return s

def decode_b_strings_in_file(filename="input.txt", output="output.txt"):
    with open(filename, "r", encoding="utf-8", errors="ignore") as f:
        content = f.read()

    # Replace every b'...' pattern with decoded version
    def replacer(match):
        original = match.group(0)  # e.g., b'hi\\r\\nworld'
        inner = match.group(1)     # e.g., hi\\r\\nworld
        decoded = decode_escaped_bytestring(inner)
        return decoded  # Replace entire b'...' with actual decoded text

    # This pattern targets b'....' (or b"....") safely
    pattern = re.compile(r"b[\"'](.*?)[\"']")
    updated = pattern.sub(replacer, content)

    with open(output, "w", encoding="utf-8") as f:
        f.write(updated)

    print("[+] Finished decoding and replacing b'...' strings in-place.")

decode_b_strings_in_file()
