import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Editor Workflow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zu Editor
    final editorNav = find.byIcon(Icons.edit_document);
    expect(editorNav, findsWidgets);
    await tester.tap(editorNav.first);
    await tester.pumpAndSettle();
    
    // Warte auf Editor-Seite
    await Future.delayed(const Duration(seconds: 1));

    // Es sollte eine Toolbar für Textformatierung geben.
    // Wir suchen einfach nach Icon(Icons.format_bold) oder Icon(Icons.picture_as_pdf) - das PDF Icon zum Exportieren gibt es sicher.
    final pdfExportIcon = find.byIcon(Icons.picture_as_pdf);
    if (pdfExportIcon.evaluate().isNotEmpty) {
      expect(pdfExportIcon, findsWidgets);
    } else {
       // Alternativ format_bold
       expect(find.byIcon(Icons.format_bold), findsWidgets);
    }
    
    print('✅ Editor-Workflow erfolgreich geladen.');
  });
}
