# -*- coding: utf-8 -*-
import os
import re

files = [
    'lib/presentation/screens/dashboard/dashboard_screen.dart',
    'lib/presentation/screens/settings/settings_screen.dart',
    'lib/presentation/screens/reports/jobcenter_report_screen.dart',
    'lib/presentation/screens/templates/templates_screen.dart',
    'lib/presentation/screens/calendar/calendar_screen.dart',
]

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    
    # Fix imports
    text = text.replace("import '../../l10n/app_localizations.dart';", "import '../../../l10n/app_localizations.dart';")
    
    # Fix undefined loc in DashboardScreen
    if "dashboard_screen" in path:
        text = text.replace("Widget _buildStatCard(BuildContext context, String value, String title)", "Widget _buildStatCard(BuildContext context, String value, String title, [AppLocalizations? loc])")
        text = text.replace("loc.dashboardRejections", "AppLocalizations.of(context)!.dashboardRejections")
        text = text.replace("loc.dashboardOverview", "AppLocalizations.of(context)!.dashboardOverview")
        text = text.replace("loc.dashboardTopRejectionReasons", "AppLocalizations.of(context)!.dashboardTopRejectionReasons")
        text = text.replace("loc.dashboardNoRejectionReasons", "AppLocalizations.of(context)!.dashboardNoRejectionReasons")

    # Fix const everywhere
    text = re.sub(r"const\s+Widget\s+child", "Widget child", text)
    text = re.sub(r"const\s+Padding\(", "Padding(", text)
    text = re.sub(r"const\s+ListTile\(", "ListTile(", text)
    text = re.sub(r"const\s+Center\(", "Center(", text)
    text = re.sub(r"const\s+DropdownMenuItem\(", "DropdownMenuItem(", text)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

print("Fixed imports, scope, and more const!")
