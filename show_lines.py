# -*- coding: utf-8 -*-
with open('lib/presentation/screens/applications/applications_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i in range(35, 55):
    print(f"{i+1}: {lines[i].strip()}")
