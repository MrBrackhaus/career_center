import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/document_sanitizer_service.dart';

void main() {
  group('DocumentSanitizerService - sanitizeHtml', () {
    test('Entfernt HTML-Tags und gibt reinen Text zurück', () {
      const html = '<html><body><h1>Stellenanzeige</h1><p>Wir suchen einen Entwickler.</p></body></html>';
      final result = DocumentSanitizerService.sanitizeHtml(html);

      expect(result, contains('Stellenanzeige'));
      expect(result, contains('Wir suchen einen Entwickler'));
      expect(result, isNot(contains('<h1>')));
      expect(result, isNot(contains('<p>')));
    });

    test('Gibt Plaintext unverändert zurück', () {
      const plainText = 'Das ist normaler Text ohne HTML';
      final result = DocumentSanitizerService.sanitizeHtml(plainText);

      expect(result, plainText);
    });

    test('Verarbeitet DOCTYPE korrekt', () {
      const html = '<!DOCTYPE html><html><body>Inhalt</body></html>';
      final result = DocumentSanitizerService.sanitizeHtml(html);

      expect(result, contains('Inhalt'));
      expect(result, isNot(contains('DOCTYPE')));
    });

    test('Normalisiert Whitespace aus HTML', () {
      const html = '<div>  Viel    Whitespace   hier  </div>';
      final result = DocumentSanitizerService.sanitizeHtml(html);

      // Mehrfache Leerzeichen sollten auf eines reduziert werden
      expect(result, isNot(contains('  ')));
      expect(result, contains('Viel'));
      expect(result, contains('Whitespace'));
    });

    test('Verarbeitet leeren HTML-Body ohne Absturz', () {
      const html = '<html><body></body></html>';
      final result = DocumentSanitizerService.sanitizeHtml(html);

      expect(result, isNotNull);
    });

    test('Gibt leeren String bei leerem Input zurück', () {
      final result = DocumentSanitizerService.sanitizeHtml('');
      expect(result, '');
    });

    test('Verarbeitet verschachteltes HTML mit Links und Tabellen', () {
      const html = '''
        <html><body>
          <table><tr><td>Firma</td><td>Musterfirma GmbH</td></tr></table>
          <a href="https://example.com">Zur Stellenanzeige</a>
        </body></html>
      ''';
      final result = DocumentSanitizerService.sanitizeHtml(html);

      expect(result, contains('Musterfirma GmbH'));
      expect(result, contains('Zur Stellenanzeige'));
      expect(result, isNot(contains('<table>')));
      expect(result, isNot(contains('href')));
    });
  });
}
