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

