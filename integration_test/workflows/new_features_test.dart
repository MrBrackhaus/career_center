import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;
import 'package:career_center/presentation/screens/applications/widgets/mock_interview_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test New Features (Mock Interview & Calendar Export)', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // Handle tutorial if it appears (using Icons instead of exact texts where possible, or just the keys)
    if (find.text('Willkommen in der Bewerbungszentrale!').evaluate().isNotEmpty) {
      final weiterBtn = find.text('Weiter');
      while (weiterBtn.evaluate().isNotEmpty) {
        await tester.tap(weiterBtn.first);
        await tester.pumpAndSettle();
      }
      final startBtn = find.text('Loslegen');
      if (startBtn.evaluate().isNotEmpty) {
        await tester.tap(startBtn.first);
        await tester.pumpAndSettle();
      }
    }

    // 1. Bewerbung erstellen
    // In applications_screen.dart it is a FilledButton.icon with Icons.add
    final newBtn = find.byIcon(Icons.add);
    expect(newBtn, findsWidgets);
    await tester.tap(newBtn.first);
    await tester.pumpAndSettle();

    // Felder ausfüllen
    // Since labels are translated, we just fill the text fields by index.
    // Index 0: Company
    // Index 1: Company URL
    // Index 2: Job URL
    // Index 3: Position
    final textFields = find.byType(TextFormField);
    expect(textFields.evaluate().length, greaterThanOrEqualTo(4));
    await tester.enterText(textFields.at(0), 'Testcorp Inc.'); // Company
    await tester.enterText(textFields.at(3), 'Senior Flutter Dev'); // Position
    
    // Follow-up Datum setzen (damit der ICS Button erscheint)
    // The text 'Nachhaken am... (optional)' is hardcoded in basic_data_tab.dart
    final dateField = find.textContaining('Nachhaken am');
    if (dateField.evaluate().isNotEmpty) {
      await tester.ensureVisible(dateField.first);
      await tester.tap(dateField.first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // DatePicker OK
      await tester.pumpAndSettle();
    }

    // Speichern
    // The save button has Icons.save
    final saveButton = find.byIcon(Icons.save);
    await tester.ensureVisible(saveButton.first);
    await tester.tap(saveButton.first);
    await tester.pumpAndSettle();
    
    // Wait for the database stream to update the UI
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 2. Zurück im Dashboard, klicke auf die neue Bewerbung um Details aufzuklappen
    final applicationCard = find.textContaining('Testcorp Inc.').first;
    expect(applicationCard, findsOneWidget);
    await tester.tap(applicationCard);
    await tester.pumpAndSettle();

    // 3. Prüfe ob der ICS-Export Button existiert
    // Der Button heißt '.ics Export' (hardcoded)
    final icsButton = find.widgetWithText(OutlinedButton, '.ics Export');
    // Hinweis: Wir klicken ihn im Test nicht an, da der native Windows-Dialog den Test blockieren würde.
    expect(icsButton, findsWidgets, reason: 'Der .ics Export Button sollte bei vorhandenem Follow-Up Datum sichtbar sein.');

    // 4. Prüfe ob der Mock-Interview Button existiert und klicke ihn
    // The button has Icons.mic or 'Mock-Interview starten' text
    final mockInterviewButton = find.widgetWithText(ElevatedButton, 'Mock-Interview starten');
    expect(mockInterviewButton, findsOneWidget, reason: 'Der Mock-Interview Button sollte sichtbar sein.');
    
    // Scrollen falls nötig
    await tester.ensureVisible(mockInterviewButton);
    await tester.tap(mockInterviewButton);
    await tester.pumpAndSettle();

    // 5. Verifiziere, dass wir im Mock-Interview-Screen sind
    expect(find.byType(MockInterviewScreen), findsOneWidget);
    
    // 6. Teste die Chat-Eingabe
    final chatInput = find.byType(TextField);
    expect(chatInput, findsOneWidget);
    await tester.enterText(chatInput, 'Guten Tag, danke für die Einladung!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Das Senden-Icon klicken
    final sendButton = find.byIcon(Icons.send);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    // Die gesendete Nachricht sollte im Chat auftauchen
    expect(find.text('Guten Tag, danke für die Einladung!'), findsOneWidget);

    print('✅ New Features Test erfolgreich!');
  });
}
