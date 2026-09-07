import 'dart:convert';
import 'package:http/http.dart' as http;

class AiCoverLetterService {
  Future<String> generateCoverLetter({
    required String baseUrl,
    required String modelName,
    required String userProfile,
    required String company,
    required String position,
    required String jobDescription,
  }) async {
    final prompt = """Du bist ein professioneller Karriereberater und Experte im Schreiben von Bewerbungsanschreiben.
Deine Aufgabe ist es, ein vollständiges, überzeugendes und fehlerfreies Bewerbungsanschreiben zu verfassen.
Das Anschreiben MUSS den kompletten Briefkopf (Absender, Empfänger, Datum), einen passenden Betreff, die Anrede, den Hauptteil und die Schlussformel (Mit freundlichen Grüßen) enthalten.

Hier sind die Daten für das Anschreiben:

=== MEIN PROFIL (Absender & Lebenslauf) ===
$userProfile

=== STELLENANZEIGE (Empfänger & Anforderungen) ===
Firma: $company
Position: $position
Anforderungen & Beschreibung:
$jobDescription

=== ANWEISUNG ===
Schreibe das Anschreiben. Der Text soll professionell, motiviert und direkt auf die Anforderungen der Stelle eingehen. Verknüpfe meine Erfahrungen aus dem Lebenslauf intelligent mit den geforderten Skills der Stelle.
Formatiere das Ergebnis klar und sauber. Gib NUR das Anschreiben aus, ohne zusätzliche Kommentare.
""";

    final uri = Uri.parse(baseUrl);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'model': modelName,
        'prompt': prompt,
        'stream': false,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse['response'] ?? '';
    } else {
      throw Exception('Fehler beim Generieren: ${response.statusCode} ${response.body}');
    }
  }
}
