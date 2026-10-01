import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/ai_interview_service.dart';

void main() {
  group('coverLetterPlainText', () {
    test('Klartext bleibt erhalten', () {
      expect(coverLetterPlainText('  Sehr geehrte Damen und Herren  '),
          'Sehr geehrte Damen und Herren');
    });

    test('leer -> leer', () {
      expect(coverLetterPlainText(''), '');
    });

    test('Quill-Delta wird in Klartext umgewandelt', () {
      final delta = jsonEncode([
        {'insert': 'Sehr geehrte '},
        {
          'insert': 'Frau Müller',
          'attributes': {'bold': true}
        },
        {'insert': ',\nich bewerbe mich.\n'},
      ]);
      expect(coverLetterPlainText(delta),
          'Sehr geehrte Frau Müller,\nich bewerbe mich.');
    });

    test('Delta mit ops-Objekt und Nicht-Text-Inserts', () {
      final delta = jsonEncode({
        'ops': [
          {'insert': 'Hallo'},
          {
            'insert': {'image': 'x.png'}
          },
          {'insert': ' Welt\n'},
        ]
      });
      expect(coverLetterPlainText(delta), 'Hallo Welt');
    });

    test('ungültiges JSON wird als Text übernommen', () {
      expect(coverLetterPlainText('[kein json'), '[kein json');
    });
  });
}
