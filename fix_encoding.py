import os

def fix_file(path):
    try:
        with open(path, 'rb') as f:
            content = f.read()
        if content.startswith(b'\xef\xbb\xbf'):
            content = content[3:]
            with open(path, 'wb') as f:
                f.write(content)
            print(f"Fixed BOM in {path}")
        else:
            # Maybe it was saved as ISO-8859-1 or cp1252?
            # We can try to decode as utf-8. If it fails, decode as cp1252 and write as utf-8
            try:
                content.decode('utf-8')
            except UnicodeDecodeError:
                text = content.decode('cp1252')
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(text)
                print(f"Fixed encoding in {path}")
    except Exception as e:
        pass

for root, dirs, files in os.walk('.'):
    if '.git' in root or '.dart_tool' in root or 'build' in root:
        continue
    for file in files:
        if file.endswith(('.dart', '.arb', '.yaml', '.xml', '.plist', '.html', '.rc', '.cpp', '.txt')):
            fix_file(os.path.join(root, file))
