import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/ml/text_preprocessor.dart';

void main() {
  group('TextPreprocessor', () {
    test('Tokenisiert deutschen Text und entfernt Stoppwörter', () {
      const text = 'Der erfahrene Entwickler hat Kenntnisse in Flutter und Dart';
      final tokens = TextPreprocessor.tokenize(text);

      expect(tokens, contains('erfahrene'));
      expect(tokens, contains('entwickler'));
      expect(tokens, contains('kenntnisse'));
      expect(tokens, contains('flutter'));
      // Stoppwörter sollten weg sein
      expect(tokens, isNot(contains('der')));
      expect(tokens, isNot(contains('und')));
      expect(tokens, isNot(contains('hat')));
      expect(tokens, isNot(contains('in')));
    });

    test('Tokenisiert englische IT-Texte und entfernt englische Stoppwörter', () {
      const text = 'The developer should have experience with React and Node';
      final tokens = TextPreprocessor.tokenize(text);

      expect(tokens, isNot(contains('the')));
      expect(tokens, isNot(contains('and')));
      expect(tokens, contains('developer'));
      expect(tokens, contains('experience'));
      expect(tokens, contains('react'));
      expect(tokens, contains('node'));
    });

    test('Gibt leere Liste bei leerem Text zurück', () {
      final tokens = TextPreprocessor.tokenize('');
      expect(tokens, isEmpty);
    });

    test('Entfernt Satzzeichen aber behält Bindestriche in Komposita', () {
      const text = 'Full-Stack-Entwickler! Gute Kenntnisse.';
      final tokens = TextPreprocessor.tokenize(text);

      expect(tokens, contains('full-stack-entwickler'));
    });

    test('Normalisiert Umlaute korrekt', () {
      expect(TextPreprocessor.normalizeUmlauts('über'), 'ueber');
      expect(TextPreprocessor.normalizeUmlauts('schön'), 'schoen');
      expect(TextPreprocessor.normalizeUmlauts('größe'), 'groesse');
    });

    test('Generiert Bigrams korrekt', () {
      final tokens = ['flutter', 'entwickler', 'gesucht'];
      final bigrams = TextPreprocessor.generateBigrams(tokens);

      expect(bigrams, ['flutter_entwickler', 'entwickler_gesucht']);
    });

    test('Generiert leere Bigrams bei einzelnem Token', () {
      final bigrams = TextPreprocessor.generateBigrams(['flutter']);
      expect(bigrams, isEmpty);
    });

    test('Generiert leere Bigrams bei leerer Liste', () {
      final bigrams = TextPreprocessor.generateBigrams([]);
      expect(bigrams, isEmpty);
    });
  });
}
