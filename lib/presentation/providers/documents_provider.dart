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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../data/database/app_database.dart';
import 'database_provider.dart';

final documentsProvider = StreamProvider.family
    .autoDispose<List<Document>, int>((ref, applicationId) {
      return ref
          .watch(databaseProvider)
          .documentsDao
          .watchDocumentsForApplication(applicationId);
    });

class DocumentsNotifier extends Notifier<AsyncValue<void>> {
  final int applicationId;
  DocumentsNotifier(this.applicationId);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addDocument(
    String fileName,
    String filePath,
    String fileType,
  ) async {
    final db = ref.read(databaseProvider);
    await db.documentsDao.insertDocument(
      DocumentsCompanion.insert(
        applicationId: applicationId,
        fileName: fileName,
        filePath: filePath,
        fileType: fileType,
        uploadedAt: drift.Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteDocument(int id) async {
    final db = ref.read(databaseProvider);
    await db.documentsDao.deleteDocument(id);
  }
}

final documentsNotifierProvider = NotifierProvider.autoDispose
    .family<DocumentsNotifier, AsyncValue<void>, int>(
      (id) => DocumentsNotifier(id),
    );
