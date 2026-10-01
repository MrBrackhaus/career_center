import 'package:career_center/data/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

String _documentText(WidgetTester tester) => tester
    .widget<quill.QuillEditor>(find.byType(quill.QuillEditor))
    .controller
    .document
    .toPlainText();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('free editor opens with an empty document and the margin '
      'slider updates its mm label', (tester) async {
    await pumpTestApp(tester);
    await tapVisible(tester, find.byIcon(Icons.edit_document));
    await pumpUntilFound(tester, find.byType(quill.QuillEditor));

    expect(_documentText(tester).trim(), isEmpty);

    // Margin sliders live on the "Design" tab of the side panel.
    if (find.text('Seitenränder').evaluate().isEmpty) {
      await tapVisible(tester, find.widgetWithText(Tab, 'Design'));
    }
    final topLabel = find.textContaining(RegExp(r'^Oben: \d+ mm$'));
    expect(topLabel, findsOneWidget);
    final before = tester.widget<Text>(topLabel).data;

    final topSlider = find
        .descendant(
            of: find.ancestor(of: topLabel, matching: find.byType(Column)).first,
            matching: find.byType(Slider))
        .first;
    await tester.ensureVisible(topSlider);
    await tester.drag(topSlider, const Offset(60, 0));
    await settle(tester);

    final after = tester.widget<Text>(topLabel).data;
    expect(after, isNot(before), reason: 'dragging changes the top margin');
  });

  testWidgets('application editor loads the stored cover letter (Quill JSON '
      'and legacy plain text)', (tester) async {
    late int jsonId;
    late int plainId;
    await pumpTestApp(tester, seed: (db) async {
      jsonId = await db.into(db.applications).insert(ApplicationsCompanion.insert(
            company: 'Json AG',
            position: 'Dev',
            coverLetterContent:
                const Value('[{"insert":"Sehr geehrte Damen und Herren,\\n"}]'),
          ));
      plainId = await db.into(db.applications).insert(ApplicationsCompanion.insert(
            company: 'Plain AG',
            position: 'Dev',
            coverLetterContent: const Value('Alter Klartext-Brief'),
          ));
    });

    await goTo(tester, '/applications/$jsonId/editor');
    await pumpUntilFound(tester, find.byType(quill.QuillEditor));
    await settle(tester);
    expect(_documentText(tester), contains('Sehr geehrte Damen und Herren,'));

    // Leave the editor first: the editor state is not rebuilt when only the
    // :id path parameter changes.
    await goTo(tester, '/applications');
    await goTo(tester, '/applications/$plainId/editor');
    await pumpUntilFound(tester, find.byType(quill.QuillEditor));
    expect(_documentText(tester), contains('Alter Klartext-Brief'));
  });
}
