import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/core/services/document_intelligence_service.dart';
import 'package:career_center/domain/models/extraction_result.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Bulk AutoFill Extraction Test', (WidgetTester tester) async {
    final file = File('s:/Projekte/career_center/integration_test/mock_server/raw_tabs.json');
    if (!file.existsSync()) {
      return;
    }

    final jsonString = await file.readAsString();
    final List<dynamic> tabs = json.decode(jsonString);
    
    final service = DocumentIntelligenceService();
    
    int total = tabs.length;
    int successCount = 0;

    for (int i = 0; i < total; i++) {
      final tab = tabs[i];
      final url = tab['url'];
      final html = tab['html'];
      
      try {
        final result = await service.analyzeDocument(html, source: DocumentSource.url);
        final f = result.fields;
        
        final company = f.company?.value ?? '---';
        final position = f.position?.value ?? '---';
        
        print("  [x] Firma:         $company");
        print("  [x] Position:      $position");
        print("  [x] Ort/Adresse:   ${f.address?.value ?? '---'}");
        print("  [x] Kontaktperson: ${f.contactName?.value ?? '---'}");
        print("  [x] E-Mail:        ${f.contactEmail?.value ?? '---'}");
        print("  [x] Telefon:       ${f.contactPhone?.value ?? '---'}");
        print("  [x] Gehalt:        ${f.salaryInfo?.value ?? '---'}");
        
        if (company != '---' || position != '---') {
          successCount++;
        }
      } catch (e) {
        print("  [!] Error processing $url: $e");
      }
    }
  });
}
