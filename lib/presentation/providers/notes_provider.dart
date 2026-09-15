import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note_entity.dart';
import 'database_provider.dart';

final notesProvider = StreamProvider.family.autoDispose<List<NoteEntity>, int>((
  ref,
  applicationId,
) {
  return ref.watch(notesRepositoryProvider).watchNotesForApplication(applicationId);
});

class NotesNotifier extends Notifier<AsyncValue<void>> {
  final int applicationId;
  NotesNotifier(this.applicationId);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addNote(String content) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.addNote(applicationId, content);
  }

  Future<void> updateNote(NoteEntity note) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.updateNote(note);
  }

  Future<void> deleteNote(int id) async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.deleteNote(id);
  }
}

final notesNotifierProvider = NotifierProvider.autoDispose
    .family<NotesNotifier, AsyncValue<void>, int>(
      (id) => NotesNotifier(id),
    );
