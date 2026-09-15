import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Reports & Calendar Workflow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zu Wochenbericht
    final reportNav = find.byIcon(Icons.assignment_outlined);
    expect(reportNav, findsWidgets);
    await tester.tap(reportNav.first);
    await tester.pumpAndSettle();
    
    // Warte auf Wochenbericht-Seite
    await Future.delayed(const Duration(seconds: 1));
    expect(find.text('Wochenbericht'), findsWidgets);

    // Navigiere zu Kalender
    final calNav = find.byIcon(Icons.calendar_today_outlined);
    expect(calNav, findsWidgets);
    await tester.tap(calNav.first);
    await tester.pumpAndSettle();
    
    // Warte auf Kalender-Seite
    await Future.delayed(const Duration(seconds: 1));
    // Check if a calendar widget exists or title
    expect(find.text('Kalender'), findsWidgets);

    print('✅ Reports & Kalender Workflow erfolgreich.');
  });
}
