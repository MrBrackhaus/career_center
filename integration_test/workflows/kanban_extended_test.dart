import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

/// The kanban column (a DragTarget) whose header is [title].
Finder _column(String title) => find.ancestor(
      of: find.text(title),
      matching: find.byType(DragTarget<ApplicationEntity>),
    );

Set<String> _companiesIn(WidgetTester tester, String columnTitle) => tester
    .widgetList<Draggable<ApplicationEntity>>(find.descendant(
      of: _column(columnTitle),
      matching: find.byType(Draggable<ApplicationEntity>),
    ))
    .map((d) => d.data!.company)
    .toSet();

Future<void> _openKanban(WidgetTester tester) async {
  await tapVisible(tester, find.byIcon(Icons.view_kanban));
  expect(find.byIcon(Icons.list), findsOneWidget,
      reason: 'toggle icon switches to "Listenansicht"');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('kanban groups applications by (normalized) status',
      (tester) async {
    await pumpTestApp(tester, seed: (db) async {
      Future<void> add(String c, String s) => db
          .into(db.applications)
          .insert(ApplicationsCompanion.insert(
              company: c, position: 'P', status: Value(s)))
          .then((_) {});
      await add('Offen AG', 'offen');
      await add('Versendet AG', 'versendet');
      await add('Interview AG', 'interview');
      await add('Zusage AG', 'zusage');
      await add('Absage AG', 'absage');
      await add('Absage Zwei AG', 'absage');
    });

    await _openKanban(tester);

    expect(_companiesIn(tester, 'In Vorbereitung'), {'Offen AG'});
    expect(_companiesIn(tester, 'Warten auf Antwort'), {'Versendet AG'});
    expect(_companiesIn(tester, 'Im Gespräch'), {'Interview AG'});
    expect(_companiesIn(tester, 'Angebote'), {'Zusage AG'});
    expect(_companiesIn(tester, 'Archiv (Absagen)'),
        {'Absage AG', 'Absage Zwei AG'});
    // Header counter of the archive column.
    expect(
      find.descendant(
          of: _column('Archiv (Absagen)'), matching: find.text('2')),
      findsOneWidget,
    );

    // Toggling back restores the list view.
    await tapVisible(tester, find.byIcon(Icons.list));
    expect(find.byType(DragTarget<ApplicationEntity>), findsNothing);
  });

  testWidgets('changing the status in the edit form moves the card to the new '
      'column and persists it', (tester) async {
    late int id;
    final t = await pumpTestApp(tester, seed: (db) async {
      id = await db.into(db.applications).insert(ApplicationsCompanion.insert(
          company: 'Integration Test Corp', position: 'Quality Engineer'));
    });

    await _openKanban(tester);
    expect(_companiesIn(tester, 'In Vorbereitung'), {'Integration Test Corp'});

    // Tap the kanban card -> edit form.
    await tapVisible(tester, find.text('Quality Engineer'));
    await pumpUntilFound(tester, find.text('Bewerbung bearbeiten'));

    await tapVisible(tester, find.text('Offen').first);
    await tapVisible(tester, find.text('Versendet').last);
    await tapVisible(tester, find.widgetWithIcon(ElevatedButton, Icons.save));

    final app =
        await tester.runAsync(() => t.db.applicationsDao.getApplicationById(id));
    expect(app!.status, 'versendet');

    // The list/kanban view state is reset after navigation; open kanban again.
    if (find.byIcon(Icons.view_kanban).evaluate().isNotEmpty) {
      await _openKanban(tester);
    }
    expect(_companiesIn(tester, 'In Vorbereitung'), isEmpty);
    expect(_companiesIn(tester, 'Warten auf Antwort'), {'Integration Test Corp'});
  });

  testWidgets('drag & drop between columns updates only the status '
      '(other columns such as the cover letter are preserved)', (tester) async {
    late int id;
    final t = await pumpTestApp(tester, seed: (db) async {
      id = await db.into(db.applications).insert(ApplicationsCompanion.insert(
            company: 'Drag AG',
            position: 'Dragger',
            coverLetterContent: const Value('[{"insert":"Mein Anschreiben\\n"}]'),
            priority: const Value(3),
          ));
    });

    await _openKanban(tester);
    final card = find.descendant(
        of: _column('In Vorbereitung'),
        matching: find.byType(Draggable<ApplicationEntity>));
    final target = find.text('Warten auf Antwort');

    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(tester.getCenter(target) + const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await settle(tester);

    final app =
        await tester.runAsync(() => t.db.applicationsDao.getApplicationById(id));
    expect(app!.status, 'versendet');
    expect(app.coverLetterContent, '[{"insert":"Mein Anschreiben\\n"}]');
    expect(app.priority, 3);
    expect(_companiesIn(tester, 'Warten auf Antwort'), {'Drag AG'});
  });
}
