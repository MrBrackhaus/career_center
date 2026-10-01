import '../database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class EditorRepository {
  final AppDatabase _db;
  EditorRepository(this._db);
  
  Future<int> saveTemplate(int? existingId, String finalName, String type, String content) async {
    if (existingId == null) {
      return await _db.templatesDao.insertTemplate(
        TemplatesCompanion.insert(
          name: finalName,
          type: type,
          content: drift.Value(content),
          createdAt: drift.Value(DateTime.now()),
        ),
      );
    } else {
      // Teil-Update: applicationId, filePath und createdAt bleiben erhalten.
      await _db.templatesDao.updateTemplate(
        TemplatesCompanion(
          id: drift.Value(existingId),
          name: drift.Value(finalName),
          type: drift.Value(type),
          content: drift.Value(content),
        ),
      );
      return existingId;
    }
  }
}
