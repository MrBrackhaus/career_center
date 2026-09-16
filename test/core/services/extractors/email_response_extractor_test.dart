import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/extractors/email_response_extractor.dart';

void main() {
  group('EmailResponseExtractor - Helpers', () {
    test('stripReplyPrefix', () {
      expect(EmailResponseExtractor.stripReplyPrefix('RE: AW: FWD: Meine Bewerbung'), 'Meine Bewerbung');
      expect(EmailResponseExtractor.stripReplyPrefix('AW:Einladung zum Gespräch'), 'Einladung zum Gespräch');
      expect(EmailResponseExtractor.stripReplyPrefix('Kein Prefix'), 'Kein Prefix');
    });

    test('extractCompanyFromDomain', () {
      expect(EmailResponseExtractor.extractCompanyFromDomain('hr@siemens.com'), 'Siemens');
      expect(EmailResponseExtractor.extractCompanyFromDomain('info@mercedes-benz.de'), 'Mercedes Benz');
      expect(EmailResponseExtractor.extractCompanyFromDomain('jobs@aldi-sued.co.uk'), 'Aldi Sued');
      // Should ignore generic domains
      expect(EmailResponseExtractor.extractCompanyFromDomain('peter@gmx.de'), '');
      expect(EmailResponseExtractor.extractCompanyFromDomain('max@gmail.com'), '');
      expect(EmailResponseExtractor.extractCompanyFromDomain('jobcenter-ge@arbeitsagentur.de'), '');
    });
  });

  group('EmailResponseExtractor - detectStatus', () {
    test('Erkennt Absage', () {
      expect(
        EmailResponseExtractor.detectStatus(
          'Ihre Bewerbung als Entwickler',
          'Sehr geehrter Herr Meyer, leider müssen wir Ihnen absagen. Wir haben uns für einen anderen Kandidaten entschieden.',
        ),
        'absage',
      );
    });

    test('Erkennt Interview/Einladung', () {
      expect(
        EmailResponseExtractor.detectStatus(
          'AW: Bewerbung als Entwickler',
          'Hallo! Wir würden Sie gerne zu einem Interview kennenlernen. Wann passt es Ihnen?',
        ),
        'interview',
      );
    });

    test('Erkennt Eingangsbestätigung', () {
      expect(
        EmailResponseExtractor.detectStatus(
          'Eingangsbestätigung: Bewerbung',
          'Wir haben Ihre Unterlagen erhalten und melden uns bald.',
        ),
        'bestaetigung',
      );
    });

    test('Ignoriert Spam/Newsletter', () {
      expect(
        EmailResponseExtractor.detectStatus(
          'Newsletter: Aktuelle Bewerbungsübersicht',
          'Hier sind neue Jobs für Sie...',
        ),
        isNull,
      );
    });
  });

  group('EmailResponseExtractor - extract', () {
    test('Extrahiert Position, Firma und Kontaktperson', () {
      const subject = 'AW: Bewerbung als Flutter Entwickler (m/w/d)';
      const body = '''
        Sehr geehrte Frau Dr. Meyer,
        
        vielen Dank für Ihr Interesse an einer Position bei der TechCorp GmbH.
        Wir laden Sie gerne zum Interview ein.
      ''';

      final result = EmailResponseExtractor.extract(body, subject: subject, senderEmail: 'hr@techcorp.de');

      expect(result.position?.value, 'Flutter Entwickler');
      expect(result.company?.value, 'TechCorp GmbH');
      expect(result.contactName?.value, 'Frau Dr. Meyer'); // Note: Salutation regex matches Frau + Name
      expect(result.applicationStatus?.value, 'interview');
    });

    test('Fällt auf Domain-Extraktion für Firmennamen zurück, wenn im Text nicht gefunden', () {
      final result = EmailResponseExtractor.extract(
        'Vielen Dank für die Bewerbung.',
        subject: 'AW: Bewerbung als Buchhalter',
        senderEmail: 'jobs@audi.de'
      );

      expect(result.position?.value, 'Buchhalter');
      expect(result.company?.value, 'Audi');
    });
  });
}
