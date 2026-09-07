import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/widgets/basic_data_tab.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace('application: bundle.application,', 'onCoverLetterGenerated: bundle.onCoverLetterGenerated,')

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Tab logic patched!")
