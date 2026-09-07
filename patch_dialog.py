import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/widgets/ai_cover_letter_dialog.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace("import 'package:flutter_quill/flutter_quill.dart' as quill;", "import 'package:flutter_quill/flutter_quill.dart' as quill;\nimport 'package:drift/drift.dart' as drift;")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
