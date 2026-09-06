import 'package:drift/drift.dart';
import '../app_database.dart';

part 'documents_dao.g.dart';

@DriftAccessor(tables: [Documents])
class DocumentsDao extends DatabaseAccessor<AppDatabase> with _$DocumentsDaoMixin {
  DocumentsDao(AppDatabase db) : super(db);

  Stream<List<Document>> watchDocumentsForApplication(int applicationId) {
    return (select(documents)
          ..where((d) => d.applicationId.equals(applicationId))
          ..orderBy([(d) => OrderingTerm(expression: d.uploadedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<int> insertDocument(DocumentsCompanion doc) => into(documents).insert(doc);
  Future<void> deleteDocument(int id) => (delete(documents)..where((d) => d.id.equals(id))).go();
}

