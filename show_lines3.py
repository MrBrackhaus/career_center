# -*- coding: utf-8 -*-
with open('lib/presentation/screens/settings/settings_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i in range(460, 480):
    print(f"{i+1}: {lines[i].strip()}")
