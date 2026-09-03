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

