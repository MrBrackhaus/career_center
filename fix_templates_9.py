path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if "children: [" in line and "crossAxisAlignment: CrossAxisAlignment.start" in lines[i-1]:
        new_lines.append(line)
        new_lines.append("          Text('\U0001f916 ' + AppLocalizations.of(context)!.promptTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),\n")
        new_lines.append("          const SizedBox(height: 8),\n")
        new_lines.append("          Text(AppLocalizations.of(context)!.promptSubtitle, style: const TextStyle(color: Colors.grey)),\n")
        new_lines.append("          const SizedBox(height: 16),\n")
        new_lines.append("          TextField(\n")
        # We need to skip lines until we hit the TextField declaration. Wait, the TextField starts at line 205.
        skip = True
        continue
        
    if skip:
        if "controller: _promptPositionController," in line:
            skip = False
            new_lines.append(line)
        continue
        
    if not skip:
        new_lines.append(line)

with open(path, 'w', encoding='utf-8') as f:
    f.write(''.join(new_lines))
print("Fixed layout")
