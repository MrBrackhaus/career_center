path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re

# We will use re.sub with dotall to match the whole block since it's just strings
text = re.sub(
    r"const\s+Text\s*\(\s*'[^']*KI Prompt Generator',\s*style:\s*[^)]+\)\s*\)\s*,\s*const\s+SizedBox\s*\(\s*height:\s*8\s*\)\s*,\s*const\s+Text\s*\(\s*'[^']+',\s*'[^']+',\s*style:\s*TextStyle\s*\(\s*color:\s*Colors.grey\s*\)\s*,\s*\)",
    r"Text('🤖 ' + AppLocalizations.of(context)!.promptTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(AppLocalizations.of(context)!.promptSubtitle, style: const TextStyle(color: Colors.grey))",
    text
)

# wait, the first part is:
# const Text('🤖 KI Prompt Generator', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
# Let's write a simpler regex

text = re.sub(
    r"const Text\('[^']*KI Prompt Generator',\s*style:\s*[^)]+\)\),",
    r"Text('🤖 ' + AppLocalizations.of(context)!.promptTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),",
    text
)

text = re.sub(
    r"const Text\(\s*'Fülle die Felder aus[^']+',\s*'[^']+',\s*style:\s*TextStyle\(color:\s*Colors\.grey\),\s*\),",
    r"Text(AppLocalizations.of(context)!.promptSubtitle, style: const TextStyle(color: Colors.grey)),",
    text
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Done")
