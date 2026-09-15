import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/document_entity.dart';
import 'database_provider.dart';

final documentsProvider = StreamProvider.family.autoDispose<List<DocumentEntity>, int>((
  ref,
  applicationId,
) {
  return ref.watch(documentsRepositoryProvider).watchDocumentsForApplication(applicationId);
});

class DocumentsNotifier extends Notifier<AsyncValue<void>> {
  final int applicationId;
  DocumentsNotifier(this.applicationId);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addDocument(String fileName, String filePath, String fileType) async {
    final repo = ref.read(documentsRepositoryProvider);
    await repo.addDocument(applicationId, fileName, filePath, fileType);
  }

  Future<void> deleteDocument(int id) async {
    final repo = ref.read(documentsRepositoryProvider);
    await repo.deleteDocument(id);
  }
}

final documentsNotifierProvider = NotifierProvider.autoDispose
    .family<DocumentsNotifier, AsyncValue<void>, int>(
      (id) => DocumentsNotifier(id),
    );
