import re
import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/editor/application_editor_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

new_header = """  Future<void> _insertHeader() async {
    final lang = SpellChecker.currentLanguage;
    final templateService = ref.read(documentTemplateServiceProvider);
    final headerText = await templateService.generateHeader(_application, lang);
    
    _controller.document.insert(0, headerText);
    
    // Bold the subject line dynamically based on language
    String subjectPrefix;
    if (lang == 'en') subjectPrefix = 'Application for ';
    else if (lang == 'fr') subjectPrefix = 'Candidature pour le poste de ';
    else if (lang == 'es') subjectPrefix = 'Candidatura para el puesto de ';
    else subjectPrefix = 'Bewerbung als ';
    
    final subjectStart = headerText.indexOf(subjectPrefix);
    final subjectEnd = headerText.indexOf('\\n', subjectStart);
    if (subjectStart != -1 && subjectEnd != -1) {
      _controller.formatText(subjectStart, subjectEnd - subjectStart, quill.Attribute.bold);
    }
  }"""

text = re.sub(r'  void _insertHeader\(\) \{.*?  \}', new_header, text, flags=re.DOTALL)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Header replaced")
