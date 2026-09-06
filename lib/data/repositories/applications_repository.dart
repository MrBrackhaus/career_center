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
