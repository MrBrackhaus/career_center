import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App starts, adds a new application and returns to list', (WidgetTester tester) async {
    // 1. App starten
    app.main();
    await tester.pumpAndSettle();

    // Warten, bis die initiale Ladephase des Dashboards beendet ist
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 2. Button "Neue Bewerbung" finden und klicken
    final newAppButton = find.widgetWithText(FilledButton, 'Neue Bewerbung');
    
    // Falls der Text anders lautet, versuche es per Icon
    if (newAppButton.evaluate().isEmpty) {
      final iconButton = find.byIcon(Icons.add);
      expect(iconButton, findsWidgets);
      await tester.tap(iconButton.first);
    } else {
      await tester.tap(newAppButton);
    }
    
    await tester.pumpAndSettle();
    
    // Wir sind jetzt im Formular. Warte kurz.
    await Future.delayed(const Duration(seconds: 1));

    // 3. Felder füllen (wir nehmen an, die Labels sind "Unternehmen" und "Position" o.ä.)
    // Wir suchen Textfelder. Da wir die Keys nicht 100% kennen, suchen wir alle TextFields.
    // Das erste ist meistens "Unternehmen", das zweite "Position".
    final textFields = find.byType(TextField);
    expect(textFields, findsWidgets);

    // Gib ins erste gefundene Textfeld (Unternehmen) etwas ein
    await tester.enterText(textFields.at(0), 'Test Firma GmbH');
    // Gib ins zweite gefundene Textfeld (Position) etwas ein
    await tester.enterText(textFields.at(1), 'Integration Tester (w/m/d)');
    
    await tester.pumpAndSettle();
    
    // 4. Speichern Button klicken (meist ein ElevatedButton oder FilledButton mit "Speichern" oder Icon.save)
    final saveButton = find.widgetWithText(ElevatedButton, 'Speichern');
    if (saveButton.evaluate().isNotEmpty) {
      await tester.tap(saveButton);
    } else {
      final saveButtonAlt = find.widgetWithText(FilledButton, 'Speichern');
      if (saveButtonAlt.evaluate().isNotEmpty) {
        await tester.tap(saveButtonAlt);
      } else {
        // Fallback Icon save
        await tester.tap(find.byIcon(Icons.save).first);
      }
    }

    await tester.pumpAndSettle();
    
    // Wir sollten zurück auf dem Dashboard sein
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    
    // 5. Überprüfen, ob die "Test Firma GmbH" nun in der Liste auftaucht
    expect(find.textContaining('Test Firma GmbH'), findsWidgets);
    
    print('✅ Erweiterter Test: Neue Bewerbung erfolgreich angelegt!');
  });
}
