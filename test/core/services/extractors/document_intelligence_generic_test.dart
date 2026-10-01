import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/document_intelligence_service.dart';
import 'package:career_center/core/services/document_sanitizer_service.dart';

void main() {
  group('DocumentIntelligenceService - generische Extraktion', () {
    final service = DocumentIntelligenceService();

    test('Kleingeschriebene Satzwörter nach "Kontakt" sind kein Name', () {
      final fields = service.extractGeneric(
        'Zertifikat\nIhr Kontakt zu uns ist jederzeit möglich.\nRecruiter sind gern behilflich.',
      );
      expect(fields.contactName, isNull);
    });

    test('Informeller Kontakt mit echtem Namen wird erkannt', () {
      final fields = service.extractGeneric(
        'Zertifikat\nihr ansprechpartner: Jonas Bauer\n',
      );
      expect(fields.contactName?.value, 'Jonas Bauer');
    });

    test('Geburtsdatum ist keine Telefonnummer', () {
      final fields = service.extractGeneric(
        'Lebenslauf\nGeboren am 15.03.1990 in Bremen\n',
      );
      expect(fields.contactPhone, isNull);
    });

    test('Telefon mit Kontext wird erkannt', () {
      final fields = service.extractGeneric(
        'Lebenslauf\nMobil: +49 171 2345678\nE-Mail: a@b.de',
      );
      expect(fields.contactPhone?.value, '+49 171 2345678');
    });
  });

  group('DocumentIntelligenceService - Modell laden', () {
    test('Beschädigtes Modell-JSON liefert null statt TypeError', () {
      expect(DocumentIntelligenceService.parseUserModel({'wordCounts': 5}), isNull);
      expect(DocumentIntelligenceService.parseUserModel('kaputt'), isNull);
      expect(DocumentIntelligenceService.parseUserModel(null), isNull);
    });
  });

  group('DocumentSanitizerService.sanitizeHtml', () {
    test('Entfernt script-, style- und noscript-Inhalte', () {
      const html = '<html><head><style>p{color:red}</style><script>var a = 1;</script></head>'
          '<body><noscript>JS aktivieren</noscript><p>Hallo Welt</p><script>track()</script></body></html>';
      expect(DocumentSanitizerService.sanitizeHtml(html), 'Hallo Welt');
    });
  });
}
