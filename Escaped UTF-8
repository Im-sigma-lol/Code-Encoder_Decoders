import re

def decode_escaped_bytestring(s):
    if isinstance(s, bytes):
        s = s.decode("utf-8", errors="replace")
    try:
        return bytes(s, "utf-8").decode("unicode_escape")
    except:
        return s

with open("input.txt", "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# Find b'....' or b"...." patterns
matches = re.findall(r"b[\"'](.*?)[\"']", content)

for i, m in enumerate(matches, 1):
    decoded = decode_escaped_bytestring(m)
    print(f"\n--- Decoded Match #{i} ---\n{decoded}")
