import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/app_database.dart';
import 'database_provider.dart';

final notesProvider = StreamProvider.family.autoDispose<List<Note>, int>((ref, applicationId) {
  return ref.watch(databaseProvider).notesDao.watchNotesForApplication(applicationId);
});

class NotesNotifier extends Notifier<AsyncValue<void>> {
  final int applicationId;
  NotesNotifier(this.applicationId);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addNote(String text) async {
    final db = ref.read(databaseProvider);
    await db.notesDao.insertNote(NotesCompanion.insert(
      applicationId: applicationId,
      content: text,
      createdAt: drift.Value(DateTime.now()),
    ));
  }

  Future<void> deleteNote(int id) async {
    final db = ref.read(databaseProvider);
    await db.notesDao.deleteNote(id);
  }
}

final notesNotifierProvider = NotifierProvider.autoDispose.family<NotesNotifier, AsyncValue<void>, int>((id) => NotesNotifier(id));

