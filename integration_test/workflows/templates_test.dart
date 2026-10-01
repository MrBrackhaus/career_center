import 'package:career_center/data/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('templates are listed per type and can be deleted',
      (tester) async {
    final t = await pumpTestApp(tester, seed: (db) async {
      await db.into(db.templates).insert(
          TemplatesCompanion.insert(name: 'CV Standard', type: 'lebenslauf'));
      await db.into(db.templates).insert(TemplatesCompanion.insert(
          name: 'Anschreiben Allgemein', type: 'anschreiben'));
    });

    await tapVisible(tester, find.byIcon(Icons.file_copy_outlined));
    await pumpUntilFound(tester, find.text('Lebensläufe'));

    // Tab "Lebensläufe" shows only the CV.
    expect(find.text('CV Standard'), findsOneWidget);
    expect(find.text('Anschreiben Allgemein'), findsNothing);

    // Tab "Anschreiben" shows only the cover letter.
    await tapVisible(tester, find.widgetWithText(Tab, 'Anschreiben'));
    expect(find.text('Anschreiben Allgemein'), findsOneWidget);
    expect(find.text('CV Standard'), findsNothing);

    // Delete it – the app asks for confirmation first.
    await tapVisible(
      tester,
      find.descendant(
        of: find.ancestor(
            of: find.text('Anschreiben Allgemein'),
            matching: find.byType(ListTile)),
        matching: find.byIcon(Icons.delete_outline),
      ),
    );
    expect(find.text('Vorlage löschen?'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Löschen'));
    expect(find.text('Anschreiben Allgemein'), findsNothing);
    expect(find.text('Noch keine Dokumente'), findsOneWidget);

    final remaining = await tester.runAsync(
        () => t.db.select(t.db.templates).get());
    expect(remaining!.map((e) => e.name), ['CV Standard']);
  });

  testWidgets('empty templates tab offers creating a document', (tester) async {
    await pumpTestApp(tester);
    await tapVisible(tester, find.byIcon(Icons.file_copy_outlined));
    await pumpUntilFound(tester, find.text('Lebensläufe'));

    expect(find.text('Noch keine Dokumente'), findsOneWidget);
    await tapVisible(
        tester, find.widgetWithText(ElevatedButton, 'Neues Dokument anlegen'));
    // For CVs a choice dialog (empty vs. PDF import) is shown.
    expect(find.text('Neuen Lebenslauf anlegen'), findsOneWidget);
    expect(find.text('Leeres Dokument'), findsOneWidget);
    expect(find.text('Aus PDF importieren'), findsOneWidget);
  });
}
