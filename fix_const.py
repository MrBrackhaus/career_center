import os
import re

files = [
    'lib/presentation/screens/dashboard/dashboard_screen.dart',
    'lib/presentation/screens/settings/settings_screen.dart',
    'lib/presentation/screens/reports/jobcenter_report_screen.dart',
    'lib/presentation/screens/templates/templates_screen.dart',
    'lib/presentation/screens/calendar/calendar_screen.dart',
]

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    
    # Fix const Text(loc...) -> Text(loc...)
    text = re.sub(r"const\s+Text\s*\(\s*loc\.", "Text(loc.", text)
    # Fix const Tab(text: loc...) -> Tab(text: loc...)
    text = re.sub(r"const\s+Tab\s*\(\s*text:\s*loc\.", "Tab(text: loc.", text)
    # Fix const InputDecoration(labelText: loc...) -> InputDecoration(labelText: loc...)
    text = re.sub(r"const\s+InputDecoration\s*\(\s*labelText:\s*loc\.", "InputDecoration(labelText: loc.", text)
    # Generic const wrapper fix
    text = re.sub(r"const\s+([A-Za-z0-9_]+)\s*\(([^)]*loc\.[^)]*)\)", r"\1(\2)", text)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

print("Removed const modifiers!")
