import re
import base64
import os

input_file = "input.html"
output_dir = "/storage/emulated/0/DecodedBlobs"

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Regex pattern to find Base64 blobs (data URI or raw)
base64_pattern = re.compile(
    r'(?:data:[^;]+;base64,)?([A-Za-z0-9+/=]{100,})'
)

with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    html_content = f.read()

blobs = base64_pattern.findall(html_content)

print(f"Found {len(blobs)} base64 blobs.")

for i, blob in enumerate(blobs):
    try:
        decoded = base64.b64decode(blob)
        output_path = os.path.join(output_dir, f"blob_{i:03}.bin")
        with open(output_path, 'wb') as out_file:
            out_file.write(decoded)
        print(f"Decoded blob {i} -> {output_path}")
    except Exception as e:
        print(f"Failed to decode blob {i}: {e}")
