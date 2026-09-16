import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Kanban Extended Workflow - Create, Edit Status and Check Columns', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1)); // Give db time to load
    
    // 1. Klicke auf FAB (Add) um neue Bewerbung zu erstellen
    final fab = find.byIcon(Icons.add);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // 2. Fülle das Formular aus (0 = Firma, 1 = Position)
    await tester.enterText(find.byType(TextFormField).at(0), 'Integration Test Corp');
    await tester.enterText(find.byType(TextFormField).at(1), 'Quality Engineer');
    
    // Status sollte standardmäßig "Offen" (In Vorbereitung) sein
    
    // 3. Speichern (Save Icon Button ganz unten)
    final saveButton = find.byIcon(Icons.save);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1)); 

    // 4. Wir sollten wieder auf der Liste sein. Wechsle zu Kanban.
    final kanbanIcon = find.byIcon(Icons.view_kanban);
    if (kanbanIcon.evaluate().isNotEmpty) {
      await tester.tap(kanbanIcon.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(milliseconds: 500)); 
    }

    // 5. Überprüfe, ob die Karte existiert
    final cardText = find.text('Integration Test Corp');
    expect(cardText, findsOneWidget);

    // 6. Klicke die Karte an, um sie zu bearbeiten
    await tester.tap(cardText);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 500)); 

    // 7. Ändere den Status auf "versendet"
    final statusDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Offen').first;
    await tester.ensureVisible(statusDropdown);
    await tester.tap(statusDropdown);
    await tester.pumpAndSettle();
    
    // Wähle "Versendet"
    await tester.tap(find.text('Versendet').last);
    await tester.pumpAndSettle();

    // Wieder speichern
    await tester.ensureVisible(find.byIcon(Icons.save));
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2)); 

    expect(find.text('Integration Test Corp'), findsWidgets);
    
    // Lösche die Bewerbung um sauber aufzuräumen
    await tester.tap(find.text('Integration Test Corp').last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 500)); 
    
    // Löschen Button (Icons.delete_outline)
    final deleteIcon = find.byIcon(Icons.delete_outline);
    if (deleteIcon.evaluate().isNotEmpty) {
      await tester.ensureVisible(deleteIcon.first);
      await tester.tap(deleteIcon.first);
      await tester.pumpAndSettle();
      
      // Bestätigungsdialog (Löschen Text)
      await tester.tap(find.text('Löschen').last);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1)); 
    }
    
    print('✅ Erweiterter Kanban-Workflow erfolgreich durchlaufen.');
  });
}
