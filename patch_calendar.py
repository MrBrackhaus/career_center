# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/calendar/calendar_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

if "import '../../l10n/app_localizations.dart';" not in text:
    text = text.replace("import '../../providers/applications_provider.dart';", "import '../../providers/applications_provider.dart';\nimport '../../l10n/app_localizations.dart';")

text = text.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final loc = AppLocalizations.of(context)!;")

text = text.replace("'Bewerbungskalender'", "loc.calendarTitle")
text = text.replace("'Keine Termine an diesem Tag.'", "loc.calendarNoEvents")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Calendar patched!")
