import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Kanban Workflow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zum Dashboard (Ist Default)
    // Wir überprüfen, ob wir in die Kanban-Ansicht wechseln müssen.
    final kanbanIcon = find.byIcon(Icons.view_kanban);
    if (kanbanIcon.evaluate().isNotEmpty) {
      await tester.tap(kanbanIcon.first);
      await tester.pumpAndSettle();
    }
    
    // Prüfe, ob die Kanban-Spaltennamen existieren
    expect(find.text('In Vorbereitung'), findsWidgets);
    expect(find.text('Warten auf Antwort'), findsWidgets);
    expect(find.textContaining('Archiv'), findsWidgets);
    
    print('✅ Kanban UI-Test erfolgreich geladen.');
  });
}
