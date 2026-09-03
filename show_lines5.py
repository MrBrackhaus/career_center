# -*- coding: utf-8 -*-
with open('lib/presentation/screens/applications/widgets/documents_widget.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i in range(70, 90):
    if i < len(lines):
        print(f"{i+1}: {lines[i].strip()}")
