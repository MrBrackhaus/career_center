import 'package:career_center/presentation/screens/applications/widgets/application_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create an application through the form persists it and shows '
      'it in the list', (tester) async {
    final t = await pumpTestApp(tester);

    // Empty DB -> empty state.
    expect(find.text('Zeit für den ersten Schritt!'), findsOneWidget);
    expect(find.byType(ApplicationCard), findsNothing);

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Neue Bewerbung').first);
    expect(find.text('Neue Bewerbung'), findsWidgets); // AppBar title

    await tester.enterText(fieldByLabel('Firma *'), 'Test GmbH');
    await tester.enterText(fieldByLabel('Position *'), 'Flutter Developer');
    await tapVisible(tester, find.widgetWithIcon(ElevatedButton, Icons.save));

    // Back on the list, the new card is shown.
    await pumpUntilFound(tester, find.byType(ApplicationCard));
    expect(find.byType(ApplicationCard), findsOneWidget);
    expect(
      find.descendant(
          of: find.byType(ApplicationCard), matching: find.text('Test GmbH')),
      findsOneWidget,
    );

    // ...and really stored in the database with the defaults.
    final apps = await tester.runAsync(t.db.applicationsDao.getAllApplications);
    expect(apps, hasLength(1));
    expect(apps!.single.company, 'Test GmbH');
    expect(apps.single.position, 'Flutter Developer');
    expect(apps.single.status, 'offen');
  });

  testWidgets('leading/trailing whitespace is trimmed on save', (tester) async {
    final t = await pumpTestApp(tester);

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Neue Bewerbung').first);
    await tester.enterText(fieldByLabel('Firma *'), '  Spaces AG  ');
    await tester.enterText(fieldByLabel('Position *'), '  Tester ');
    await tapVisible(tester, find.widgetWithIcon(ElevatedButton, Icons.save));
    await pumpUntilFound(tester, find.byType(ApplicationCard));

    final apps = await tester.runAsync(t.db.applicationsDao.getAllApplications);
    expect(apps!.single.company, 'Spaces AG');
    expect(apps.single.position, 'Tester');
  });
}
