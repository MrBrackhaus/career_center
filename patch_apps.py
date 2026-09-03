# -*- coding: utf-8 -*-
import os
import re

path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

if "import '../../l10n/app_localizations.dart';" not in text:
    text = text.replace("import 'widgets/application_list_item.dart';", "import 'widgets/application_list_item.dart';\nimport '../../l10n/app_localizations.dart';")

if "final loc = AppLocalizations.of(context)!;" not in text:
    text = text.replace("Widget build(BuildContext context, WidgetRef ref) {", "Widget build(BuildContext context, WidgetRef ref) {\n    final loc = AppLocalizations.of(context)!;")

text = text.replace("'Meine Bewerbungen'", "loc.applicationsTitle")
text = text.replace("'Bewerbungen'", "loc.applicationsTitle")
text = text.replace("'Neue Bewerbung'", "loc.btnNewApplication")
text = text.replace("'Suche nach Firma, Position, Ort...'", "loc.searchPlaceholder")
text = text.replace("'Noch keine Bewerbungen'", "loc.emptyApplicationsTitle")
text = text.replace("'Erste Bewerbung anlegen'", "loc.btnNewApplication")

# Fix const again
text = re.sub(r"const\s+Text\s*\(\s*loc\.", "Text(loc.", text)
text = re.sub(r"const\s+Padding\(", "Padding(", text)
text = re.sub(r"const\s+Center\(", "Center(", text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Applications screen patched!")
