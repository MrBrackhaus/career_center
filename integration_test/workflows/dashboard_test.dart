import 'package:career_center/data/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

/// Reads the big number of the dashboard stat card titled [title].
String _statValue(WidgetTester tester, String title) {
  final card = find.ancestor(of: find.text(title), matching: find.byType(Card));
  final texts = tester
      .widgetList<Text>(find.descendant(of: card.first, matching: find.byType(Text)))
      .map((t) => t.data)
      .toList();
  return texts.first!;
}

String _fmt(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('weekly dashboard counts this week\'s applications and lists '
      'overdue / upcoming follow-ups (closed ones excluded)', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final yesterday = DateTime(now.year, now.month, now.day - 1, 10);
    final inTwoDays = DateTime(now.year, now.month, now.day + 2, 10);

    await pumpTestApp(tester, seed: (db) async {
      Future<void> add(String c, String s,
              {DateTime? applied, DateTime? followup}) =>
          db
              .into(db.applications)
              .insert(ApplicationsCompanion.insert(
                company: c,
                position: 'P',
                status: Value(s),
                appliedDate: Value(applied),
                followupDate: Value(followup),
              ))
              .then((_) {});
      await add('Overdue AG', 'versendet', applied: today, followup: yesterday);
      await add('Soon AG', 'offen', applied: today, followup: inTwoDays);
      // Rejected: counts as a rejection, its old follow-up is NOT overdue.
      await add('Rejected AG', 'absage', applied: today, followup: yesterday);
      // Applied long ago -> not part of this week.
      await add('Old AG', 'interview',
          applied: DateTime(now.year, now.month, now.day - 40));
    });

    await tapVisible(tester, find.byIcon(Icons.bar_chart_outlined));
    await pumpUntilFound(tester, find.text('Aktuelle Woche'));

    expect(_statValue(tester, 'NEUE BEWERBUNGEN'), '3');
    // "open" = offen + versendet (Overdue AG, Soon AG).
    expect(_statValue(tester, 'AKTIVE BEWERBUNGEN'), '2');
    expect(_statValue(tester, 'ABSAGEN'), '1');

    expect(find.text('1 überfällige Erinnerung – jetzt nachhaken!'),
        findsOneWidget);
    expect(find.text('• Overdue AG – P (seit ${_fmt(yesterday)})'),
        findsOneWidget);
    expect(find.textContaining('Rejected AG'), findsNothing);

    expect(find.text('1 Erinnerung diese Woche'), findsOneWidget);
    expect(find.text('• Soon AG – P (am ${_fmt(inTwoDays)})'), findsOneWidget);
  });

  testWidgets('dashboard without data shows zeros and no reminder cards',
      (tester) async {
    await pumpTestApp(tester);
    await tapVisible(tester, find.byIcon(Icons.bar_chart_outlined));
    await pumpUntilFound(tester, find.text('Aktuelle Woche'));

    expect(_statValue(tester, 'NEUE BEWERBUNGEN'), '0');
    expect(_statValue(tester, 'AKTIVE BEWERBUNGEN'), '0');
    expect(find.textContaining('überfällige Erinnerung'), findsNothing);
    expect(find.textContaining('Erinnerung diese Woche'), findsNothing);
  });
}
