# -*- coding: utf-8 -*-
import os
import json
import re

translations = {
    "Jobcenter-Nachweis": ("navJobcenter", "Jobcenter-Nachweis", "Jobcenter Report"),
    "Posteingang checken": ("appCheckInbox", "Posteingang checken", "Check Inbox"),
}

def update_arbs():
    for lang, idx in [('de', 1), ('en', 2)]:
        path = f'lib/l10n/app_{lang}.arb'
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for orig, (key, de_val, en_val) in translations.items():
            if key not in data:
                data[key] = de_val if lang == 'de' else en_val
                
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

def patch_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
        
    changed = False
    for orig, (key, _, _) in translations.items():
        pattern = r"['\"]" + orig + r"['\"]"
        replacement = f"loc?.{key} ?? '{orig}'"
        
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
            changed = True
            
    if changed:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)

update_arbs()
patch_file('lib/presentation/widgets/responsive_shell.dart')
print("Patched responsive shell!")
