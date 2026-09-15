import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Templates Workflow - Navigate and View', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zu Vorlagen
    final templatesNav = find.byIcon(Icons.file_copy_outlined);
    expect(templatesNav, findsWidgets);
    await tester.tap(templatesNav.first);
    await tester.pumpAndSettle();
    
    // Warte auf Vorlagen-Seite
    await Future.delayed(const Duration(seconds: 1));

    // Prüfe ob die Tabs "Lebensläufe" / "Anschreiben" gerendert wurden
    expect(find.text('Lebensläufe'), findsWidgets);
    
    // Neues Dokument Button suchen
    final addTemplateButton = find.widgetWithText(ElevatedButton, 'Neues Dokument anlegen');
    if (addTemplateButton.evaluate().isNotEmpty) {
      await tester.tap(addTemplateButton.first);
      await tester.pumpAndSettle();
      
      // Cancel Dialog (könnte "Abbrechen" sein, oder per Pop)
      // Wir tippen ins Leere oder Esc, oder belassen es dabei
    }
    
    print('✅ Templates-Workflow erfolgreich.');
  });
}
