import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/utils/csv_generator.dart';

void main() {
  group('CsvGenerator.escapeCsvCell', () {
    test('Formel-Präfixe werden neutralisiert', () {
      for (final input in ['=1+1', '+49 30 1234', '-5', '@SUM(A1)', '\t=1+1', '\r=1+1', '  =HYPERLINK("x")']) {
        expect(CsvGenerator.escapeCsvCell(input), startsWith('"\''),
            reason: 'Eingabe "$input" muss neutralisiert werden');
      }
    });

    test('Normale Texte bleiben unverändert, Anführungszeichen verdoppelt', () {
      expect(CsvGenerator.escapeCsvCell('Müller GmbH'), '"Müller GmbH"');
      expect(CsvGenerator.escapeCsvCell('Firma "Nord"'), '"Firma ""Nord"""');
      expect(CsvGenerator.escapeCsvCell(''), '""');
    });
  });
}
