/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:drift/drift.dart';

import '../app_database.dart';

part 'templates_dao.g.dart';

@DriftAccessor(tables: [Templates])
class TemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$TemplatesDaoMixin {
  TemplatesDao(super.db);

  Future<List<Template>> getAllTemplates() => select(templates).get();

  Stream<List<Template>> watchAllTemplates() => select(templates).watch();

  Stream<List<Template>> watchTemplatesByType(String t) {
    return (select(templates)..where((tbl) => tbl.type.equals(t))).watch();
  }

  Future<int> insertTemplate(TemplatesCompanion template) {
    return into(templates).insert(template);
  }

  /// Teil-Update: schreibt nur die im Companion gesetzten Felder.
  /// Nicht gesetzte Spalten (z. B. applicationId, filePath, createdAt)
  /// bleiben unverändert – im Gegensatz zu `replace`, das sie überschreibt.
  Future<bool> updateTemplate(TemplatesCompanion template) async {
    assert(template.id.present, 'updateTemplate benötigt eine id');
    final id = template.id.value;
    final rows = await (update(templates)..where((tbl) => tbl.id.equals(id)))
        .write(template.copyWith(id: const Value.absent()));
    return rows > 0;
  }

  Future<Template?> getTemplateById(int id) {
    return (select(templates)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> deleteTemplate(Template template) {
    return delete(templates).delete(template);
  }
}
