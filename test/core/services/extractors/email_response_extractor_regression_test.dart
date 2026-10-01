import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/extractors/email_response_extractor.dart';

void main() {
  group('EmailResponseExtractor - Firma', () {
    test('Kein Satzfragment über mehrere Zeilen als Firmenname', () {
      const body = '''
Sehr geehrte Frau Becker,

vielen Dank für Ihre Bewerbung. Bitte melden Sie sich bis Montag.
Wir freuen uns auf Sie.

Mit freundlichen Grüßen
Ihr Recruiting-Team

Nordlicht Energie AG
Hafenstraße 4, 20457 Hamburg
''';
      final result = EmailResponseExtractor.extract(
        body,
        subject: 'AW: Bewerbung als Sachbearbeiterin',
      );
      expect(result.company?.value, 'Nordlicht Energie AG');
    });

    test('Kleingeschriebene Wortenden ("Montag", "Tage") sind keine Rechtsform', () {
      const body = '''
Hallo Herr Yilmaz,
wir melden uns in den nächsten Tagen. Bitte haben Sie bis Montag Geduld.
Viele Grüße
''';
      final result = EmailResponseExtractor.extract(
        body,
        subject: 'Ihre Bewerbung',
        senderEmail: 'jobs@beispielwerk.de',
      );
      expect(result.company?.value, 'Beispielwerk');
      expect(result.company?.source, 'email_domain');
    });

    test('Firma im Satz ohne vorangestellte Satzteile', () {
      const body =
          'Sehr geehrter Herr Wolf,\nwir danken Ihnen für Ihr Interesse an der Müller & Söhne GmbH und melden uns.';
      final result = EmailResponseExtractor.extract(body, subject: 'Bewerbung');
      expect(result.company?.value, 'Müller & Söhne GmbH');
    });

    test('Footer-Zeile wird gegenüber Fließtext bevorzugt', () {
      const body = '''
Sehr geehrte Frau Arslan,
Ihre Bewerbung ist bei der Personal Service GmbH eingegangen, wir leiten sie weiter.

Klinikum Rhein-Main GmbH
''';
      final result = EmailResponseExtractor.extract(body, subject: 'Bewerbung');
      expect(result.company?.value, 'Klinikum Rhein-Main GmbH');
    });
  });

  group('EmailResponseExtractor - Position', () {
    test('Position im Body über Zeilenende hinweg korrekt begrenzt', () {
      const body = '''
Guten Tag,
vielen Dank für Ihre Bewerbung als Mediengestalterin
bei uns. Wir melden uns.
''';
      final result = EmailResponseExtractor.extract(body, subject: 'Rückmeldung');
      expect(result.position?.value, 'Mediengestalterin');
    });
  });

  group('EmailResponseExtractor - Interview-Erkennung', () {
    test('"herunterladen" + "Gespräch" ist keine Einladung', () {
      final status = EmailResponseExtractor.detectStatus(
        'AW: Bewerbung als Lagerist',
        'Vielen Dank. Sie können die Unterlagen zum Gespräch hier herunterladen. '
            'Wir haben Ihre Bewerbung erhalten.',
      );
      expect(status, 'bestaetigung');
    });

    test('Echte Einladung mit "freue ich mich" wird erkannt', () {
      final status = EmailResponseExtractor.detectStatus(
        'AW: Bewerbung als Lagerist',
        'Sehr geehrter Herr Kaya, gerne lade ich Sie zu einem persönlichen Gespräch '
            'am Dienstag ein. Auf Ihr Kommen freue ich mich.',
      );
      expect(status, 'interview');
    });

    test('Eigenes Anschreiben mit "über eine Einladung" ist keine Einladung', () {
      final status = EmailResponseExtractor.detectStatus(
        'Bewerbung als Lagerist',
        'Sehr geehrte Damen und Herren, ich bewerbe mich bei Ihnen. Über eine Einladung '
            'zu einem persönlichen Gespräch freue ich mich sehr.',
      );
      expect(status, 'versendet');
    });

    test('Betreff "Einladung zum Vorstellungsgespräch" ohne Reply-Prefix', () {
      final status = EmailResponseExtractor.detectStatus(
        'Einladung zum Vorstellungsgespräch',
        'Wir laden Sie herzlich am 12.11. um 10 Uhr ein.',
      );
      expect(status, 'interview');
    });

    test('Betreff "Terminvorschlag" mit Einladung im Body', () {
      final status = EmailResponseExtractor.detectStatus(
        'Terminvorschlag für ein Gespräch',
        'Wir möchten Sie gerne zu einem Kennenlernen einladen.',
      );
      expect(status, 'interview');
    });
  });
}
