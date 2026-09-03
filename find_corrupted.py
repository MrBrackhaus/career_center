import os
import re

files_to_check = [
    'lib/app.dart',
    'lib/main.dart',
    'lib/core/router/app_router.dart',
    'lib/presentation/providers/locale_provider.dart',
    'lib/presentation/screens/settings/settings_screen.dart',
    'lib/presentation/screens/applications/applications_screen.dart',
    'lib/l10n/app_de.arb',
    'lib/l10n/app_en.arb'
]

non_ascii_words = set()
for f_path in files_to_check:
    if not os.path.exists(f_path): continue
    with open(f_path, 'r', encoding='utf-8', errors='replace') as f:
        text = f.read()
        words = re.findall(r'\b[a-zA-Z]*[^\x00-\x7F]+[a-zA-Z]*\b', text)
        non_ascii_words.update(words)

for w in non_ascii_words:
    print(w)
