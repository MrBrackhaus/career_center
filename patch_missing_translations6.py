# -*- coding: utf-8 -*-
import os

path_dashboard = 'lib/presentation/screens/dashboard/dashboard_screen.dart'
with open(path_dashboard, 'r', encoding='utf-8') as f:
    dashboard_text = f.read()

# Fix Wochenziel: $current von $goal Bewerbungen
dashboard_text = dashboard_text.replace(
    "'Wochenziel: $current von $goal Bewerbungen'",
    "AppLocalizations.of(context)!.weeklyGoal + ' $current ' + AppLocalizations.of(context)!.weeklyGoalSuffix"
)
# Fix Diese Woche $current Bewerbungen vs. letzte Woche $last Bewerbungen
dashboard_text = dashboard_text.replace(
    "'Diese Woche $current Bewerbungen vs. letzte Woche $last Bewerbungen'",
    "AppLocalizations.of(context)!.weeklyThisWeek + '$current' + AppLocalizations.of(context)!.weeklyVs + '$last' + AppLocalizations.of(context)!.weeklyApplications"
)
# Fix "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job." - wait, the python script earlier DID replace it! We just saw `weeklyMotivationalFooterNoIcon` in the Select-String output!
# Wait, let's make sure it's fully replaced.

with open(path_dashboard, 'w', encoding='utf-8') as f:
    f.write(dashboard_text)


path_report = 'lib/presentation/screens/reports/jobcenter_report_screen.dart'
with open(path_report, 'r', encoding='utf-8') as f:
    report_text = f.read()

report_text = report_text.replace(
    "'Generiert am: $nowString Uhr${_userName.isNotEmpty ? ' | Name: $_userName' : ''}'",
    "AppLocalizations.of(context)!.reportGeneratedAt + ' $nowString' + AppLocalizations.of(context)!.reportTimeSuffix + (_userName.isNotEmpty ? ' | Name: $_userName' : '')"
)
report_text = report_text.replace(
    "'No applications found.'",
    "AppLocalizations.of(context)!.noAppsFound" # Use an existing string if possible, or we'll create it
)

with open(path_report, 'w', encoding='utf-8') as f:
    f.write(report_text)


path_templates = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path_templates, 'r', encoding='utf-8') as f:
    templates_text = f.read()

templates_text = templates_text.replace("'No templates created yet.'", "AppLocalizations.of(context)!.templatesEmptyState")
templates_text = templates_text.replace("'Create your first cover letter or text snippet!'", "AppLocalizations.of(context)!.templatesEmptyStateSub")

with open(path_templates, 'w', encoding='utf-8') as f:
    f.write(templates_text)

print("Patched dart files manually!")
