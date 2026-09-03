# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/dashboard/dashboard_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Make sure AppLocalizations is imported
if "import '../../l10n/app_localizations.dart';" not in text:
    text = text.replace("import '../../providers/applications_provider.dart';", "import '../../providers/applications_provider.dart';\nimport '../../l10n/app_localizations.dart';")

# In build method
text = text.replace("Widget build(BuildContext context, WidgetRef ref) {\n    final stats = ref.watch(statsProvider);", 
                    "Widget build(BuildContext context, WidgetRef ref) {\n    final loc = AppLocalizations.of(context)!;\n    final stats = ref.watch(statsProvider);")

# Replace strings
text = text.replace("'Bewerbungs-Statistiken'", "loc.dashboardTitle")
text = text.replace("'ÜBERBLICK'", "loc.dashboardOverview")
text = text.replace("'oBERBLICK'", "loc.dashboardOverview")
text = text.replace("'BEWERBUNGEN'", "loc.dashboardApplications")
text = text.replace("'NOCH OFFEN'", "loc.dashboardOpen")
text = text.replace("'ABSAGEN'", "loc.dashboardRejections")
text = text.replace("'ANTWORTQUOTE'", "loc.dashboardResponseRate")
text = text.replace("'ABSAGEQUOTE'", "loc.dashboardRejectionRate")
text = text.replace("'INTERVIEWS'", "loc.dashboardInterviews")
text = text.replace("'Ø PENDELZEIT AUTO'", "loc.dashboardCommute")
text = text.replace("'BEWERBUNGEN PRO MONAT'", "loc.dashboardAppsPerMonth")
text = text.replace("'TOP ABSAGEGRÜNDE'", "loc.dashboardTopRejectionReasons")
text = text.replace("'Bisher keine Absagegründe erfasst.'", "loc.dashboardNoRejectionReasons")
text = text.replace("'TOP ABSAGEGRoNDE'", "loc.dashboardTopRejectionReasons")
text = text.replace("'Bisher keine AbsagegrǬnde erfasst.'", "loc.dashboardNoRejectionReasons")
text = text.replace("'~ PENDELZEIT AUTO'", "loc.dashboardCommute")
text = text.replace("'oBERBLICK'", "loc.dashboardOverview")


with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Dashboard patched!")
