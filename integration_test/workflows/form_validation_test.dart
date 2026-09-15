import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Form Validation Workflow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zu Neue Bewerbung
    final newAppButton = find.widgetWithText(FilledButton, 'Neue Bewerbung');
    if (newAppButton.evaluate().isEmpty) {
      await tester.tap(find.byIcon(Icons.add).first);
    } else {
      await tester.tap(newAppButton);
    }
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // Klicke sofort auf Speichern, ohne etwas einzugeben
    final saveButton = find.byType(ElevatedButton);
    // Find the save button (usually the last ElevatedButton with Icons.save)
    final saveBtnIcon = find.byIcon(Icons.save);
    if (saveBtnIcon.evaluate().isNotEmpty) {
       await tester.ensureVisible(saveBtnIcon.first);
       await tester.tap(saveBtnIcon.first);
    } else if (saveButton.evaluate().isNotEmpty) {
       await tester.ensureVisible(saveButton.last);
       await tester.tap(saveButton.last);
    }
    
    await tester.pumpAndSettle();
    
    // Es sollte ein Validierungsfehler "Pflichtfeld" erscheinen
    expect(find.text('Pflichtfeld'), findsWidgets);
    
    print('✅ Form Validation-Workflow erfolgreich: Leere Pflichtfelder werden blockiert.');
  });
}
