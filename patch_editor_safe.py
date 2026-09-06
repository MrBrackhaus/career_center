import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/editor/application_editor_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# 1. Imports
text = text.replace("import 'package:http/http.dart' as http;", "import '../../providers/ai_correction_provider.dart';\nimport '../../providers/document_template_provider.dart';\nimport 'package:intl/intl.dart';")

# 2. _runAiCorrection
old_ai = """  Future<void> _runAiCorrection() async {
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

new_ai = """  Future<void> _runAiCorrection() async {
    final text = _controller.document.toPlainText();
    if (text.trim().isEmpty) return;
    
    final lang = SpellChecker.currentLanguage;
    final correctedText = await ref.read(aiCorrectionProvider.notifier).correctText(text, lang);
    
    if (correctedText != null && correctedText.isNotEmpty && mounted) {
      final length = _controller.document.length;
      _controller.replaceText(0, length - 1, correctedText, const TextSelection.collapsed(offset: 0));
    }
  }"""

text = text.replace(old_ai, new_ai)

# 3. _insertHeader
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
      _controller.formatText(subjectStart, subjectEnd - subjectStart, quill.Attribute.bold);
    }
  }"""

new_header = """  Future<void> _insertHeader() async {
    final lang = SpellChecker.currentLanguage;
    final templateService = ref.read(documentTemplateServiceProvider);
    final headerText = await templateService.generateHeader(_application, lang);
    
    _controller.document.insert(0, headerText);
    
    String subjectPrefix = 'Bewerbung als ';
    if (lang == 'en') subjectPrefix = 'Application for ';
    else if (lang == 'fr') subjectPrefix = 'Candidature pour le poste de ';
    else if (lang == 'es') subjectPrefix = 'Candidatura para el puesto de ';
    
    final subjectStart = headerText.indexOf(subjectPrefix);
    final subjectEnd = headerText.indexOf('\\n', subjectStart);
    if (subjectStart != -1 && subjectEnd != -1) {
      _controller.formatText(subjectStart, subjectEnd - subjectStart, quill.Attribute.bold);
    }
  }"""

text = text.replace(old_header, new_header)
text = text.replace("onPressed: _insertHeader,", "onPressed: () => _insertHeader(),")

# 4. Global errors and loading state
build_old = "  Widget build(BuildContext context) {"
build_new = """  Widget build(BuildContext context) {
    ref.listen<AiCorrectionState>(aiCorrectionProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });
"""
text = text.replace(build_old, build_new)

text = text.replace("_isCorrecting", "ref.watch(aiCorrectionProvider).isCorrecting")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Safe patch applied.")
