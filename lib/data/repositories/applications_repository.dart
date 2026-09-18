import 'dart:io';
import '../database/app_database.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/models/application_form_dto.dart';
import '../mappers/drift_mappers.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:developer';

class ApplicationsRepository {
  final AppDatabase _db;

  ApplicationsRepository(this._db);

  Stream<List<ApplicationEntity>> watchAllApplications() {
    return _db.applicationsDao.watchAllApplications().map(
      (list) => list.map((a) => a.toEntity()).toList(),
    );
  }

  Future<List<ApplicationEntity>> getAllApplications() async {
    final list = await _db.applicationsDao.getAllApplications();
    return list.map((a) => a.toEntity()).toList();
  }

  Future<ApplicationEntity?> getApplicationById(int id) async {
    final a = await _db.applicationsDao.getApplicationById(id);
    return a?.toEntity();
  }

  Future<int> addApplication(ApplicationFormDto app) async {
    return await _db.applicationsDao.insertApplication(app.toCompanion(isUpdate: false));
  }

  Future<void> updateApplication(ApplicationFormDto app) async {
    await _db.applicationsDao.updateApplication(app.toCompanion(isUpdate: true));
  }

  Future<void> updateApplicationStatus(int id, String status, {String? rejectionReason}) async {
    await _db.applicationsDao.partialUpdate(
      id,
      ApplicationsCompanion(
        status: drift.Value(status),
        rejectionReason: rejectionReason != null ? drift.Value(rejectionReason) : const drift.Value.absent(),
      ),
    );
  }

  Future<void> updateCoverLetterContent(int id, String content) async {
    await _db.applicationsDao.partialUpdate(
      id,
      ApplicationsCompanion(
        coverLetterContent: drift.Value(content),
      ),
    );
  }

  Future<void> updateJobDescription(int id, String text) async {
    await _db.applicationsDao.partialUpdate(
      id,
      ApplicationsCompanion(
        jobDescriptionText: drift.Value(text),
      ),
    );
  }

  Future<void> deleteApplication(int id) async {
    await _db.transaction(() async {
      final docs = await (_db.select(_db.documents)
        ..where((d) => d.applicationId.equals(id))).get();
        
      final app = await _db.applicationsDao.getApplicationById(id);
      if (app == null) return;
      
      // Lösche manuell alle verknüpften Daten, da ON DELETE CASCADE in der SQLite DB fehlt
      await (_db.delete(_db.emails)..where((e) => e.applicationId.equals(id))).go();
      await (_db.delete(_db.notes)..where((n) => n.applicationId.equals(id))).go();
      await (_db.delete(_db.contacts)..where((c) => c.applicationId.equals(id))).go();
      await (_db.delete(_db.cvWorkExperiences)..where((w) => w.applicationId.equals(id))).go();
      await (_db.delete(_db.cvEducations)..where((e) => e.applicationId.equals(id))).go();
      await (_db.delete(_db.cvSkills)..where((s) => s.applicationId.equals(id))).go();
      await (_db.delete(_db.cvLanguages)..where((l) => l.applicationId.equals(id))).go();
      await (_db.delete(_db.documents)..where((d) => d.applicationId.equals(id))).go();
      
      await _db.applicationsDao.deleteApplication(app);

      for (final doc in docs) {
        final path = doc.filePath;
        final file = File(path);
        if (await file.exists()) {
          try {
            await file.delete();
          } catch (e) {
            log('Failed to delete file: $path', name: 'ApplicationsRepository');
          }
        }
      }
    });
  }
}
