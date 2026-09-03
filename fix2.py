import os
import re

path = 'lib/presentation/widgets/responsive_shell.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Replace WindowCaption with SizedBox(child: WindowCaption)
text = re.sub(r"WindowCaption\(\s*brightness: Theme\.of\(context\)\.brightness,\s*backgroundColor: Theme\.of\(context\)\.colorScheme\.surface,\s*\),", 
              "SizedBox(height: 32, child: WindowCaption(brightness: Theme.of(context).brightness, backgroundColor: Theme.of(context).colorScheme.surface, title: const Text(''))),", text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed!")
