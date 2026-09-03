# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/reports/jobcenter_report_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

if "import '../../l10n/app_localizations.dart';" not in text:
    text = text.replace("import '../../providers/database_provider.dart';", "import '../../providers/database_provider.dart';\nimport '../../l10n/app_localizations.dart';")

text = text.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final loc = AppLocalizations.of(context)!;")

text = text.replace("'Nachweis Eigenbemühungen'", "loc.reportTitle")
text = text.replace("'Nachweis EigenbemǬhungen'", "loc.reportTitle")
text = text.replace("'PDF Speichern'", "loc.reportSavePdf")
text = text.replace("'BEWERBUNGSDATUM'", "loc.reportDate")
text = text.replace("'UNTERNEHMEN'", "loc.reportCompany")
text = text.replace("'BEWORBENE POSITION'", "loc.reportPosition")
text = text.replace("'AKTUELLER STATUS'", "loc.reportStatus")
text = text.replace("'ABSAGEGRUND'", "loc.reportRejectionReason")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Report patched!")
