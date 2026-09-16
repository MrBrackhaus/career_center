import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/utils/keyword_extractor.dart';

void main() {
  group('KeywordExtractor', () {
    test('Extrahiert die häufigsten Keywords aus einem Stellentext', () {
      const text =
          'Wir suchen einen erfahrenen Flutter Entwickler mit Erfahrung in Dart und Flutter. '
          'Der Entwickler sollte Kenntnisse in REST APIs und agiler Softwareentwicklung mitbringen. '
          'Flutter Flutter Dart Dart REST';
      final keywords = KeywordExtractor.extractKeywords(text, topN: 3);

      expect(keywords, contains('flutter'));
      expect(keywords, contains('dart'));
      expect(keywords.length, 3);
    });

    test('Filtert deutsche Stoppwörter korrekt heraus', () {
      const text = 'Der die das und in im zu für mit als von auf ist sind ein eine';
      final keywords = KeywordExtractor.extractKeywords(text);

      expect(keywords, isEmpty);
    });

    test('Ignoriert Wörter mit 2 oder weniger Zeichen', () {
      const text = 'ab cd ef Flutter Dart';
      final keywords = KeywordExtractor.extractKeywords(text);

      expect(keywords, isNot(contains('ab')));
      expect(keywords, isNot(contains('cd')));
      expect(keywords, contains('flutter'));
    });

    test('Gibt leere Liste bei leerem Text zurück', () {
      final keywords = KeywordExtractor.extractKeywords('');
      expect(keywords, isEmpty);
    });

    test('findMatchingKeywords findet vorhandene Keywords im Text', () {
      const text = 'Kenntnisse in Flutter und Dart sind erforderlich';
      final found = KeywordExtractor.findMatchingKeywords(
        text,
        ['flutter', 'dart', 'react', 'angular'],
      );

      expect(found, contains('flutter'));
      expect(found, contains('dart'));
      expect(found, isNot(contains('react')));
      expect(found, isNot(contains('angular')));
    });

    test('findMatchingKeywords gibt leeres Set bei keinem Treffer zurück', () {
      const text = 'Erfahrung im Projektmanagement';
      final found = KeywordExtractor.findMatchingKeywords(
        text,
        ['react', 'angular', 'vue'],
      );

      expect(found, isEmpty);
    });
  });
}
