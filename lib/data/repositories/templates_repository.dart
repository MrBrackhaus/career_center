import '../database/app_database.dart';
import '../../domain/entities/template_entity.dart';
import '../mappers/drift_mappers.dart';
import 'package:drift/drift.dart' as drift;

class TemplatesRepository {
  final AppDatabase _db;
  TemplatesRepository(this._db);

  Stream<List<TemplateEntity>> watchTemplatesByType(String type) {
    return _db.templatesDao.watchTemplatesByType(type).map(
      (list) => list.map((t) => t.toEntity()).toList()
    );
  }

  Stream<List<TemplateEntity>> watchAllTemplates() {
    return _db.templatesDao.watchAllTemplates().map(
      (list) => list.map((t) => t.toEntity()).toList()
    );
  }

  Future<List<TemplateEntity>> getAllTemplates() async {
    final list = await _db.templatesDao.getAllTemplates();
    return list.map((t) => t.toEntity()).toList();
  }

  Future<void> addTemplate(String name, String type, String content, {String? filePath, int? applicationId}) async {
    await _db.templatesDao.insertTemplate(
      TemplatesCompanion.insert(
        name: name,
        type: type,
        content: drift.Value(content),
        filePath: drift.Value.absentIfNull(filePath),
        applicationId: drift.Value.absentIfNull(applicationId),
        createdAt: drift.Value(DateTime.now()),
      )
    );
  }
  
  Future<void> addTemplateEntity(TemplateEntity t) async {
     await _db.templatesDao.insertTemplate(t.toCompanion(false));
  }

  Future<void> updateTemplate(TemplateEntity template) async {
    await _db.templatesDao.updateTemplate(template.toCompanion(true));
  }
  
  Future<void> updateTemplateFields(int id, String name, String type, String content) async {
      await _db.templatesDao.updateTemplate(
        TemplatesCompanion(
          id: drift.Value(id),
          name: drift.Value(name),
          type: drift.Value(type),
          content: drift.Value(content),
        )
      );
  }

  Future<void> deleteTemplate(int id) async {
    await (_db.delete(_db.templates)..where((t) => t.id.equals(id))).go();
  }
}
