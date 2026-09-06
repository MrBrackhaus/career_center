import 'package:drift/drift.dart';
import '../app_database.dart';

part 'templates_dao.g.dart';

@DriftAccessor(tables: [Templates])
class TemplatesDao extends DatabaseAccessor<AppDatabase> with _$TemplatesDaoMixin {
  TemplatesDao(AppDatabase db) : super(db);

  Future<List<Template>> getAllTemplates() => select(templates).get();
  
  Stream<List<Template>> watchAllTemplates() => select(templates).watch();

  Stream<List<Template>> watchTemplatesByType(String t) {
    return (select(templates)..where((tbl) => tbl.type.equals(t))).watch();
  }

  Future<int> insertTemplate(TemplatesCompanion template) {
    return into(templates).insert(template);
  }

  Future<bool> updateTemplate(TemplatesCompanion template) {
    return update(templates).replace(template);
  }

  Future<int> deleteTemplate(Template template) {
    return delete(templates).delete(template);
  }
}

