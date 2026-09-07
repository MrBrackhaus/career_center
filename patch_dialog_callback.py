import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/widgets/ai_cover_letter_dialog.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace('final Application application;', 'final Function(String) onCoverLetterGenerated;')
text = text.replace('required this.application,', 'required this.onCoverLetterGenerated,')

save_logic_old = """      // Save to application
      final appDao = ref.read(databaseProvider).applicationsDao;
      await appDao.updateApplication(widget.application.copyWith(coverLetterContent: drift.Value(deltaJson)));"""

save_logic_new = """      // Callback to form
      widget.onCoverLetterGenerated(deltaJson);"""

text = text.replace(save_logic_old, save_logic_new)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Dialog patched!")
