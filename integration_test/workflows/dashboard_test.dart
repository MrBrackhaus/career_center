import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dashboard Workflow - View Toggle and Search', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zum Dashboard (Sollte Default sein, aber wir prüfen)
    expect(find.byIcon(Icons.view_kanban), findsWidgets);
    
    // Toggle Kanban View
    await tester.tap(find.byIcon(Icons.view_kanban).first);
    await tester.pumpAndSettle();
    
    // Icon sollte sich zu Icons.list geändert haben
    expect(find.byIcon(Icons.list), findsWidgets);
    
    // Toggle back
    await tester.tap(find.byIcon(Icons.list).first);
    await tester.pumpAndSettle();
    
    // Search Field
    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'NonExistentCompany123');
    await tester.pumpAndSettle();
    
    // Check if Empty State is shown (Icon rocket_launch is used in empty state)
    expect(find.byIcon(Icons.rocket_launch), findsWidgets);
    
    print('✅ Dashboard-Workflow erfolgreich: Ansichtswechsel und Suche funktionieren.');
  });
}
