import os

path = 'lib/presentation/widgets/responsive_shell.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("SizedBox(height: 32,", "SizedBox(width: double.infinity, height: 32,")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed again!")
