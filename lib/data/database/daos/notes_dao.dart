/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:drift/drift.dart';

import '../app_database.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<Note>> watchNotesForApplication(int applicationId) {
    return (select(notes)
          ..where((n) => n.applicationId.equals(applicationId))
          ..orderBy([
            (n) =>
                OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);
  Future<void> deleteNote(int id) =>
      (delete(notes)..where((n) => n.id.equals(id))).go();
}
