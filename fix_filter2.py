path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re

# Fix matchesStatus
text = re.sub(r'final matchesStatus = _statusFilter == AppLocalizations\.of\(context\)!\.appFilterAll \|\|\s+app\.status\.toLowerCase\(\) == \(_statusFilter\?\.toLowerCase\(\)\);', 
              'final matchesStatus = _statusFilter == null || _statusFilter == AppLocalizations.of(context)!.appFilterAll || app.status.toLowerCase() == _statusFilter?.toLowerCase();', text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
