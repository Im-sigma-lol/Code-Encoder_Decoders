import re

def decode_lua_string(s):
    # Decode Lua-style escape sequences like \n, \", etc.
    return bytes(s, "utf-8").decode("unicode_escape")

def extract_and_decode(filename="input.txt"):
    with open(filename, "r", encoding="utf-8") as f:
        content = f.read()

    # Match strings wrapped in quotes (e.g. "something with \" escapes \n")
    pattern = r'"(.*?\\n.*?|.*?\\\".*?)*?"'  # Matches strings with \n or \"
    matches = re.findall(pattern, content)

    decoded_strings = []
    for m in matches:
        try:
            decoded = decode_lua_string(m)
            decoded_strings.append(decoded)
        except Exception as e:
            print(f"[!] Failed to decode: {m[:30]}... ({e})")

    # Print decoded results
    for i, s in enumerate(decoded_strings):
        print(f"\n--- Decoded String #{i + 1} ---\n{s}")

    # Optionally save to a file
    with open("decoded_output.txt", "w", encoding="utf-8") as out:
        for s in decoded_strings:
            out.write(s + "\n\n")

extract_and_decode()
