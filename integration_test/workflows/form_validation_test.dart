import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saving an empty form is blocked: both required fields report '
      '"Pflichtfeld" and nothing is written', (tester) async {
    final t = await pumpTestApp(tester);

    await tapVisible(
        tester, find.widgetWithText(FilledButton, 'Neue Bewerbung').first);
    await tapVisible(tester, find.widgetWithIcon(ElevatedButton, Icons.save));

    expect(find.text('Pflichtfeld'), findsNWidgets(2));
    // Still on the form.
    expect(find.widgetWithIcon(ElevatedButton, Icons.save), findsOneWidget);
    final apps = await tester.runAsync(t.db.applicationsDao.getAllApplications);
    expect(apps, isEmpty);
  });

  testWidgets('only the missing required field is flagged', (tester) async {
    final t = await pumpTestApp(tester);

    await tapVisible(
        tester, find.widgetWithText(FilledButton, 'Neue Bewerbung').first);
    await tester.enterText(fieldByLabel('Firma *'), 'Nur Firma GmbH');
    await tapVisible(tester, find.widgetWithIcon(ElevatedButton, Icons.save));

    expect(find.text('Pflichtfeld'), findsOneWidget);
    expect(
      find.descendant(
          of: fieldByLabel('Position *'), matching: find.text('Pflichtfeld')),
      findsOneWidget,
    );
    final apps = await tester.runAsync(t.db.applicationsDao.getAllApplications);
    expect(apps, isEmpty);
  });
}
