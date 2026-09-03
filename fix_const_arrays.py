# -*- coding: utf-8 -*-
import os
import re

files = [
    'lib/presentation/screens/dashboard/dashboard_screen.dart',
    'lib/presentation/screens/settings/settings_screen.dart',
    'lib/presentation/screens/reports/jobcenter_report_screen.dart',
    'lib/presentation/screens/templates/templates_screen.dart',
    'lib/presentation/screens/calendar/calendar_screen.dart',
    'lib/presentation/screens/applications/applications_screen.dart',
]

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    
    # We will just remove const [ and replace it with [ if we find AppLocalizations inside the array.
    # Actually, the easiest is to just remove `const` before `[` and `DataColumn` etc.
    text = text.replace("const [", "[")
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

print("Removed const from lists!")
