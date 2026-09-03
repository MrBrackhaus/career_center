# -*- coding: utf-8 -*-
path = 'lib/presentation/screens/settings/settings_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("child: const Row(", "child: Row(")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed const Row!")
