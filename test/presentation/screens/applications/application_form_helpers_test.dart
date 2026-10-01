import 'dart:convert';

import 'package:career_center/core/services/document_storage_service.dart';
import 'package:career_center/domain/entities/document_entity.dart';
import 'package:career_center/presentation/screens/applications/application_status_updates.dart';
import 'package:career_center/presentation/screens/applications/custom_fields_codec.dart';
import 'package:career_center/presentation/screens/applications/email_composer_dialog.dart';
import 'package:career_center/presentation/screens/applications/widgets/company_avatar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

DocumentEntity _doc(String name, String type) => DocumentEntity(
  id: 1,
  applicationId: 1,
  fileName: name,
  filePath: '/tmp/$name',
  fileType: type,
  uploadedAt: DateTime(2026),
);

void main() {
  group('Custom Fields', () {
    test('Felder ohne Controller bleiben beim Speichern erhalten', () {
      final stored = decodeCustomFields('{"Alt":"bleibt","Gehalt":"50k"}');
      final merged = mergeCustomFields(stored, {'Gehalt': '60k', 'Neu': 'x'});
      expect(json.decode(merged!), {'Alt': 'bleibt', 'Gehalt': '60k', 'Neu': 'x'});
    });

    test('geleertes Feld wird entfernt', () {
      final merged = mergeCustomFields({'A': '1', 'B': '2'}, {'A': ''});
      expect(json.decode(merged!), {'B': '2'});
    });

    test('leeres Ergebnis ergibt null', () {
      expect(mergeCustomFields({'A': '1'}, {'A': ''}), isNull);
      expect(mergeCustomFields({}, {}), isNull);
    });

    test('ungültiges JSON ergibt leere Map', () {
      expect(decodeCustomFields('kaputt'), isEmpty);
      expect(decodeCustomFields('[1,2]'), isEmpty);
      expect(decodeCustomFields(null), isEmpty);
      expect(decodeCustomFields('{"Zahl": 5}'), {'Zahl': '5'});
    });
  });

  group('datesForStatusChange', () {
    final now = DateTime(2026, 10, 1);

    test('versendet setzt Bewerbungsdatum nur wenn leer', () {
      expect(datesForStatusChange('versendet', now: now).appliedDate, now);
      expect(
        datesForStatusChange('versendet',
                currentAppliedDate: DateTime(2026, 1, 1), now: now)
            .isEmpty,
        isTrue,
      );
    });

    test('absage/zusage/interview setzen Antwortdatum nur wenn leer', () {
      for (final s in ['absage', 'zusage', 'interview']) {
        expect(datesForStatusChange(s, now: now).responseDate, now);
        expect(
          datesForStatusChange(s,
                  currentResponseDate: DateTime(2026, 2, 2), now: now)
              .responseDate,
          isNull,
        );
      }
    });

    test('offen ändert keine Daten', () {
      expect(datesForStatusChange('offen', now: now).isEmpty, isTrue);
    });
  });

  group('isDefaultAttachment', () {
    test('Screenshot und Bilder nicht vorausgewählt', () {
      expect(isDefaultAttachment(_doc('Stellenanzeige_Screenshot.png', 'png')), isFalse);
      expect(isDefaultAttachment(_doc('foto.jpg', 'jpg')), isFalse);
      expect(isDefaultAttachment(_doc('screenshot_12.png', 'png')), isFalse);
    });

    test('Dokumente vorausgewählt', () {
      expect(isDefaultAttachment(_doc('Lebenslauf.pdf', 'pdf')), isTrue);
      expect(isDefaultAttachment(_doc('Zeugnis.docx', 'docx')), isTrue);
    });
  });

  group('DocumentStorageService', () {
    test('uniqueFileName mit Zeitstempel-Präfix', () {
      final name = DocumentStorageService.uniqueFileName(
        '/a/b/Lebenslauf.pdf',
        now: DateTime.fromMicrosecondsSinceEpoch(42),
      );
      expect(name, '42_Lebenslauf.pdf');
    });

    test('isInsideAnyRoot erkennt nur App-Ordner', () {
      final root = p.join(p.separator, 'data', 'app', 'documents');
      expect(
        DocumentStorageService.isInsideAnyRoot(p.join(root, 'x.pdf'), [root]),
        isTrue,
      );
      expect(
        DocumentStorageService.isInsideAnyRoot(
          p.join(p.separator, 'home', 'user', 'x.pdf'),
          [root],
        ),
        isFalse,
      );
      expect(
        DocumentStorageService.isInsideAnyRoot(
          p.join(root, '..', 'other', 'x.pdf'),
          [root],
        ),
        isFalse,
      );
    });
  });

  group('companyInitials', () {
    test('liefert Initialen', () {
      expect(companyInitials('Deutsche Bahn AG'), 'DB');
      expect(companyInitials('techcorp'), 'T');
      expect(companyInitials(''), '?');
    });
  });
}
