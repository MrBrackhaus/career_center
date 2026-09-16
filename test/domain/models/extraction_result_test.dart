import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/domain/enums/document_type.dart';
import 'package:career_center/domain/models/extraction_result.dart';

void main() {
  group('FieldResult', () {
    test('Speichert Wert, Konfidenz und Quelle korrekt', () {
      const field = FieldResult<String>(
        value: 'Flutter Entwickler',
        confidence: 0.95,
        source: 'regex_subject',
      );

      expect(field.value, 'Flutter Entwickler');
      expect(field.confidence, 0.95);
      expect(field.source, 'regex_subject');
    });

    test('toString gibt lesbares Format aus', () {
      const field = FieldResult<String>(
        value: 'Test',
        confidence: 0.85,
        source: 'test',
      );

      expect(field.toString(), contains('85%'));
      expect(field.toString(), contains('Test'));
    });

    test('Default source ist "unknown"', () {
      const field = FieldResult<String>(
        value: 'Test',
        confidence: 0.5,
      );

      expect(field.source, 'unknown');
    });
  });

  group('ExtractedFields', () {
    test('averageConfidence berechnet Durchschnitt korrekt', () {
      const fields = ExtractedFields(
        company: FieldResult(value: 'Firma', confidence: 0.8, source: 'test'),
        position: FieldResult(value: 'Dev', confidence: 0.6, source: 'test'),
      );

      expect(fields.averageConfidence, 0.7);
    });

    test('averageConfidence gibt 0.0 bei leeren Feldern zurück', () {
      const fields = ExtractedFields();

      expect(fields.averageConfidence, 0.0);
    });

    test('filledFieldCount zählt nur gefüllte Felder', () {
      const fields = ExtractedFields(
        company: FieldResult(value: 'Firma', confidence: 0.8, source: 'test'),
        position: FieldResult(value: 'Dev', confidence: 0.6, source: 'test'),
        contactEmail: FieldResult(value: 'a@b.de', confidence: 0.9, source: 'test'),
      );

      expect(fields.filledFieldCount, 3);
    });

    test('filledFieldCount gibt 0 bei leeren Feldern zurück', () {
      const fields = ExtractedFields();

      expect(fields.filledFieldCount, 0);
    });
  });

  group('ExtractionResult', () {
    test('isReliable ist true bei hoher Konfidenz und vielen Feldern', () {
      final result = ExtractionResult(
        documentType: DocumentType.anschreiben,
        typeConfidence: 0.85,
        fields: ExtractedFields(
          company: const FieldResult(value: 'Firma', confidence: 0.8, source: 'test'),
          position: const FieldResult(value: 'Dev', confidence: 0.9, source: 'test'),
          contactName: const FieldResult(value: 'Herr M', confidence: 0.7, source: 'test'),
          contactEmail: const FieldResult(value: 'a@b.de', confidence: 0.8, source: 'test'),
        ),
        source: DocumentSource.pdf,
      );

      expect(result.isReliable, isTrue);
    });

    test('isReliable ist false bei niedriger Konfidenz', () {
      final result = ExtractionResult(
        documentType: DocumentType.anschreiben,
        typeConfidence: 0.3,
        fields: const ExtractedFields(
          company: FieldResult(value: 'Firma', confidence: 0.8, source: 'test'),
        ),
        source: DocumentSource.pdf,
      );

      expect(result.isReliable, isFalse);
    });

    test('needsReview ist true bei sehr niedriger Konfidenz', () {
      final result = ExtractionResult(
        documentType: DocumentType.unknown,
        typeConfidence: 0.1,
        fields: const ExtractedFields(),
        source: DocumentSource.text,
      );

      expect(result.needsReview, isTrue);
    });

    test('needsReview ist false bei akzeptabler Konfidenz', () {
      final result = ExtractionResult(
        documentType: DocumentType.anschreiben,
        typeConfidence: 0.7,
        fields: const ExtractedFields(),
        source: DocumentSource.pdf,
      );

      expect(result.needsReview, isFalse);
    });
  });
}
