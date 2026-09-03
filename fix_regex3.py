path = 'lib/core/services/extractors/cover_letter_extractor.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re
match = re.search(r"RegExp\(\s*r'\(\?i\)bewerbung\\s\*\([^)]*\)\?\\s\*'\s*\)", text)
if match:
    old = match.group(0)
    text = text.replace(old, "RegExp(r'bewerbung\\s*(als|auf|um|für|:|-)?\\s*', caseSensitive: false)")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Replaced!")
else:
    print("Not found")
