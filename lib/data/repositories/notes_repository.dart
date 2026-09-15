import '../database/app_database.dart';
import '../../domain/entities/note_entity.dart';
import '../mappers/drift_mappers.dart';
import 'package:drift/drift.dart' as drift;

class NotesRepository {
  final AppDatabase _db;
  NotesRepository(this._db);

  Stream<List<NoteEntity>> watchNotesForApplication(int applicationId) {
    return _db.notesDao.watchNotesForApplication(applicationId).map(
      (list) => list.map((n) => n.toEntity()).toList()
    );
  }

  Future<void> addNote(int applicationId, String content) async {
    await _db.notesDao.insertNote(
      NotesCompanion.insert(
        applicationId: applicationId,
        
        content: content,
        createdAt: drift.Value(DateTime.now()),
      )
    );
  }

  Future<void> updateNote(NoteEntity note) async {
    await _db.update(_db.notes).replace(note.toCompanion(true));
  }

  Future<void> deleteNote(int id) async {
    await _db.notesDao.deleteNote(id);
  }
}
