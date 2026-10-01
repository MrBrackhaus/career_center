import 'package:career_center/core/services/extractors/magic_clipboard_service.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import 'package:flutter_test/flutter_test.dart';

ApplicationEntity _app(
  int id,
  String company,
  String position, {
  String? contactEmail,
}) {
  return ApplicationEntity(
    id: id,
    company: company,
    position: position,
    contactEmail: contactEmail,
    status: 'versendet',
    priority: 2,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('companyCoreName', () {
    test('entfernt Rechtsform-Zusätze', () {
      expect(companyCoreName('NCSolution GmbH'), 'ncsolution');
      expect(companyCoreName('Muster Bau GmbH & Co. KG'), 'muster bau');
      expect(companyCoreName('Beispiel AG'), 'beispiel');
      expect(companyCoreName('Start UG (haftungsbeschränkt)'), 'start');
    });
  });

  group('companyMailDomain', () {
    test('liefert Firmendomain, ignoriert Freemailer', () {
      expect(companyMailDomain('hr@techcorp.de'), 'techcorp.de');
      expect(companyMailDomain('max@gmail.com'), isNull);
      expect(companyMailDomain(null), isNull);
      expect(companyMailDomain('kaputt'), isNull);
    });
  });

  group('findBestMatchingApplication', () {
    test('"GmbH" allein erzeugt keinen Treffer', () {
      final apps = [_app(1, 'Alpha GmbH', 'Entwickler')];
      final match = findBestMatchingApplication(
        'Vielen Dank für Ihre Bewerbung bei der Beta GmbH.',
        apps,
      );
      expect(match, isNull);
    });

    test('Teilwort des Firmennamens reicht nicht', () {
      final apps = [_app(1, 'Deutsche Bahn AG', 'Projektleiter')];
      final match = findBestMatchingApplication(
        'Die Deutsche Telekom lädt Sie zum Gespräch ein.',
        apps,
      );
      expect(match, isNull);
    });

    test('vollständiger Firmenname ergibt Treffer', () {
      final apps = [
        _app(1, 'Deutsche Bahn AG', 'Projektleiter'),
        _app(2, 'Deutsche Telekom AG', 'Projektleiter'),
      ];
      final match = findBestMatchingApplication(
        'Die Deutsche Telekom lädt Sie zum Gespräch ein.',
        apps,
      );
      expect(match?.id, 2);
    });

    test('Kontakt-Domain ergibt Treffer', () {
      final apps = [
        _app(1, 'Irgendwas Ganz Anderes', 'Admin', contactEmail: 'jobs@acme.de'),
      ];
      final match = findBestMatchingApplication(
        'Von: recruiting@karriere.acme.de\nLeider müssen wir absagen.',
        apps,
      );
      expect(match?.id, 1);
    });

    test('Gleichstand ergibt keine Auswahl', () {
      final apps = [
        _app(1, 'TechCorp', 'Flutter Developer'),
        _app(2, 'TechCorp GmbH', 'Flutter Developer'),
      ];
      final match = findBestMatchingApplication(
        'Ihre Bewerbung als Flutter Developer bei TechCorp',
        apps,
      );
      expect(match, isNull);
    });

    test('Position entscheidet bei gleicher Firma', () {
      final apps = [
        _app(1, 'TechCorp', 'Flutter Developer'),
        _app(2, 'TechCorp', 'Backend Engineer'),
      ];
      final match = findBestMatchingApplication(
        'Ihre Bewerbung als Flutter Developer bei TechCorp',
        apps,
      );
      expect(match?.id, 1);
    });
  });
}
