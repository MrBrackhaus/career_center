import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/providers/database_provider.dart';
import 'package:career_center/presentation/screens/editor/application_editor_screen.dart';

void main() {
  testWidgets('Autosave im Vorlagenmodus legt die Vorlage nur einmal an', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1920, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          localizationsDelegates: [
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ApplicationEditorScreen(initialType: 'anschreiben'),
        ),
      ),
    );
    // Laden abwarten (DB-Zugriffe laufen real asynchron).
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }

    final nameField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == 'Dokumentname (z.B. Lebenslauf)',
    );
    expect(nameField, findsOneWidget);

    Future<void> editAndAutosave(String name) async {
      await tester.enterText(nameField, name);
      await tester.pump(const Duration(seconds: 3)); // Autosave-Timer
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump();
      }
    }

    await editAndAutosave('Erster Name');
    await editAndAutosave('Zweiter Name');

    final templates = await tester.runAsync(() => db.templatesDao.getAllTemplates());
    expect(templates, hasLength(1));
    expect(templates!.single.name, 'Zweiter Name');
    expect(find.text('Gespeichert'), findsOneWidget);

    // Editor schließen, Timer & Streams aufräumen.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
