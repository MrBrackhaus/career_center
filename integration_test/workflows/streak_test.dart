import 'package:career_center/data/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

Future<void> _addApplied(AppDatabase db, String company, DateTime applied) => db
    .into(db.applications)
    .insert(ApplicationsCompanion.insert(
        company: company, position: 'P', appliedDate: Value(applied)))
    .then((_) {});

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('streak badge counts consecutive weeks that reached the goal',
      (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9);
    final lastWeek = DateTime(now.year, now.month, now.day - 7, 9);
    final twoWeeksAgo = DateTime(now.year, now.month, now.day - 14, 9);

    await pumpTestApp(
      tester,
      settings: {'weeklyApplicationGoal': '2'},
      seed: (db) async {
        // This week: 2 (goal met), last week: 2 (goal met),
        // two weeks ago: 1 (goal missed -> streak stops there).
        await _addApplied(db, 'A', today);
        await _addApplied(db, 'B', today);
        await _addApplied(db, 'C', lastWeek);
        await _addApplied(db, 'D', lastWeek);
        await _addApplied(db, 'E', twoWeeksAgo);
      },
    );

    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(find.text('2 Wochen'), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.ancestor(
        of: find.byIcon(Icons.local_fire_department),
        matching: find.byType(Tooltip)));
    expect(tooltip.message, 'Ziel: 2 Bewerbungen/Woche\nAktuell: 2 Bewerbungen');
  });

  testWidgets('goal not reached this week: streak counts previous weeks only',
      (tester) async {
    final now = DateTime.now();
    await pumpTestApp(
      tester,
      settings: {'weeklyApplicationGoal': '1'},
      seed: (db) async {
        await _addApplied(db, 'C', DateTime(now.year, now.month, now.day - 7, 9));
      },
    );

    expect(find.text('1 Wochen'), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.ancestor(
        of: find.byIcon(Icons.local_fire_department),
        matching: find.byType(Tooltip)));
    expect(tooltip.message, contains('Aktuell: 0 Bewerbungen'));
  });

  testWidgets('no applications -> no streak badge', (tester) async {
    await pumpTestApp(tester);
    expect(find.byIcon(Icons.local_fire_department), findsNothing);
  });
}
