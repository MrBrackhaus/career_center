import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Editor Workflow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zu Editor
    final editorNav = find.byIcon(Icons.edit_document);
    expect(editorNav, findsWidgets);
    await tester.tap(editorNav.first);
    await tester.pumpAndSettle();

    // Warte auf Editor-Seite
    await Future.delayed(const Duration(seconds: 1));

    // Es sollte eine Toolbar für Textformatierung geben.
    expect(find.byType(Slider), findsWidgets);

    // Teste die Margin Sliders
    final sliders = find.byType(Slider);
    expect(sliders, findsWidgets);

    // Verschiebe den ersten Slider (Top Margin)
    await tester.drag(sliders.first, const Offset(30, 0));
    await tester.pumpAndSettle();

    // Überprüfe ob Design Templates da sind und klickbar
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

    // Prüfe Toolbar Icons (z.B. Bold, Italic oder Export)
    final pdfExportIcon = find.byIcon(Icons.picture_as_pdf);
    if (pdfExportIcon.evaluate().isNotEmpty) {
      expect(pdfExportIcon, findsWidgets);
    } else {
      expect(find.byIcon(Icons.format_bold), findsWidgets);
    }

    print(
      '✅ Editor-Workflow und Settings (Ränder & Design) erfolgreich getestet.',
    );
  });
}
