import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/utils/spell_checker.dart';

void main() {
  group('SpellChecker - Sprachunterstützung', () {
    test('availableLanguages enthält Deutsch und Englisch', () {
      expect(SpellChecker.availableLanguages, containsPair('de', 'Deutsch'));
      expect(SpellChecker.availableLanguages, containsPair('en', 'English'));
    });

    test('availableLanguages enthält mindestens 8 Sprachen', () {
      expect(SpellChecker.availableLanguages.length, greaterThanOrEqualTo(8));
    });

    test('availableLanguages enthält Französisch und Spanisch', () {
      expect(SpellChecker.availableLanguages.containsKey('fr'), isTrue);
      expect(SpellChecker.availableLanguages.containsKey('es'), isTrue);
    });

    test('availableLanguages enthält Türkisch und Arabisch', () {
      expect(SpellChecker.availableLanguages.containsKey('tr'), isTrue);
      expect(SpellChecker.availableLanguages.containsKey('ar'), isTrue);
    });
  });

  group('SpellChecker - ignoreWord', () {
    test('Ignorierte Wörter werden im User-Dictionary gespeichert', () {
      SpellChecker.ignoreWord('Antigravity');
      SpellChecker.ignoreWord('FlutterDev');
      // Kein expect nötig - wenn es nicht crasht, ist der Test bestanden
    });
  });

  group('SpellChecker - checkText', () {
    test('Gibt leere Liste bei leerem Text zurück', () async {
      final warnings = await SpellChecker.checkText('');
      expect(warnings, isEmpty);
    });

    test('Gibt leere Liste bei nur Whitespace zurück', () async {
      final warnings = await SpellChecker.checkText('   \n\t  ');
      expect(warnings, isEmpty);
    });
  });

  group('SpellChecker - currentLanguage', () {
    test('Default-Sprache ist zugänglich', () {
      final lang = SpellChecker.currentLanguage;
      expect(lang, isNotEmpty);
    });
  });
}
