import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_center/core/services/document_intelligence_service.dart';
import 'package:career_center/presentation/providers/application_form_notifier.dart';
import 'package:career_center/domain/enums/document_type.dart';
import 'package:career_center/domain/models/extraction_result.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AutoFill Comparison Test (URL vs Extension)', (WidgetTester tester) async {
    final file = File('s:/Projekte/career_center/integration_test/mock_server/raw_tabs.json');
    if (!file.existsSync()) {
      print('JSON file not found!');
      return;
    }

    final jsonString = await file.readAsString();
    final List<dynamic> tabs = json.decode(jsonString);
    
    final service = DocumentIntelligenceService();
    final container = ProviderContainer();
    final notifier = container.read(applicationFormNotifierProvider.notifier);
    
    print('\\n======================================================');
    print('      STARTING AUTO-FILL COMPARISON TEST            ');
    print('======================================================\\n');

    for (int i = 0; i < tabs.length; i++) {
      final tab = tabs[i];
      final url = tab['url'];
      final html = tab['html'];

      print('Processing Tab ${i + 1}/${tabs.length}');
      print('URL: $url');
      print('---');

      // TEST 1: DIRECT URL
      String urlCompany = '---', urlPos = '---', urlEmail = '---', urlPhone = '---';
      try {
        await notifier.extractFromUrl(url);
        final state = container.read(applicationFormNotifierProvider);
        if (state.result != null) {
          final r = state.result!.fields;
          urlCompany = r.company?.value ?? '---';
          urlPos = r.position?.value ?? '---';
          urlEmail = r.contactEmail?.value ?? '---';
          urlPhone = r.contactPhone?.value ?? '---';
        } else {
          urlCompany = 'Failed: ${state.error}';
        }
      } catch (e) {
        urlCompany = 'Exception: $e';
      }

      // TEST 2: BROWSER EXTENSION (RAW HTML)
      String extCompany = '---', extPos = '---', extEmail = '---', extPhone = '---';
      try {
        final result = await service.analyzeDocument(html, source: DocumentSource.url);
        final r = result.fields;
        extCompany = r.company?.value ?? '---';
        extPos = r.position?.value ?? '---';
        extEmail = r.contactEmail?.value ?? '---';
        extPhone = r.contactPhone?.value ?? '---';
      } catch (e) {
        extCompany = 'Exception: $e';
      }

      // PRINT COMPARISON
      print('  Method 1: Direct URL Input');
      print('    Firma:    $urlCompany');
      print('    Position: $urlPos');
      print('    Email:    $urlEmail');
      print('    Telefon:  $urlPhone');
      print('  -------------------------');
      print('  Method 2: Browser Extension (HTML)');
      print('    Firma:    $extCompany');
      print('    Position: $extPos');
      print('    Email:    $extEmail');
      print('    Telefon:  $extPhone');
      print('======================================================\\n');
    }
  });
}
