import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/providers/database_provider.dart';
import 'package:career_center/presentation/providers/editor_provider.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test('saveTemplate liefert die ID; erneutes Speichern legt nichts neu an', () async {
    // Nur per read (wie im Editor) – der Provider darf dabei nicht entsorgt werden.
    final notifier = container.read(templateEditorProvider.notifier);
    final id = await notifier.saveTemplate(
      existingId: null,
      name: 'Entwurf',
      type: 'anschreiben',
      deltaJson: [
        {'insert': 'Hallo\n'},
      ],
    );
    final again = await notifier.saveTemplate(
      existingId: id,
      name: 'Entwurf 2',
      type: 'anschreiben',
      deltaJson: [
        {'insert': 'Hallo Welt\n'},
      ],
    );

    expect(again, id);
    final all = await database.templatesDao.getAllTemplates();
    expect(all, hasLength(1));
    expect(all.single.name, 'Entwurf 2');
    expect(container.read(templateEditorProvider).isSaving, isFalse);
  });
}
