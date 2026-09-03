path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip_count = 0
for i, line in enumerate(lines):
    if skip_count > 0:
        skip_count -= 1
        continue
    if "Fülle die Felder aus" in line:
        new_lines.append("          Text(AppLocalizations.of(context)!.promptSubtitle, style: const TextStyle(color: Colors.grey)),\n")
        skip_count = 4 # Skip the next 4 lines which contain the rest of the Text widget
    else:
        new_lines.append(line)

with open(path, 'w', encoding='utf-8') as f:
    f.write(''.join(new_lines))
print("Done")
