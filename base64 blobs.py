import re
import base64
import os
import mimetypes
import hashlib

input_file = "input.html"
output_file = "output.html"
output_dir = "/storage/emulated/0/DecodedBlobs"
os.makedirs(output_dir, exist_ok=True)

with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    html = f.read()

# Regex to match data URIs
pattern = re.compile(r'data:([^;]+);base64,([A-Za-z0-9+/=]+)')

def safe_utf8(blob):
    try:
        text = blob.decode('utf-8')
        # Optional: ensure text is printable
        return all(32 <= ord(c) < 127 or c in '\r\n\t' for c in text)
    except:
        return False

def extract_filename_near(match_start, window=500):
    # Look ahead and behind for clues
    snippet = html[max(0, match_start - window):match_start + window]
    path_match = re.search(r'(src|href)=["\']([^"\']+)["\']', snippet)
    if path_match:
        path = path_match.group(2)
        if not path.startswith("data:"):
            return os.path.basename(path)
    comment_match = re.search(r'<!--\s*filename:\s*([^\s]+)\s*-->', snippet, re.IGNORECASE)
    if comment_match:
        return comment_match.group(1)
    return None

blob_counter = 0
replacements = []

for match in pattern.finditer(html):
    full_match = match.group(0)
    mime_type = match.group(1)
    b64 = match.group(2)
    try:
        blob = base64.b64decode(b64)
    except Exception:
        continue

    if safe_utf8(blob):
        # Text blob — replace directly
        decoded_text = blob.decode('utf-8')
        replacements.append((full_match, decoded_text))
    else:
        # Binary blob — save to file
        filename = extract_filename_near(match.start())
        if not filename:
            ext = mimetypes.guess_extension(mime_type) or '.bin'
            filename = f"blob_{blob_counter:03}{ext}"
        path = os.path.join(output_dir, filename)
        if not os.path.exists(path):
            with open(path, 'wb') as f:
                f.write(blob)
        blob_counter += 1
        replacements.append((full_match, path))

# Apply replacements
for old, new in replacements:
    html = html.replace(old, new)

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html)

print(f"Replaced {len(replacements)} blobs. Output written to {output_file}")
