import '../../../../l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../providers/documents_provider.dart';

class DocumentsWidget extends ConsumerWidget {
  final int applicationId;
  const DocumentsWidget({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider(applicationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context)!.formTabDocs, style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Hochladen'),
              onPressed: () => _uploadDoc(context, ref),
            )
          ],
        ),
        const SizedBox(height: 8),
        docsAsync.when(
          data: (docs) {
            if (docs.isEmpty) return const Text('Keine Dokumente abgelegt.', style: TextStyle(color: Colors.grey));
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final d = docs[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: Text(d.fileName),
                    subtitle: Text('${d.uploadedAt?.day}.${d.uploadedAt?.month}.${d.uploadedAt?.year}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref.read(documentsNotifierProvider(applicationId).notifier).deleteDocument(d.id),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Fehler: $e'),
        ),
      ],
    );
  }

  Future<void> _uploadDoc(BuildContext context, WidgetRef ref) async {
    final typeGroup = XTypeGroup(
      label: AppLocalizations.of(context)!.formTabDocs,
      extensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, 'jobtracker_docs'));
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }

    final originalName = p.basename(file.path);
    final newPath = p.join(docsDir.path, '${DateTime.now().millisecondsSinceEpoch}_$originalName');
    
    await File(file.path).copy(newPath);

    ref.read(documentsNotifierProvider(applicationId).notifier).addDocument(
      originalName,
      newPath,
      p.extension(originalName).replaceAll('.', ''),
    );
  }
}
