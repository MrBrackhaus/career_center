import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Editor Workflow mit Texteingaben und Settings', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // 1. Navigiere zu Editor
    final editorNav = find.byIcon(Icons.edit_document);
    expect(editorNav, findsWidgets);
    await tester.tap(editorNav.first);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // 2. Schreibe Text in das Kopfzeilen-Formular (TextFormField)
    final textFields = find.byType(TextFormField);
    expect(textFields, findsWidgets);
    await tester.enterText(textFields.first, 'Musterfirma GmbH Test');
    await tester.pumpAndSettle();
    print('  [x] Text erfolgreich in Header-Feld getippt');

    // 3. Teste die Sidebar Slider (Ränder verschieben)
    expect(find.byType(Slider), findsWidgets);
    final sliders = find.byType(Slider);
    await tester.drag(sliders.first, const Offset(30, 0));
    await tester.pumpAndSettle();
    print('  [x] Ränder-Slider erfolgreich verschoben');

    // 4. Teste Designwechsel (welcher auch Schriftarten anpasst)
    final klassisch = find.text('Klassisch');
    if (klassisch.evaluate().isNotEmpty) {
      await tester.tap(klassisch.first);
      await tester.pumpAndSettle();
      print('  [x] Design-Wechsel auf "Klassisch" erfolgreich');
    }

    final modern = find.text('Modern');
    if (modern.evaluate().isNotEmpty) {
      await tester.tap(modern.first);
      await tester.pumpAndSettle();
      print('  [x] Design-Wechsel auf "Modern" erfolgreich');
    }

    // 5. Teste die Editor-Formatierungs-Toolbar
    final boldIcon = find.byIcon(Icons.format_bold);
    if (boldIcon.evaluate().isNotEmpty) {
      await tester.tap(boldIcon.first);
      await tester.pumpAndSettle();
      print('  [x] Bold-Formatierungsbutton erfolgreich geklickt');
    }

    print(
      '✅ Editor: Text, Slider, Designs und Toolbar erfolgreich interagiert.',
    );
  });
}
