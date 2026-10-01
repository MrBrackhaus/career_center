import 'package:career_center/data/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/table_calendar.dart';

import '../helpers/test_app.dart';

// TableCalendar is instantiated with a private event type, so match by
// predicate instead of exact runtime type.
final _calendar = find.byWidgetPredicate((w) => w is TableCalendar);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('weekly report compares this week with last week and lists '
      'applications waiting for an answer', (tester) async {
    final now = DateTime.now();
    await pumpTestApp(tester, seed: (db) async {
      Future<void> add(String c, String p, String s, DateTime applied) => db
          .into(db.applications)
          .insert(ApplicationsCompanion.insert(
              company: c,
              position: p,
              status: Value(s),
              appliedDate: Value(applied)))
          .then((_) {});
      final today = DateTime(now.year, now.month, now.day, 9);
      await add('Wartet AG', 'Backend Dev', 'versendet', today);
      await add('Offen AG', 'Frontend Dev', 'offen', today);
      await add('Vorwoche AG', 'Ops', 'absage',
          DateTime(now.year, now.month, now.day - 7, 9));
    });

    await tapVisible(tester, find.byIcon(Icons.assignment_outlined));
    await pumpUntilFound(tester, find.text('Anstehende Rückmeldungen'));

    expect(
      find.text('Diese Woche 2 Bewerbungen vs. letzte Woche 1 Bewerbungen'),
      findsOneWidget,
    );
    // Only "versendet" applications are "waiting".
    final waiting = find.ancestor(
        of: find.text('Wartend'), matching: find.byType(ListTile));
    expect(waiting, findsOneWidget);
    expect(find.descendant(of: waiting, matching: find.text('Backend Dev')),
        findsOneWidget);
    expect(find.descendant(of: waiting, matching: find.text('Wartet AG')),
        findsOneWidget);
    expect(find.text('Aktuell keine ausstehenden Antworten.'), findsNothing);
  });

  testWidgets('calendar shows follow-up of the selected day', (tester) async {
    final now = DateTime.now();
    await pumpTestApp(tester, seed: (db) async {
      await db.into(db.applications).insert(ApplicationsCompanion.insert(
            company: 'Kalender AG',
            position: 'Planner',
            status: const Value('versendet'),
            followupDate: Value(DateTime(now.year, now.month, now.day, 12)),
          ));
    });

    await tapVisible(tester, find.byIcon(Icons.calendar_today_outlined));
    await pumpUntilFound(tester, _calendar);

    // table_calendar keys every day cell by its date. (No ensureVisible:
    // it would scroll the calendar's internal PageView.)
    await tester.tap(
        find.byKey(ValueKey('CellContent-${now.year}-${now.month}-${now.day}')));
    await settle(tester);

    expect(find.text('Kalender AG - Planner'), findsOneWidget);
    final tile = find.ancestor(
        of: find.text('Kalender AG - Planner'), matching: find.byType(ListTile));
    expect(find.descendant(of: tile, matching: find.text('Nachhaken')),
        findsOneWidget);
  });
}
