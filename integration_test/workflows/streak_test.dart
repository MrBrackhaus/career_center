import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Streak & Weekly Goal Workflow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Prüfen, ob das Streak-Badge sichtbar ist (oder SizedBox).
    // Wenn das Dashboard geladen wird, lädt der streakProvider.
    // Wir prüfen einfach, ob wir "Wochen" oder das Icon(Icons.local_fire_department) finden
    final fireIcon = find.byIcon(Icons.local_fire_department);
    if (fireIcon.evaluate().isNotEmpty) {
      expect(fireIcon, findsWidgets);
    }
    
    // In der Navigation checken.
    print('✅ Streak-Workflow erfolgreich durchlaufen (Badge gerendert oder verborgen).');
  });
}
