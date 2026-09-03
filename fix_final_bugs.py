# -*- coding: utf-8 -*-
path_form = 'lib/presentation/screens/applications/application_form_screen.dart'
with open(path_form, 'r', encoding='utf-8') as f:
    text = f.read()

if 'app_localizations.dart' not in text:
    text = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n" + text

with open(path_form, 'w', encoding='utf-8') as f:
    f.write(text)

path_docs = 'lib/presentation/screens/applications/widgets/documents_widget.dart'
with open(path_docs, 'r', encoding='utf-8') as f:
    text2 = f.read()

text2 = text2.replace("const typeGroup = XTypeGroup(", "final typeGroup = XTypeGroup(")

with open(path_docs, 'w', encoding='utf-8') as f:
    f.write(text2)

print("Fixed imports and const in documents_widget!")
