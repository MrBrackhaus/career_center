import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/ai_cover_letter_service.dart';

void main() {
  group('AiCoverLetterService - Post-Processing', () {
    test('Entfernt Markdown (fett) aus der Antwort', () {
      final jsonStr = jsonEncode({
        'response': '**Betreff:** Bewerbung als Entwickler\n\nSehr geehrte Damen und Herren,'
      });
      final bytes = utf8.encode(jsonStr);
      final result = processAiResponse(bytes);
      
      expect(result, 'Bewerbung als Entwickler\n\nSehr geehrte Damen und Herren,');
    });

    test('Entfernt typische KI-Gesprächsfetzen (Einleitungen)', () {
      final jsonStr = jsonEncode({
        'response': 'Hier ist ein Anschreiben für Sie:\n\nSehr geehrte Frau Müller,'
      });
      final bytes = utf8.encode(jsonStr);
      final result = processAiResponse(bytes);
      
      expect(result, 'Sehr geehrte Frau Müller,');
    });

    test('Behält reinen Text exakt bei', () {
      final jsonStr = jsonEncode({
        'response': 'Sehr geehrter Herr Schmidt,\nhiermit bewerbe ich mich.'
      });
      final bytes = utf8.encode(jsonStr);
      final result = processAiResponse(bytes);
      
      expect(result, 'Sehr geehrter Herr Schmidt,\nhiermit bewerbe ich mich.');
    });

    test('Fängt ungültiges JSON (z.B. Proxy HTML Fehler) ab ohne abzustürzen', () {
      final bytes = utf8.encode('<html><body>502 Bad Gateway</body></html>');
      final result = processAiResponse(bytes);
      
      expect(result, 'Fehler: Die KI hat eine ungültige Antwort gesendet.');
    });

    test('Verarbeitet JSON ohne response Feld', () {
      final jsonStr = jsonEncode({
        'error': 'API limit exceeded'
      });
      final bytes = utf8.encode(jsonStr);
      final result = processAiResponse(bytes);
      
      expect(result, '');
    });
  });
}
