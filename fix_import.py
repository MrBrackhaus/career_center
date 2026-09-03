import os

path = 'lib/presentation/screens/applications/application_form_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("import 'package:flutter_gen/gen_l10n/app_localizations.dart';", "import '../../../l10n/app_localizations.dart';")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed import in application_form_screen!")
