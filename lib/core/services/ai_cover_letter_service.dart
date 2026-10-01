import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import 'ai_endpoint.dart';

/// Typische KI-Einleitungen ("Hier ist Ihr Anschreiben:"), die nur am
/// Anfang der Antwort (erste Zeile) entfernt werden.
final List<RegExp> _preamblePatterns = [
  RegExp(r'^\s*Hier ist[^\n]*?:[ \t]*', caseSensitive: false),
  RegExp(r'^\s*Ich kann Ihnen[^\n]*?:[ \t]*', caseSensitive: false),
  RegExp(r'^\s*Bitte beachten Sie[^\n]*?:[ \t]*', caseSensitive: false),
];

/// Bereinigt den reinen Antworttext der KI: entfernt Markdown-Fettdruck-Marker
/// (der Text dazwischen bleibt erhalten) und Einleitungen am Anfang.
String cleanCoverLetterText(String text) {
  var result = text;

  // Nur die **-Marker entfernen, nicht den fett gedruckten Text.
  result = result.replaceAllMapped(
    RegExp(r'\*\*(.*?)\*\*', dotAll: true),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAll('**', '');

  // Einleitungen nur am Anfang der Antwort entfernen.
  bool changed = true;
  while (changed) {
    changed = false;
    for (final pattern in _preamblePatterns) {
      final stripped = result.replaceFirst(pattern, '');
      if (stripped != result) {
        result = stripped;
        changed = true;
      }
    }
  }

  return result.trim();
}

String processAiResponse(List<int> bodyBytes) {
  try {
    final decodedString = utf8.decode(bodyBytes);
    final jsonResponse = jsonDecode(decodedString);
    String result = '';
    if (jsonResponse is Map) {
      final choices = jsonResponse['choices'];
      if (choices is List && choices.isNotEmpty) {
        // OpenAI-kompatible Antwort
        result = choices.first['message']?['content']?.toString() ?? '';
      } else {
        // Ollama-Antwort
        result = jsonResponse['response']?.toString() ?? '';
      }
    }

    return cleanCoverLetterText(result);
  } catch (e) {
    return 'Fehler: Die KI hat eine ungültige Antwort gesendet.';
  }
}

class AiCoverLetterService {
  Future<String> generateCoverLetter({
    required String baseUrl,
    required String modelName,
    required String userProfile,
    required String company,
    required String position,
    required String jobDescription,
    String apiKey = '',
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

    // Endpunkt ausschließlich aus der konfigurierten URL ableiten.
    final endpoint = AiEndpoint.resolve(baseUrl);
    final Map<String, dynamic> body = endpoint.isOpenAiCompatible
        ? {
            'model': modelName.isEmpty ? 'gpt-4o-mini' : modelName,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
            'temperature': 0.3,
          }
        : {
            'model': modelName,
            'prompt': userPrompt,
            'system': systemPrompt,
            'stream': false,
            'options': {'temperature': 0.3},
          };

    final response = await http.post(
      endpoint.uri,
      headers: endpoint.headers(apiKey),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return await compute(processAiResponse, response.bodyBytes);
    } else {
      throw Exception(
        'Fehler beim Generieren: ${response.statusCode} ${response.body}',
      );
    }
  }
}
