import re

def decode_lua_string(s):
    try:
        return bytes(s, "utf-8").decode("unicode_escape")
    except:
        return s  # return original if decoding fails

def decode_strings_in_file(input_file="input.txt", output_file="output.txt"):
    with open(input_file, "r", encoding="utf-8") as f:
        content = f.read()

    # Replace each quoted string with its decoded version
    def replacer(match):
        original = match.group(0)  # includes quotes
        inner = match.group(1)     # just the string content
        decoded_inner = decode_lua_string(inner)
        return f'"{decoded_inner}"'

    # Matches "anything possibly escaped" including \" and \n
    pattern = r'"((?:[^"\\]|\\.)*?)"'
    new_content = re.sub(pattern, replacer, content)

    # Save the updated file
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(new_content)

    print("[+] Strings decoded. Output saved to:", output_file)

decode_strings_in_file()
