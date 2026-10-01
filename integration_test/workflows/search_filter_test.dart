import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/screens/applications/widgets/application_card.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

Future<void> _seed(AppDatabase db) async {
  Future<void> add(String company, String position, String status) => db
      .into(db.applications)
      .insert(ApplicationsCompanion.insert(
          company: company, position: position, status: Value(status)))
      .then((_) {});
  await add('Apple Corp', 'iOS Developer', 'offen');
  await add('Microsoft GmbH', 'C# Developer', 'versendet');
  await add('Google LLC', 'Go Developer', 'absage');
}

Finder get _searchField => find.byWidgetPredicate((w) =>
    w is TextField &&
    w.decoration?.prefixIcon is Icon &&
    (w.decoration!.prefixIcon as Icon).icon == Icons.search);

Set<String> _visibleCompanies(WidgetTester tester) => tester
    .widgetList<ApplicationCard>(find.byType(ApplicationCard))
    .map((c) => c.application.company)
    .toSet();

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('search matches company and position, case-insensitively',
      (tester) async {
    await pumpTestApp(tester, seed: _seed);
    expect(_visibleCompanies(tester),
        {'Apple Corp', 'Microsoft GmbH', 'Google LLC'});

    await tester.enterText(_searchField, 'APPLE');
    await settle(tester);
    expect(_visibleCompanies(tester), {'Apple Corp'});

    // Position match ("C# Developer").
    await tester.enterText(_searchField, 'c#');
    await settle(tester);
    expect(_visibleCompanies(tester), {'Microsoft GmbH'});

    // Matches all three positions.
    await tester.enterText(_searchField, 'developer');
    await settle(tester);
    expect(_visibleCompanies(tester), hasLength(3));

    await tester.enterText(_searchField, 'NonExistentCompany123');
    await settle(tester);
    expect(find.byType(ApplicationCard), findsNothing);
    expect(find.text('Nichts gefunden.'), findsOneWidget);

    await tester.enterText(_searchField, '');
    await settle(tester);
    expect(_visibleCompanies(tester), hasLength(3));
  });

  testWidgets('status filter shows only applications with that status',
      (tester) async {
    await pumpTestApp(tester, seed: _seed);

    Future<void> selectStatus(String label) async {
      await tapVisible(tester, find.byIcon(Icons.filter_list));
      await tapVisible(tester, find.text(label).last);
    }

    await selectStatus('absage');
    expect(_visibleCompanies(tester), {'Google LLC'});

    await selectStatus('versendet');
    expect(_visibleCompanies(tester), {'Microsoft GmbH'});

    await selectStatus('zusage');
    expect(find.byType(ApplicationCard), findsNothing);
    expect(find.text('Nichts gefunden.'), findsOneWidget);
  });

  testWidgets('search and status filter are combined', (tester) async {
    await pumpTestApp(tester, seed: _seed);

    await tester.enterText(_searchField, 'developer');
    await settle(tester);
    await tapVisible(tester, find.byIcon(Icons.filter_list));
    await tapVisible(tester, find.text('offen').last);

    expect(_visibleCompanies(tester), {'Apple Corp'});
  });
}
