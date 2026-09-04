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
import 'dart:io';
import '../database/app_database.dart';
import '../database/daos/applications_dao.dart';

class ApplicationsRepository {
  final AppDatabase _db;

  ApplicationsRepository(this._db);

  Stream<List<Application>> watchAllApplications() {
    return _db.applicationsDao.watchAllApplications();
  }

  Future<List<Application>> getAllApplications() {
    return _db.applicationsDao.getAllApplications();
  }

  Future<Application> getApplicationById(int id) {
    return _db.applicationsDao.getApplicationById(id);
  }

  Future<int> addApplication(ApplicationsCompanion app) async {
    return await _db.applicationsDao.insertApplication(app);
  }

  Future<void> updateApplication(ApplicationsCompanion app) async {
    await _db.applicationsDao.updateApplication(app);
  }

  Future<void> deleteApplication(Application app) async {
    // 1. Delete associated physical files
    try {
      final docs = await (_db.select(_db.documents)..where((d) => d.applicationId.equals(app.id))).get();
      for (final doc in docs) {
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore file deletion errors
    }

    // 2. Database transaction to delete all related rows
    await _db.transaction(() async {
      await (_db.delete(_db.documents)..where((d) => d.applicationId.equals(app.id))).go();
      await (_db.delete(_db.notes)..where((n) => n.applicationId.equals(app.id))).go();
      await (_db.delete(_db.emails)..where((e) => e.applicationId.equals(app.id))).go();
      await _db.applicationsDao.deleteApplication(app);
    });
  }
}
