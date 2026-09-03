# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

if "import '../../l10n/app_localizations.dart';" not in text:
    text = text.replace("import '../../providers/database_provider.dart';", "import '../../providers/database_provider.dart';\nimport '../../l10n/app_localizations.dart';")

text = text.replace("Widget build(BuildContext context, WidgetRef ref) {", "Widget build(BuildContext context, WidgetRef ref) {\n    final loc = AppLocalizations.of(context)!;")

text = text.replace("'Vorlagen & Anschreiben'", "loc.templatesTitle")
text = text.replace("'Neue Vorlage'", "loc.templatesNew")
text = text.replace("'Noch keine Vorlagen erstellt.'", "loc.templatesEmpty")
text = text.replace("'Erstelle Dein erstes Anschreiben oder einen Textbaustein!'", "loc.templatesCreateFirst")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Templates patched!")
