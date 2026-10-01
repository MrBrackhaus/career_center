import 'dart:convert';
import 'dart:io';

import 'package:career_center/core/services/document_intelligence_service.dart';
import 'package:career_center/domain/enums/document_type.dart';
import 'package:career_center/domain/models/extraction_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _TempPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String path;
  _TempPathProvider(this.path);
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

/// Echte Stellenanzeigen der Arbeitsagentur (HTML, wie von der
/// Browser-Erweiterung gesendet) müssen als Stellenanzeige erkannt werden und
/// dürfen kein rohes HTML in den Feldern liefern.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Echte BA-Seiten werden als Stellenanzeige erkannt', () async {
    PathProviderPlatform.instance =
        _TempPathProvider(Directory.systemTemp.createTempSync('di').path);
    final tabs = jsonDecode(
            File('integration_test/mock_server/raw_tabs.json').readAsStringSync())
        as List;
    final service = DocumentIntelligenceService();

    final failures = <String>[];
    for (final tab in tabs) {
      final html = tab['html'] as String;
      final result =
          await service.analyzeDocument(html, source: DocumentSource.url);
      final fields = [
        result.fields.company?.value,
        result.fields.position?.value,
      ];
      if (result.documentType != DocumentType.stellenanzeige ||
          fields.any((f) => f != null && f.contains('<'))) {
        failures.add('${tab['url']}: ${result.documentType.name} '
            'company=${fields[0]} position=${fields[1]}');
      }
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
