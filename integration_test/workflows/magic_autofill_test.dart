import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Magic Auto-Fill Workflow', (WidgetTester tester) async {
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

    // Finde das Auto-Fill URL Feld via Icon(Icons.link)
    final linkIcon = find.byIcon(Icons.link);
    expect(linkIcon, findsWidgets);
    
    // Gib die URL des lokalen Mock-Servers ein
    final urlField = find.ancestor(of: linkIcon.first, matching: find.byType(TextField));
    if (urlField.evaluate().isNotEmpty) {
      await tester.enterText(urlField.first, 'http://127.0.0.1:8080/job.html');
    }
    
    // Klicke den Auto-Fill Button
    final autoFixIcon = find.byIcon(Icons.auto_fix_high);
    expect(autoFixIcon, findsWidgets);
    
    final autoFillButton = find.ancestor(of: autoFixIcon.first, matching: find.byType(ElevatedButton));
    if (autoFillButton.evaluate().isNotEmpty) {
      await tester.ensureVisible(autoFillButton.first);
      await tester.tap(autoFillButton.first);
      
      // Pump, um den Lade-Indikator zu triggern
      await tester.pump(const Duration(milliseconds: 500));
      
      // Wir warten bis alle Animationen/Netzwerk-Requests durch sind
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
    
    // VERIFIZIERE, DASS DIE DATEN EXTRAHIERT UND EINGETRAGEN WURDEN!
    // Die TextFelder sollten nun "Acme Corp" und "Senior Flutter Developer" enthalten.
    expect(find.text('Acme Corp'), findsWidgets);
    expect(find.text('Senior Flutter Developer'), findsWidgets);
    
    print('✅ Magic Auto-Fill UI-Test erfolgreich: Daten ("Acme Corp", "Senior Flutter Developer") wurden eingetragen!');
  });
}
