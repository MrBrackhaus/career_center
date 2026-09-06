import 'dart:convert';
import 'package:http/http.dart' as http;

class AiCorrectionService {
  

  Future<String?> correctText(String text, String language, String baseUrl, String modelName) async {
    if (text.trim().isEmpty) return null;

    String prompt;
    if (language == 'de') {
      prompt = 'Du bist ein extrem pingeliger, professioneller Lektor für deutsche Bewerbungen. Deine EINZIGE Aufgabe ist es, ECHTE Rechtschreib- und Grammatikfehler im folgenden Text zu korrigieren. ÄNDERE NIEMALS den Schreibstil, ersetze KEINE korrekt geschriebenen Wörter durch Synonyme und erfinde keine Fakten! Behalte den originalen Text exakt so bei, bis auf die korrigierten Fehler. Antworte AUSSCHLIESSLICH mit dem korrigierten Text, ohne Einleitung, ohne Kommentare, ohne Formatierungen:\n\n' + text;
    } else if (language == 'en') {
      prompt = 'You are a highly meticulous, professional proofreader for English job applications. Your SOLE task is to correct ACTUAL spelling and grammatical errors in the following text. NEVER change the writing style, do NOT replace correctly spelled words with synonyms, and do not invent facts! Keep the original text exactly as it is, except for the corrected errors. Respond EXCLUSIVELY with the corrected text, without introduction, without comments, without formatting:\n\n' + text;
    } else if (language == 'fr') {
      prompt = 'Vous êtes un correcteur professionnel très méticuleux pour les candidatures en français. Votre SEULE tâche est de corriger les VÉRITABLES fautes d\'orthographe et de grammaire dans le texte suivant. Ne modifiez JAMAIS le style d\'écriture, ne remplacez PAS les mots correctement orthographiés par des synonymes et n\'inventez pas de faits ! Gardez le texte original exactement tel quel, à l\'exception des erreurs corrigées. Répondez EXCLUSIVEMENT avec le texte corrigé, sans introduction, sans commentaires, sans mise en forme :\n\n' + text;
    } else if (language == 'es') {
      prompt = 'Eres un corrector profesional muy meticuloso para solicitudes de empleo en español. Tu ÚNICA tarea es corregir errores REALES de ortografía y gramática en el siguiente texto. ¡NUNCA cambies el estilo de escritura, NO reemplaces palabras correctamente escritas por sinónimos y no inventes hechos! Mantén el texto original exactamente como está, excepto por los errores corregidos. Responde EXCLUSIVAMENTE con el texto corregido, sin introducción, sin comentarios, sin formato:\n\n' + text;
    } else {
      // Generic fallback
      prompt = 'Please correct the grammar and spelling in this text. Respond only with the corrected text, nothing else:\n\n' + text;
    }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': modelName,
          'prompt': prompt,
          'stream': false
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response']?.toString().trim();
      } else {
        throw Exception('AI Server returned status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('KI-Fehler: $e');
    }
  }
}
