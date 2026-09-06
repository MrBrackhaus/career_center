import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/editor/application_editor_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# 1. Add imports
imports_to_add = """
import '../../providers/ai_correction_provider.dart';
import '../../providers/document_template_provider.dart';
import 'package:intl/intl.dart';
"""
text = text.replace("import 'package:http/http.dart' as http;", imports_to_add)

# 2. Refactor _runAiCorrection
old_ai_correction = """  Future<void> _runAiCorrection() async {
    final text = _controller.document.toPlainText();
    if (text.trim().isEmpty) return;
    setState(() => _isCorrecting = true);
    try {
      final url = Uri.parse('http://localhost:11434/api/generate');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'model': 'llama3', 'prompt': 'Du bist ein extrem pingeliger, professioneller Lektor für deutsche Bewerbungen. Deine EINZIGE Aufgabe ist es, ECHTE Rechtschreib- und Grammatikfehler im folgenden Text zu korrigieren. ÄNDERE NIEMALS den Schreibstil, ersetze KEINE korrekt geschriebenen Wörter durch Synonyme und erfinde keine Fakten! Behalte den originalen Text exakt so bei, bis auf die korrigierten Fehler. Antworte AUSSCHLIESSLICH mit dem korrigierten Text, ohne Einleitung, ohne Kommentare, ohne Formatierungen:\\n\\n' + text, 'stream': false}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final correctedText = data['response']?.toString().trim();
        if (correctedText != null && correctedText.isNotEmpty) {
          final length = _controller.document.length;
          _controller.replaceText(0, length - 1, correctedText, const TextSelection.collapsed(offset: 0));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('KI-Fehler: $e')));
    } finally {
      if (mounted) setState(() => _isCorrecting = false);
    }
  }"""

new_ai_correction = """  Future<void> _runAiCorrection() async {
    final text = _controller.document.toPlainText();
    if (text.trim().isEmpty) return;
    
    final lang = SpellChecker.currentLanguage;
    final correctedText = await ref.read(aiCorrectionProvider.notifier).correctText(text, lang);
    
    if (correctedText != null && correctedText.isNotEmpty && mounted) {
      final length = _controller.document.length;
      _controller.replaceText(0, length - 1, correctedText, const TextSelection.collapsed(offset: 0));
    }
  }"""

if old_ai_correction in text:
    text = text.replace(old_ai_correction, new_ai_correction)
else:
    print("Could not find _runAiCorrection exact match! Will try generic replace.")
    # Generic replace just in case (fallback)
    import re
    text = re.sub(r'  Future<void> _runAiCorrection\(\) async \{.*?\n  \}', new_ai_correction, text, flags=re.DOTALL)

# 3. Refactor _insertHeader
old_header = """  void _insertHeader() {
    final date = "${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}";
    final headerText = "Max Mustermann * Musterstrasse 1 * 12345 Musterstadt\\n\\n"
        "${_application?.company ?? 'Unternehmensname'}\\n"
        "Personalabteilung\\n"
        "Musterstrasse 2\\n"
        "12345 Musterstadt\\n\\n\\n\\n"
        "Musterstadt, den $date\\n\\n"
        "Bewerbung als ${_application?.position ?? 'Position'}\\n\\n"
        "Sehr geehrte Damen und Herren,\\n\\n";

    _controller.document.insert(0, headerText);
    
    final subjectStart = headerText.indexOf('Bewerbung als');
    final subjectEnd = headerText.indexOf('\\n', subjectStart);
    if (subjectStart != -1) {
      _controller.formatText(subjectStart, subjectEnd - subjectStart, const quill.Attribute('bold', true));
    }
  }"""

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
      _controller.formatText(subjectStart, subjectEnd - subjectStart, const quill.Attribute('bold', true));
    }
  }"""

text = text.replace(old_header, new_header)

# Also need to fix where _insertHeader is called (it was synchronous, now it's async)
text = text.replace("onPressed: _insertHeader,", "onPressed: () => _insertHeader(),")

# 4. Handle global errors from AI
# We need to listen to aiCorrectionProvider errors.
error_listener = """
    // Listen for AI errors
    ref.listen<AiCorrectionState>(aiCorrectionProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });
"""

# Insert error_listener in build method
build_method_start = """  @override
  Widget build(BuildContext context) {"""
new_build_method = build_method_start + error_listener
text = text.replace(build_method_start, new_build_method)

# Change _isCorrecting usage in UI
text = text.replace("_isCorrecting", "ref.watch(aiCorrectionProvider).isCorrecting")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Editor refactored.")
