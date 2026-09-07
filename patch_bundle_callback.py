import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/application_form_state_bundle.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Add callback
text = text.replace('final VoidCallback onAutoFillFromUrl;', 'final VoidCallback onAutoFillFromUrl;\n  final Function(String) onCoverLetterGenerated;')
text = text.replace('required this.onAutoFillFromUrl,', 'required this.onAutoFillFromUrl,\n    required this.onCoverLetterGenerated,')

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Callback added!")
