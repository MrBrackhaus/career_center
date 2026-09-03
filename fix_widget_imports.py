# -*- coding: utf-8 -*-
import os
import re

def fix_file(path, add_import=False):
    if not os.path.exists(path):
        return
        
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
        
    if add_import and 'app_localizations.dart' not in text:
        text = "import '../../../../l10n/app_localizations.dart';\n" + text
        
    # Remove const from DropdownMenuItem and DropdownButtonFormField items array
    # The error "Not a constant expression" means there is a `const [...]` array or `const DropdownMenuItem`
    text = re.sub(r"const\s+DropdownMenuItem", "DropdownMenuItem", text)
    text = re.sub(r"const\s+\[\s*DropdownMenuItem", "[DropdownMenuItem", text)
    text = re.sub(r"const\s+\[\s*Tab", "[Tab", text)
    
    # Check for const Center(child: Text(AppLocalizations...
    text = re.sub(r"const\s+Center\(\s*child:\s*Text\(AppLocalizations", r"Center(child: Text(AppLocalizations", text)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

fix_file('lib/presentation/screens/applications/widgets/basic_data_tab.dart', True)
fix_file('lib/presentation/screens/applications/widgets/documents_widget.dart', True)
fix_file('lib/presentation/screens/applications/widgets/emails_contacts_tab.dart', True)
fix_file('lib/presentation/screens/applications/widgets/emails_tab.dart', True)
fix_file('lib/presentation/screens/applications/widgets/contacts_widget.dart', True)
fix_file('lib/presentation/screens/applications/widgets/notes_widget.dart', True)

print("Fixed imports and consts in widgets!")
