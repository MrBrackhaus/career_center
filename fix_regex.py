path = 'lib/core/services/extractors/cover_letter_extractor.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re
pattern = r"RegExp\(r'\(\?i\)bewerbung\\s\*\(\w+\|[^']+\)\?\\s\*'\)"
new_code = "RegExp(r'bewerbung\s*(als|auf|um|für|:|-)?\s*', caseSensitive: false)"

# Let's just do a simple replace
if '(?i)bewerbung\s*(als|auf|um|f' in text or '(?i)bewerbung' in text:
    # replace the exact line
    text = re.sub(r"RegExp\(\s*r'\(\?i\)bewerbung\\s\*\([^)]*\)\?\\s\*'\s*\)", new_code, text)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Fixed Extractor Regex!")
else:
    print("Could not find regex.")
