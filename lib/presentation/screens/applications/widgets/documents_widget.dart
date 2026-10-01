import '../../../../l10n/app_localizations.dart';

/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;

import '../../../../core/services/document_storage_service.dart';
import '../../../../domain/entities/document_entity.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/documents_provider.dart';

/// Erlaubte Dateiendungen für Bewerbungsdokumente.
const List<String> kDocumentExtensions = [
  'pdf',
  'doc',
  'docx',
  'txt',
  'odt',
  'png',
  'jpg',
  'jpeg',
];

/// Importiert die Dateien unter [paths] als Dokumente der Bewerbung
/// [applicationId]. Zeigt Erfolg/Fehler per SnackBar an.
Future<void> importDocumentFiles(
  BuildContext context,
  WidgetRef ref,
  int applicationId,
  List<String> paths,
) async {
  final messenger = ScaffoldMessenger.of(context);
  var imported = 0;
  final failed = <String>[];
  for (final path in paths) {
    final originalName = p.basename(path);
    final ext = p.extension(originalName).replaceAll('.', '').toLowerCase();
    if (!kDocumentExtensions.contains(ext)) {
      failed.add('$originalName (Dateityp nicht unterstützt)');
      continue;
    }
    try {
      final newPath = await DocumentStorageService.importFile(path);
      await ref
          .read(documentsRepositoryProvider)
          .addDocument(applicationId, originalName, newPath, ext);
      imported++;
    } catch (e, st) {
      log('Dokument-Import fehlgeschlagen: $e', error: e, stackTrace: st);
      failed.add('$originalName ($e)');
    }
  }
  if (failed.isNotEmpty) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Nicht alle Dokumente konnten gespeichert werden:\n${failed.join('\n')}',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 6),
      ),
    );
  } else if (imported > 0) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          imported == 1
              ? 'Dokument gespeichert.'
              : '$imported Dokumente gespeichert.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class DocumentsWidget extends ConsumerWidget {
  final int applicationId;
  const DocumentsWidget({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsProvider(applicationId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.formTabDocs,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Hochladen'),
              onPressed: () => _uploadDoc(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tipp: Dateien können auch per Drag & Drop hier abgelegt werden.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        docsAsync.when(
          data: (docs) {
            if (docs.isEmpty) {
              return const Text(
                'Keine Dokumente abgelegt.',
                style: TextStyle(color: Colors.grey),
              );
            }
            return Column(
              children: docs.map((d) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
                    title: Text(d.fileName),
                    subtitle: Text(
                      '${d.uploadedAt.day}.${d.uploadedAt.month}.${d.uploadedAt.year}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Dokument löschen',
                      onPressed: () => _confirmDelete(context, ref, d),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Fehler: $e'),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DocumentEntity doc,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dokument löschen?'),
        content: Text(
          'Soll "${doc.fileName}" wirklich gelöscht werden? '
          'Die von der App gespeicherte Kopie der Datei wird ebenfalls entfernt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(documentsRepositoryProvider).deleteDocument(doc.id);
    } catch (e, st) {
      log('Dokument löschen fehlgeschlagen: $e', error: e, stackTrace: st);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      await DocumentStorageService.deleteManagedFile(doc.filePath);
    } catch (e, st) {
      log('Datei konnte nicht gelöscht werden: $e', error: e, stackTrace: st);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Eintrag entfernt, aber die Datei konnte nicht gelöscht werden: $e',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _uploadDoc(BuildContext context, WidgetRef ref) async {
    final typeGroup = XTypeGroup(
      label: AppLocalizations.of(context)!.formTabDocs,
      extensions: kDocumentExtensions,
    );
    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isEmpty || !context.mounted) return;
    await importDocumentFiles(
      context,
      ref,
      applicationId,
      files.map((f) => f.path).toList(),
    );
  }
}
