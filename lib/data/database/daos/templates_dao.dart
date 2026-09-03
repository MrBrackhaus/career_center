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
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'templates_dao.g.dart';

@DriftAccessor(tables: [Templates])
class TemplatesDao extends DatabaseAccessor<AppDatabase> with _$TemplatesDaoMixin {
  TemplatesDao(AppDatabase db) : super(db);

  Future<List<Template>> getAllTemplates() => select(templates).get();
  
  Stream<List<Template>> watchAllTemplates() => select(templates).watch();

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

