import os

files_to_fix = [
    'lib/app.dart',
    'lib/main.dart',
    'lib/core/router/app_router.dart',
    'lib/presentation/providers/locale_provider.dart',
    'lib/presentation/screens/settings/settings_screen.dart',
    'lib/presentation/screens/applications/applications_screen.dart',
    'lib/l10n/app_de.arb',
    'lib/l10n/app_en.arb'
]

for f_path in files_to_fix:
    if not os.path.exists(f_path): continue
    with open(f_path, 'r', encoding='utf-8') as f:
        text = f.read()
    
    # We want to reverse the CP1252 -> UTF-8 mangling.
    # We encode as cp1252 to get the raw bytes, then decode as utf-8.
    # However, some parts of the file (like the ones I added manually via regex) 
    # might not be mangled, or might contain characters that fail to encode in cp1252.
    # So we do it character by character, or better, we do it safely:
    
    try:
        raw_bytes = text.encode('cp1252')
        fixed_text = raw_bytes.decode('utf-8')
        with open(f_path, 'w', encoding='utf-8') as f:
            f.write(fixed_text)
        print(f"Fixed {f_path} entirely")
    except Exception as e:
        # Fallback: regex replace known mangled sequences
        print(f"Manual fix needed for {f_path}: {e}")
        # Let's replace known mangled sequences
        replacements = {
            'Ã¼': 'ü',
            'Ã¤': 'ä',
            'Ã¶': 'ö',
            'Ãœ': 'Ü',
            'Ã„': 'Ä',
            'Ã–': 'Ö',
            'ÃŸ': 'ß',
            'Ã\x83Â¼': 'ü',
            'Ã\x83Â¤': 'ä',
            'Ã\x83Â¶': 'ö',
            'Ã\x83\x9c': 'Ü',
            'Ã\x83\x84': 'Ä',
            'Ã\x83\x96': 'Ö',
            'Ã\x83\x9f': 'ß',
            'Ã\x83\xc6\x92\xc3\x85\xe2\x80\x9c': 'Ü', # Extreme corruption!
            '': 'ü', # Fallback for unknown
        }
        
        # We can also do a targeted replace for common words
        # but the safest is to just do a manual string replace on the file contents
        # Since python's string replace is easy:
        fixed_text = text
        
        # Actually, let's try a custom error handler for the encoding
        def lossy_reverse(t):
            res = ""
            i = 0
            while i < len(t):
                try:
                    # Try to encode 2 characters (often a UTF-8 sequence became 2 cp1252 chars)
                    if i + 1 < len(t):
                        b = t[i:i+2].encode('cp1252')
                        decoded = b.decode('utf-8')
                        res += decoded
                        i += 2
                        continue
                except:
                    pass
                res += t[i]
                i += 1
            return res

        # A better approach: just manually map the broken strings we know
        pass
