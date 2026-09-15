import '../database/app_database.dart';
import '../../domain/entities/document_entity.dart';
import '../mappers/drift_mappers.dart';
import 'package:drift/drift.dart' as drift;

class DocumentsRepository {
  final AppDatabase _db;
  DocumentsRepository(this._db);

  Stream<List<DocumentEntity>> watchDocumentsForApplication(int applicationId) {
    return _db.documentsDao.watchDocumentsForApplication(applicationId).map(
      (list) => list.map((d) => d.toEntity()).toList()
    );
  }

  Future<void> addDocument(int applicationId, String fileName, String filePath, String fileType) async {
    await _db.documentsDao.insertDocument(
      DocumentsCompanion.insert(
        applicationId: applicationId,
        fileName: fileName,
        filePath: filePath,
        fileType: fileType,
        uploadedAt: drift.Value(DateTime.now()),
      )
    );
  }
  
  Future<int> insertDocument(DocumentEntity entity) async {
    return await _db.documentsDao.insertDocument(entity.toCompanion(false));
  }

  Future<void> deleteDocument(int id) async {
    await _db.documentsDao.deleteDocument(id);
  }
}
