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
    
    # Remove const if it wraps AppLocalizations
    text = re.sub(r"const\s+([A-Za-z0-9_]+)\s*\(([^)]*AppLocalizations[^)]*)\)", r"\1(\2)", text)
    text = re.sub(r"const\s+Text\s*\(\s*AppLocalizations", r"Text(AppLocalizations", text)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

print("Removed remaining const!")
