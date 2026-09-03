path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Fix the title
import re
text = re.sub(r"const\s+Text\s*\(\s*'🤖\s+KI\s+Prompt\s+Generator'[^)]*\)", "Text('🤖 ' + AppLocalizations.of(context)!.promptTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))", text)

# Fix the subtitle
# The subtitle is:
# 'Fülle die Felder aus und generiere einen professionellen Prompt, '
# 'den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst.'
# We can just use a regex to replace the Text widget content.
text = re.sub(r"Text\(\s*'Fülle die Felder aus[^)]*\)\s*,\s*style:\s*Theme\.of\(context\)\.textTheme\.bodyMedium\?.copyWith\(color:\s*Colors\.grey\)\s*\)", "Text(AppLocalizations.of(context)!.promptSubtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey))", text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed templates_screen.dart prompt texts")
