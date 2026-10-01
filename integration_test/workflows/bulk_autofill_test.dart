// Regression test for the job-posting extraction on real, saved
// arbeitsagentur.de pages (integration_test/mock_server/raw_tabs.json, as
// delivered by the browser extension). Runs fully offline.
import 'dart:convert';
import 'dart:io';

import 'package:career_center/core/services/document_intelligence_service.dart';
import 'package:career_center/domain/enums/document_type.dart';
import 'package:career_center/domain/models/extraction_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

/// Known-correct company names (verified manually against the pages).
const _expectedCompanies = {
  '10000-1207359897-S': 'Aschert & Bohrmann GmbH',
  '12117-YF-49761-YF-S': 'Friedrich W. Schneider GmbH & Co. KG',
  '14751-373A127150-S': 'Tempton Personaldienstleistungen GmbH NL Mönchengladbach',
  '14751-70A24019-S': 'Cavio Personalmanagement GmbH Niederlassung Duisburg',
  '10001-1002539069-S': 'Piening GmbH (Mönchengladbach)',
  '10001-1003689938-S': 'NConsult GmbH',
  '13644-219817-S': 'Systemhaus Erdmann',
  '13424-PWTW9EONU83OF0KP-S': 'AUREA GmbH Zentrale Düsseldorf',
  '19146-100014436429-S': 'COMVID Medien OHG',
  '20073-uoxw1g3igh-S': 'BG Klinikum Duisburg gGmbH',
};

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every saved Arbeitsagentur page is recognised as a job posting '
      'with clean company and position', (tester) async {
    installSandbox(); // ML model file lives in a temp "Documents" folder.

    final file = File(fixturePath('raw_tabs.json'));
    expect(file.existsSync(), isTrue, reason: 'fixture missing: ${file.path}');

    final problems = <String>[];
    var checked = 0;
    await tester.runAsync(() async {
      final tabs = json.decode(await file.readAsString()) as List<dynamic>;
      final service = DocumentIntelligenceService();
      for (final tab in tabs) {
        final url = tab['url'] as String;
        final id = url.split('/').last;
        final result = await service.analyzeDocument(
          tab['html'] as String,
          source: DocumentSource.url,
        );
        checked++;
        final company = result.fields.company?.value;
        final position = result.fields.position?.value;

        if (result.documentType != DocumentType.stellenanzeige) {
          problems.add('$id: classified as ${result.documentType}');
        }
        if (company == null || company.trim().isEmpty) {
          problems.add('$id: no company');
        } else if (company.contains('<')) {
          problems.add('$id: company contains raw HTML: $company');
        }
        if (position == null || position.trim().isEmpty) {
          problems.add('$id: no position');
        } else if (position.contains('<')) {
          problems.add('$id: position contains raw HTML: $position');
        }
        final expected = _expectedCompanies[id];
        if (expected != null && company != expected) {
          problems.add('$id: company "$company" != expected "$expected"');
        }
      }
    });

    expect(checked, 14, reason: 'fixture should contain 14 pages');
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
