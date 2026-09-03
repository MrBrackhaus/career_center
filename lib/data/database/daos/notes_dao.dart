/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(AppDatabase db) : super(db);

  Stream<List<Note>> watchNotesForApplication(int applicationId) {
    return (select(notes)
          ..where((n) => n.applicationId.equals(applicationId))
          ..orderBy([(n) => OrderingTerm(expression: n.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);
  Future<void> deleteNote(int id) => (delete(notes)..where((n) => n.id.equals(id))).go();
}

