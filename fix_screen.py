path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Fix imports
text = text.replace("import 'package:flutter_gen/gen_l10n/app_localizations.dart';", "import 'package:career_center/l10n/app_localizations.dart';")

# Fix isLoading
text = text.replace("syncState.isSyncing", "syncState.isLoading")

# Fix DropdownMenuItem cast
text = text.replace("items: statusOptions.map((String status) {", "items: statusOptions.map<DropdownMenuItem<String>>((String status) {")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Fixed applications_screen.dart!")
