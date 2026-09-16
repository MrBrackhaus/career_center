import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/ml/naive_bayes_classifier.dart';
import 'package:career_center/domain/enums/document_type.dart';

void main() {
  group('NaiveBayesClassifier', () {
    late NaiveBayesClassifier classifier;

    setUp(() {
      classifier = NaiveBayesClassifier();
    });

    test('isTrained ist false am Anfang', () {
      expect(classifier.isTrained, isFalse);
    });

    test('trainBatch trainiert das Modell korrekt', () {
      classifier.trainBatch({
        DocumentType.stellenanzeige: [
          'Wir suchen einen Software Developer mit Flutter Erfahrung.',
          'Stellenanzeige: Senior Frontend Engineer gesucht.',
        ],
        DocumentType.anschreiben: [
          'Sehr geehrte Damen und Herren, hiermit bewerbe ich mich als Entwickler.',
          'Anschreiben für die Position als Software Developer.',
        ],
      });

      expect(classifier.isTrained, isTrue);
    });

    test('classify erkennt Dokumente korrekt', () {
      // Training mit repetitiven Wörtern (da minFreq=2 in pruneModel)
      classifier.trainBatch({
        DocumentType.stellenanzeige: [
          'Wir suchen einen Software Developer mit Flutter Erfahrung. Gesucht wird Entwickler.',
          'Stellenanzeige: Senior Frontend Entwickler gesucht. Flutter Erfahrung gesucht.',
          'Deine Aufgaben: Entwicklung von Apps mit Flutter. Entwickler gesucht.',
        ],
        DocumentType.anschreiben: [
          'Sehr geehrte Damen und Herren, hiermit bewerbe ich mich als Entwickler. bewerbe mich.',
          'Anschreiben für die Position als Software Developer. bewerbe mich.',
          'Mit großem Interesse habe ich Ihre Stellenanzeige gelesen und bewerbe mich als Entwickler.',
        ],
        DocumentType.absage: [
          'Leider müssen wir Ihnen absagen. Leider absagen.',
          'Wir haben uns für einen anderen Kandidaten entschieden. Leider absagen.',
          'Leider absagen wir.',
        ]
      });

      // Klassifizieren - sollte als stellenanzeige erkannt werden
      final resultJob = classifier.classify('Gesucht wird ein Junior Flutter Entwickler für unser Team.');
      expect(resultJob.type, DocumentType.stellenanzeige);
      expect(resultJob.confidence, greaterThan(0.0));

      // Klassifizieren - sollte als anschreiben erkannt werden
      final resultLetter = classifier.classify('Sehr geehrter Herr Müller, ich bewerbe mich hiermit.');
      expect(resultLetter.type, DocumentType.anschreiben);

      // Klassifizieren - sollte als Absage erkannt werden
      final resultRejection = classifier.classify('Leider können wir Sie nicht berücksichtigen und müssen absagen.');
      expect(resultRejection.type, DocumentType.absage);
    });
    test('Speichern und Laden (toJson / fromJson) funktioniert verlustfrei', () {
      classifier.trainBatch({
        DocumentType.stellenanzeige: [
          'Wir suchen einen Software Developer mit Flutter Erfahrung. Gesucht wird Entwickler.',
          'Stellenanzeige: Senior Frontend Entwickler gesucht. Flutter Erfahrung gesucht.',
        ],
        DocumentType.anschreiben: [
          'Sehr geehrte Damen und Herren, hiermit bewerbe ich mich als Entwickler. bewerbe mich.',
          'Anschreiben für die Position als Software Developer. bewerbe mich.',
        ],
      });

      // Ursprüngliches Modell testet einen String
      final origResult = classifier.classify('Gesucht wird ein Junior Flutter Entwickler für unser Team.');

      // Modell als JSON speichern
      final jsonModel = classifier.toJson();

      // Neues Modell aus JSON laden
      final loadedClassifier = NaiveBayesClassifier.fromJson(jsonModel);

      // Muss weiterhin als trainiert gelten
      expect(loadedClassifier.isTrained, isTrue);

      // Klassifikation muss exakt dasselbe Ergebnis liefern
      final loadedResult = loadedClassifier.classify('Gesucht wird ein Junior Flutter Entwickler für unser Team.');
      expect(loadedResult.type, origResult.type);
      expect(loadedResult.confidence, closeTo(origResult.confidence, 0.0001));
    });
  });
}
