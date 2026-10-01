import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/screens/applications/widgets/application_card.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

Finder _cardFor(String company) => find.ancestor(
      of: find.text(company),
      matching: find.byType(ApplicationCard),
    );

Future<void> _openCardMenuAndDelete(WidgetTester tester, String company) async {
  await tapVisible(
    tester,
    find.descendant(of: _cardFor(company), matching: find.byIcon(Icons.more_vert)),
  );
  // Popup menu entry "Löschen".
  await tapVisible(tester, find.text('Löschen').last);
  expect(find.text('Bewerbung löschen?'), findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('deleting from the list removes exactly that application and '
      'its notes/contacts/linked templates', (tester) async {
    late int keepId;
    late int deleteId;
    final t = await pumpTestApp(tester, seed: (db) async {
      deleteId = await db.into(db.applications).insert(
            ApplicationsCompanion.insert(company: 'Delete Me AG', position: 'Dev'),
          );
      keepId = await db.into(db.applications).insert(
            ApplicationsCompanion.insert(company: 'Keep Me GmbH', position: 'QA'),
          );
      await db.into(db.notes).insert(
          NotesCompanion.insert(applicationId: deleteId, content: 'note'));
      await db.into(db.contacts).insert(ContactsCompanion.insert(
          applicationId: deleteId, name: const Value('HR')));
      await db.into(db.templates).insert(TemplatesCompanion.insert(
          name: 'Anschreiben Delete Me',
          type: 'anschreiben',
          applicationId: Value(deleteId)));
      // Data of the other application must survive.
      await db.into(db.notes).insert(
          NotesCompanion.insert(applicationId: keepId, content: 'keep'));
    });

    expect(find.byType(ApplicationCard), findsNWidgets(2));

    await _openCardMenuAndDelete(tester, 'Delete Me AG');
    await tapVisible(tester, find.widgetWithText(TextButton, 'Löschen'));

    expect(find.text('Bewerbung gelöscht.'), findsOneWidget);
    expect(_cardFor('Delete Me AG'), findsNothing);
    expect(_cardFor('Keep Me GmbH'), findsOneWidget);

    final (apps, notes, contacts, templates) = (await tester.runAsync(() async => (
          await t.db.select(t.db.applications).get(),
          await t.db.select(t.db.notes).get(),
          await t.db.select(t.db.contacts).get(),
          await t.db.select(t.db.templates).get(),
        )))!;
    expect(apps.map((a) => a.id), [keepId]);
    expect(notes.map((n) => n.applicationId), [keepId],
        reason: 'notes of the deleted application must be removed');
    expect(contacts, isEmpty);
    expect(templates, isEmpty,
        reason: 'templates linked to the deleted application cascade');
  });

  testWidgets('cancelling the confirmation keeps the application',
      (tester) async {
    final t = await pumpTestApp(tester, seed: (db) async {
      await db.into(db.applications).insert(
          ApplicationsCompanion.insert(company: 'Stay AG', position: 'Dev'));
    });

    await _openCardMenuAndDelete(tester, 'Stay AG');
    await tapVisible(tester, find.widgetWithText(TextButton, 'Abbrechen'));

    expect(_cardFor('Stay AG'), findsOneWidget);
    final apps = await tester.runAsync(t.db.applicationsDao.getAllApplications);
    expect(apps, hasLength(1));
  });

  testWidgets('deleting from the edit form removes the application and returns '
      'to the list', (tester) async {
    late int id;
    final t = await pumpTestApp(tester, seed: (db) async {
      id = await db.into(db.applications).insert(
          ApplicationsCompanion.insert(company: 'Form Delete AG', position: 'Dev'));
    });

    await tapVisible(
      tester,
      find.descendant(
          of: _cardFor('Form Delete AG'), matching: find.byIcon(Icons.more_vert)),
    );
    await tapVisible(tester, find.text('Bearbeiten').last);
    await pumpUntilFound(tester, find.text('Bewerbung bearbeiten'));

    await tapVisible(
        tester, find.widgetWithText(OutlinedButton, 'Löschen'));
    expect(find.text('Diese Bewerbung wirklich löschen?'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(TextButton, 'Löschen'));

    expect(find.text('Bewerbung bearbeiten'), findsNothing);
    expect(find.text('Meine Bewerbungen'), findsOneWidget);
    expect(await tester.runAsync(() => t.db.applicationsDao.getApplicationById(id)),
        isNull);
  });
}
