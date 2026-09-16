import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/extractors/cover_letter_extractor.dart';

void main() {
  group('CoverLetterExtractor', () {
    test('Erkennt Stellenbezeichnung aus "Bewerbung als..." Zeile', () {
      const text = '''
Max Mustermann
Musterstraße 1
12345 Berlin

Musterfirma GmbH
Personalabteilung
Industriestr. 5
80331 München

Berlin, 15.09.2026

Bewerbung als Flutter Entwickler

Sehr geehrte Damen und Herren,

hiermit bewerbe ich mich auf die ausgeschriebene Stelle.

Mit freundlichen Grüßen
Max Mustermann
''';
      final result = CoverLetterExtractor.extract(text);

      expect(result.position, isNotNull);
      expect(result.position!.value.toLowerCase(), contains('flutter'));
    });

    test('Erkennt Datum im DD.MM.YYYY Format', () {
      const text = '''
Musterfirma GmbH
80331 München

Berlin, 15.09.2026

Bewerbung als Softwareentwickler

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);

      expect(result.applicationDate, isNotNull);
      expect(result.applicationDate!.value.year, 2026);
      expect(result.applicationDate!.value.month, 9);
      expect(result.applicationDate!.value.day, 15);
      expect(result.applicationDate!.confidence, greaterThanOrEqualTo(0.9));
    });

    test('Erkennt Firmenname über Rechtsform (GmbH, AG, etc.)', () {
      const text = '''
Max Mustermann
Musterstr. 1
12345 Berlin

TechCorp GmbH
Abteilung Personal
Industriestr. 5
80331 München

Berlin, 01.01.2026

Bewerbung als Tester

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);

      expect(result.company, isNotNull);
      expect(result.company!.value, contains('TechCorp'));
    });

    test('Setzt Status automatisch auf "versendet" bei Anschreiben', () {
      const text = '''
Bewerbung als Praktikant

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);

      expect(result.applicationStatus, isNotNull);
      expect(result.applicationStatus!.value, 'versendet');
    });

    test('Fällt auf Fallback-Modus bei Nicht-Anschreiben zurück', () {
      const text = '''
Stellenanzeige: Senior Developer
TechCorp AG
Kontakt: bewerbung@techcorp.de
Tel: +49 30 123456789
Industriestr. 5, 80331 München
''';
      final result = CoverLetterExtractor.extract(text);

      // Fallback sollte E-Mail und Telefon finden
      expect(result.contactEmail, isNotNull);
      expect(result.contactEmail!.value, 'bewerbung@techcorp.de');
      expect(result.contactPhone, isNotNull);
      expect(result.contactPhone!.value, contains('+49'));
    });

    test('Extrahiert E-Mail und Telefon im Fallback-Modus', () {
      const text = '''
Jobangebot Software-Engineer
GlobalTech Solutions
Max Müller
max.mueller@globaltech.com
0176/12345678
Hauptstraße 10, 50667 Köln
https://www.globaltech.com/jobs
''';
      final result = CoverLetterExtractor.extract(text);

      expect(result.contactEmail, isNotNull);
      expect(result.contactEmail!.value, 'max.mueller@globaltech.com');
    });

    test('Verarbeitet leeren Text ohne Absturz', () {
      final result = CoverLetterExtractor.extract('');

      expect(result.position, isNull);
      expect(result.company, isNull);
    });

    test('Erkennt verschiedene Bewerbungs-Prefixe', () {
      for (final prefix in [
        'Bewerbung als',
        'Bewerbung auf',
        'Bewerbung um',
        'Bewerbung für',
      ]) {
        final text = '''
$prefix die Stelle als Entwickler

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
        final result = CoverLetterExtractor.extract(text);
        expect(result.position, isNotNull,
            reason: 'Prefix "$prefix" sollte erkannt werden');
      }
    });
  });
}
