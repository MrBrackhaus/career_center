import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/ml/naive_bayes_classifier.dart';
import 'package:career_center/core/services/ml/text_preprocessor.dart';
import 'package:career_center/domain/enums/document_type.dart';

void main() {
  group('TextPreprocessor - Stoppwörter mit Umlauten', () {
    test('für, über, können, Grüße werden entfernt', () {
      final tokens = TextPreprocessor.tokenize(
        'Vielen Dank für Ihr Interesse über uns, wir können Ihnen mit freundlichen Grüßen antworten',
      );
      expect(tokens, isNot(contains('fuer')));
      expect(tokens, isNot(contains('ueber')));
      expect(tokens, isNot(contains('koennen')));
      expect(tokens, isNot(contains('gruessen')));
      expect(tokens, contains('interesse'));
      expect(tokens, contains('antworten'));
    });
  });

  group('NaiveBayesClassifier - Online-Learning', () {
    test('Frisch gelernte Tokens bleiben bei großem Vokabular erhalten', () {
      final classifier = NaiveBayesClassifier();
      // Großes Vokabular (> 10.000 Tokens) aufbauen, jedes Token zweimal,
      // damit das Batch-Pruning sie behält.
      final words = List.generate(6000, (i) => 'wort$i');
      final text = words.join(' ');
      classifier.trainBatch({
        DocumentType.stellenanzeige: [text, text],
        DocumentType.absage: ['leider absage leider', 'leider absage'],
      });
      final vocabBefore =
          (classifier.toJson()['vocabulary'] as List).length;
      expect(vocabBefore, greaterThan(10000));

      classifier.update(
        'Zwischenbescheid Bewerbungseingang Rückmeldung', DocumentType.bestaetigung);

      final vocab = (classifier.toJson()['vocabulary'] as List).toSet();
      expect(vocab, contains('zwischenbescheid'));
      expect(vocab, contains('bewerbungseingang'));
      expect(vocab, contains('zwischenbescheid_bewerbungseingang'));
    });

    test('Pruning schützt übergebene Tokens', () {
      final classifier = NaiveBayesClassifier();
      classifier.update('einmalig selten', DocumentType.absage, isBatch: true);
      classifier.pruneModel(minFreq: 2, protectedTokens: {'einmalig'});
      final vocab = (classifier.toJson()['vocabulary'] as List).toSet();
      expect(vocab, contains('einmalig'));
      expect(vocab, isNot(contains('selten')));
    });
  });
}
