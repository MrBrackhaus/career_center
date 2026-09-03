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
    
    # Replace all loc.something with AppLocalizations.of(context)!.something
    text = re.sub(r"\bloc\.([a-zA-Z0-9_]+)", r"AppLocalizations.of(context)!.\1", text)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

print("Fixed scope issues globally!")
