import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/extractors/magic_clipboard_service.dart';
import 'package:career_center/domain/entities/application_entity.dart';

void main() {
  group('MagicClipboardService Tests', () {
    late MagicClipboardService service;

    final List<ApplicationEntity> existingApps = [
      ApplicationEntity(
        id: 1,
        company: 'NCSolution GmbH',
        position: 'Senior IT-Administrator',
        status: 'versendet',
        priority: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ApplicationEntity(
        id: 2,
        company: 'TechCorp',
        position: 'Flutter Developer',
        status: 'offen',
        priority: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setUp(() {
      service = MagicClipboardService();
    });

    test('Identifies Rejection (Absage) correctly', () {
      final text = '''
Sehr geehrte(r) Bewerber(in),
vielen Dank für Ihre Bewerbung bei der NCSolution GmbH als Senior IT-Administrator.
Wir müssen Ihnen leider mitteilen, dass wir uns für einen anderen Kandidaten entschieden haben.
Wir wünschen Ihnen für Ihre berufliche Zukunft alles Gute.
''';
      
      final result = service.analyzeText(text, existingApps);
      
      expect(result, isNotNull);
      expect(result!.detectedStatus, 'absage');
      expect(result.matchedApplication?.id, 1);
      expect(result.matchedApplication?.company, 'NCSolution GmbH');
    });

    test('Identifies Interview (Einladung) correctly', () {
      final text = '''
Hallo,
wir laden Sie gerne zu einem ersten Kennenlernen für die Position als Flutter Developer ein.
Bitte teilen Sie uns Ihre Verfügbarkeit für nächste Woche mit.
Viele Grüße,
Das HR-Team von TechCorp
''';
      
      final result = service.analyzeText(text, existingApps);
      
      expect(result, isNotNull);
      expect(result!.detectedStatus, 'interview');
      expect(result.matchedApplication?.id, 2);
    });

    test('Returns null for empty text', () {
      final result = service.analyzeText('   ', existingApps);
      expect(result, isNull);
    });

    test('Returns null for unrelated text without matches', () {
      final text = 'Hallo, hier ist das Rezept für den Apfelkuchen. LG Mama';
      final result = service.analyzeText(text, existingApps);
      
      expect(result, isNull);
    });
  });
}
