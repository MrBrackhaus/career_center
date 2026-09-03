# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/settings/settings_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

if "import '../../l10n/app_localizations.dart';" not in text:
    text = text.replace("import '../../providers/theme_provider.dart';", "import '../../providers/theme_provider.dart';\nimport '../../l10n/app_localizations.dart';")

if "final loc = AppLocalizations.of(context)!;" not in text:
    text = text.replace("Widget build(BuildContext context, WidgetRef ref) {", "Widget build(BuildContext context, WidgetRef ref) {\n    final loc = AppLocalizations.of(context)!;")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Settings patched 2!")
