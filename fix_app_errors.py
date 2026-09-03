# -*- coding: utf-8 -*-
path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    "onChanged: (value) => setState(() => _statusFilter = val == loc.appFilterAll ? null : value!),",
    "onChanged: (value) => setState(() => _statusFilter = value == loc.appFilterAll ? null : value),"
)

text = text.replace(
    "app.status.toLowerCase() == _statusFilter.toLowerCase();",
    "app.status.toLowerCase() == (_statusFilter?.toLowerCase());"
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed val -> value and _statusFilter nullable!")
