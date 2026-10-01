import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/domain/enums/application_status.dart';

void main() {
  group('normalizeApplicationStatus', () {
    test('behält kanonische Werte', () {
      for (final s in ApplicationStatus.values) {
        expect(normalizeApplicationStatus(s), s);
      }
    });

    test('bildet Aliase auf Board-Status ab', () {
      expect(normalizeApplicationStatus('bestaetigung'), 'versendet');
      expect(normalizeApplicationStatus('angebot'), 'zusage');
      expect(normalizeApplicationStatus('einladung'), 'interview');
      expect(normalizeApplicationStatus('Vorstellungsgespräch'), 'interview');
    });

    test('ignoriert Groß-/Kleinschreibung und Leerzeichen', () {
      expect(normalizeApplicationStatus('Absage'), 'absage');
      expect(normalizeApplicationStatus('  ZUSAGE '), 'zusage');
      expect(normalizeApplicationStatus('Angebot'), 'zusage');
    });

    test('unbekannt/null/leer -> fallback', () {
      expect(normalizeApplicationStatus(null), 'versendet');
      expect(normalizeApplicationStatus(''), 'versendet');
      expect(normalizeApplicationStatus('unbekannt'), 'versendet');
      expect(normalizeApplicationStatus('xyz', fallback: 'offen'), 'offen');
      expect(normalizeApplicationStatus(null, fallback: 'offen'), 'offen');
    });
  });
}
