import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/app_database.dart';
import 'database_provider.dart';

final documentsProvider = StreamProvider.family.autoDispose<List<Document>, int>((ref, applicationId) {
  return ref.watch(databaseProvider).documentsDao.watchDocumentsForApplication(applicationId);
});

class DocumentsNotifier extends Notifier<AsyncValue<void>> {
  final int applicationId;
  DocumentsNotifier(this.applicationId);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addDocument(String fileName, String filePath, String fileType) async {
    final db = ref.read(databaseProvider);
    await db.documentsDao.insertDocument(DocumentsCompanion.insert(
      applicationId: applicationId,
      fileName: fileName,
      filePath: filePath,
      fileType: fileType,
      uploadedAt: drift.Value(DateTime.now()),
    ));
  }

  Future<void> deleteDocument(int id) async {
    final db = ref.read(databaseProvider);
    await db.documentsDao.deleteDocument(id);
  }
}

final documentsNotifierProvider = NotifierProvider.autoDispose.family<DocumentsNotifier, AsyncValue<void>, int>((id) => DocumentsNotifier(id));

