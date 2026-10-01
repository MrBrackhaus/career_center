import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/extractors/cover_letter_extractor.dart';

void main() {
  group('CoverLetterExtractor - Anrede', () {
    test('Name aus "Sehr geehrter Herr Schmidt," (nur Nachname)', () {
      const text = '''
Bewerbung als Industriemechaniker

Sehr geehrter Herr Schmidt,

hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);
      expect(result.contactName?.value, 'Herr Schmidt');
      expect(result.contactName?.source, 'salutation');
    });

    test('Vor- und Nachname mit Titel, Zeilenende begrenzt den Namen', () {
      const text = '''
Bewerbung als Erzieherin

Sehr geehrte Frau Dr. Anna Weiß
mit großem Interesse habe ich Ihre Anzeige gelesen.
''';
      final result = CoverLetterExtractor.extract(text);
      expect(result.contactName?.value, 'Frau Dr. Anna Weiß');
    });
  });

  group('CoverLetterExtractor - Betreff', () {
    test('"Bewerbung" innerhalb des Titels bleibt erhalten', () {
      const text = '''
Bewerbung als Bewerbungsmanager im Recruiting

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);
      expect(result.position?.value, 'Bewerbungsmanager im Recruiting');
    });

    test('Präfix "Bewerbung:" wird entfernt', () {
      const text = '''
Bewerbung: Kauffrau für Büromanagement

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);
      expect(result.position?.value, 'Kauffrau für Büromanagement');
    });
  });

  group('CoverLetterExtractor - Datum', () {
    test('Ungültiges Datum (31.02.) wird nicht übernommen', () {
      const text = '''
Hamburg, 31.02.2026
Hamburg, 05.03.2026

Bewerbung als Koch

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);
      expect(result.applicationDate?.value, DateTime(2026, 3, 5));
    });
  });

  group('CoverLetterExtractor - Firma (Fallback ohne PLZ)', () {
    test('Zeile mit Wortende "ag"/"se" ist keine Firma', () {
      const text = '''
Pflege Plus AG
Gute Deutschkenntnisse
Bewerbung als Pflegefachkraft

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text);
      expect(result.company?.value, 'Pflege Plus AG');
    });

    test('Zeile mit "20" (z.B. "20 Jahre") wird nicht als Datum übersprungen', () {
      const text = '''
Kanzlei Weber KG
Bewerbung als Steuerfachangestellte

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final withoutDate = CoverLetterExtractor.extract(text);
      expect(withoutDate.company?.value, 'Kanzlei Weber KG');

      const text2 = '''
Seit 2020 am Markt GmbH
Bewerbung als Steuerfachangestellte

Sehr geehrte Damen und Herren,
hiermit bewerbe ich mich.
''';
      final result = CoverLetterExtractor.extract(text2);
      expect(result.company?.value, 'Seit 2020 am Markt GmbH');
    });
  });

  group('CoverLetterExtractor - Fallback Telefon', () {
    test('Geburtsdatum ist keine Telefonnummer', () {
      const text = '''
Lebenslauf
Max Mustermann
Geboren am 15.03.1990
''';
      final result = CoverLetterExtractor.extract(text);
      expect(result.contactPhone, isNull);
    });
  });
}
