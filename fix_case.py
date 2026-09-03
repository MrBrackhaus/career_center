path = 'lib/presentation/screens/applications/application_form_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("case AppLocalizations.of(context)!.promptCompany:", "case 'Firma':")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed case 'Firma'")
