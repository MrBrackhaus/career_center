path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('AppLocalizations.of(context)!.promptCopied', '"In die Zwischenablage kopiert!"')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed promptCopied")
