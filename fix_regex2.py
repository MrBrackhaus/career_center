path = 'lib/core/services/extractors/cover_letter_extractor.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re
new_code = r"RegExp(r'bewerbung\s*(als|auf|um|für|:|-)?\s*', caseSensitive: false)"

text = re.sub(r"RegExp\(\s*r'\(\?i\)bewerbung\\s\*\([^)]*\)\?\\s\*'\s*\)", new_code, text)
with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Fixed Regex via python!")
