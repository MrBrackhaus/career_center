import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/application_form_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Add _coverLetterContent
text = text.replace('String _status = \'offen\';', 'String _status = \'offen\';\n  String? _coverLetterContent;')

# Init
text = text.replace('_status = app.status;', '_status = app.status;\n      _coverLetterContent = app.coverLetterContent;')

# Add to companion
companion_target = "jobDescriptionText: drift.Value(_jobDescriptionTextController.text.isEmpty ? null : _jobDescriptionTextController.text),"
companion_replacement = companion_target + "\n      coverLetterContent: drift.Value(_coverLetterContent),"
if companion_target in text:
    text = text.replace(companion_target, companion_replacement)

# Add onCoverLetterGenerated callback to bundle creation
bundle_target = "onAutoFillFromUrl: _autoFillFromUrl,"
bundle_replacement = bundle_target + "\n        onCoverLetterGenerated: (deltaJson) => setState(() => _coverLetterContent = deltaJson),"
if bundle_target in text:
    text = text.replace(bundle_target, bundle_replacement)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Form state patched!")
