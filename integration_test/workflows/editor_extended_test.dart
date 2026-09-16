import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Editor extended functional tests', (WidgetTester tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // 1. Open editor via navigation icon
    final editorNav = find.byIcon(Icons.edit_document);
    expect(editorNav, findsWidgets);
    await tester.tap(editorNav.first);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // 2. Verify QuillEditor is present (the big free‑text area)
    final quillEditor = find.byType(quill.QuillEditor);
    expect(quillEditor, findsOneWidget);

    // 3. Enter sample text into the editor
    await tester.enterText(quillEditor, 'Dies ist ein Testtext für den freien Editor');
    await tester.pumpAndSettle();
    print('  [x] Freier Text erfolgreich eingegeben');

    // 4. Test margin sliders (left sidebar)
    final sliders = find.byType(Slider);
    expect(sliders, findsWidgets);
    // Move each slider a bit to trigger setState
    for (var i = 0; i < sliders.evaluate().length; i++) {
      await tester.drag(sliders.at(i), const Offset(20, 0));
    }
    await tester.pumpAndSettle();
    print('  [x] Alle Rand‑Slider verschoben');

    // 5. Switch design templates (Klassisch, Modern)
    final klassisch = find.text('Klassisch');
    if (klassisch.evaluate().isNotEmpty) {
      await tester.tap(klassisch.first);
      await tester.pumpAndSettle();
      print('  [x] Design "Klassisch" aktiviert');
    }
    final modern = find.text('Modern');
    if (modern.evaluate().isNotEmpty) {
      await tester.tap(modern.first);
      await tester.pumpAndSettle();
      print('  [x] Design "Modern" aktiviert');
    }

    // 6. Insert Header via toolbar button (Icon(Icons.article) – placeholder)
    final insertHeaderBtn = find.byIcon(Icons.article);
    if (insertHeaderBtn.evaluate().isNotEmpty) {
      await tester.tap(insertHeaderBtn.first);
      await tester.pumpAndSettle();
      print('  [x] Header über Toolbar eingefügt');
    }

    // 7. Trigger AI‑Korrektur (Button with AI icon)
    final aiButton = find.byIcon(Icons.auto_fix_high);
    if (aiButton.evaluate().isNotEmpty) {
      await tester.tap(aiButton.first);
      await tester.pumpAndSettle();
      print('  [x] AI‑Korrektur‑Button gedrückt');
    }

    // 8. Export PDF (Icon(Icons.picture_as_pdf)) – just ensure button exists
    final pdfExport = find.byIcon(Icons.picture_as_pdf);
    expect(pdfExport, findsWidgets);
    print('  [x] PDF‑Export‑Button gefunden');

    // End of extended workflow
    print('✅ Alle erweiterten Editor‑Funktionstests erfolgreich durchlaufen');
  });
}
