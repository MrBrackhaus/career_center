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
    final systemPrompt = """Du bist ein professioneller Karriereberater. Deine einzige Aufgabe ist es, ein Bewerbungsanschreiben zu generieren.
REGELN:
1. ANTWORTE AUSSCHLIESSLICH MIT DEM TEXT DES ANSCHREIBENS!
2. KEINE Einleitungen wie "Hier ist Ihr Anschreiben".
3. KEINE Hinweise oder Kommentare am Ende.
4. Verwende für nicht vorhandene Daten Platzhalter wie [Name], [Adresse], etc. Erfinde keine Fakten.
5. Das Anschreiben muss komplett sein (Absender, Empfänger, Datum, Betreff, Anrede, Text, Grußformel).
6. KEINE Erklärungen. KEINE Entschuldigungen. NUR der Text des Anschreibens.""";

    final userPrompt =
        """Hier sind meine Daten:

=== MEIN PROFIL (Absender & Lebenslauf) ===
$userProfile

=== STELLENANZEIGE (Empfänger & Anforderungen) ===
Firma: $company
Position: $position
Beschreibung/Anforderungen:
$jobDescription

Schreibe nun das Anschreiben basierend auf diesen Daten.
""";

    final uri = Uri.parse(baseUrl);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'model': modelName,
        'prompt': userPrompt,
        'system': systemPrompt,
        'stream': false,
        'options': {'temperature': 0.3},
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      String result = jsonResponse['response'] ?? '';

      // Post-Processing um evtl. Markdown und Gesprächsfetzen zu entfernen
      result = result.replaceAll(
        RegExp(r'\*\*.*?\*\*'),
        '',
      ); // Entfernt fettgedruckte Hinweise wie **Anschreiben**
      result = result.replaceAll(
        RegExp(r'Hier ist.*?:', caseSensitive: false),
        '',
      );
      result = result.replaceAll(
        RegExp(r'Ich kann Ihnen.*?:', caseSensitive: false),
        '',
      );
      result = result.replaceAll(
        RegExp(r'Bitte beachten Sie.*?:', caseSensitive: false),
        '',
      );
      result = result.replaceAll(
        RegExp(r'Hier ist ein.*?:', caseSensitive: false),
        '',
      );

      return result.trim();
    } else {
      throw Exception(
        'Fehler beim Generieren: ${response.statusCode} ${response.body}',
      );
    }
  }
}
