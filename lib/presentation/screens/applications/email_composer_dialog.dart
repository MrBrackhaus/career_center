import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/application_entity.dart';
import '../../../domain/entities/document_entity.dart';
import '../../../domain/enums/application_status.dart';

import '../../providers/database_provider.dart';
import 'application_status_updates.dart';

import '../../providers/smtp_provider.dart';
import 'dart:developer' show log;

/// Interne Dateien (z.B. der automatisch gespeicherte Screenshot der
/// Stellenanzeige), die nicht standardmäßig angehängt werden sollen.
const Set<String> _internalDocumentNames = {'stellenanzeige_screenshot.png'};
const Set<String> _imageTypes = {'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp'};

/// Entscheidet, ob ein Dokument beim Öffnen des Dialogs als Anhang
/// vorausgewählt wird. Interne Dateien und Bilder (Screenshots) werden nicht
/// vorausgewählt.
bool isDefaultAttachment(DocumentEntity doc) {
  final name = doc.fileName.toLowerCase();
  if (_internalDocumentNames.contains(name)) return false;
  if (name.startsWith('screenshot_')) return false;
  final type = doc.fileType.toLowerCase().replaceAll('.', '');
  if (_imageTypes.contains(type)) return false;
  return true;
}

class EmailComposerDialog extends ConsumerStatefulWidget {
  final ApplicationEntity application;

  const EmailComposerDialog({super.key, required this.application});

  @override
  ConsumerState<EmailComposerDialog> createState() =>
      _EmailComposerDialogState();
}

class _EmailComposerDialogState extends ConsumerState<EmailComposerDialog> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;
  bool _isGenerating = false;
  List<DocumentEntity> _documents = [];
  Set<int> _selectedDocIds = {};
  Set<int> _missingDocIds = {};

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _toController.text = widget.application.contactEmail ?? '';
    _subjectController.text = 'Bewerbung als ${widget.application.position}';
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final docs = await ref.read(documentsRepositoryProvider)
          .watchDocumentsForApplication(widget.application.id)
          .first;
      final missing = <int>{};
      for (final d in docs) {
        if (!await File(d.filePath).exists()) missing.add(d.id);
      }
      if (!mounted) return;
      setState(() {
        _documents = docs;
        _missingDocIds = missing;
        _selectedDocIds = docs
            .where((d) => !missing.contains(d.id) && isDefaultAttachment(d))
            .map((d) => d.id)
            .toSet();
      });
    } catch (e, st) {
      log('Dokumente konnten nicht geladen werden: $e', error: e, stackTrace: st);
    }
  }

  /// Prüft die ausgewählten Anhänge. Gibt die zu sendenden Dateien zurück
  /// oder `null`, wenn der Nutzer wegen fehlender Dateien abbricht.
  Future<List<File>?> _collectAttachments() async {
    final selected =
        _documents.where((d) => _selectedDocIds.contains(d.id)).toList();
    final existing = <File>[];
    final missing = <DocumentEntity>[];
    for (final d in selected) {
      final f = File(d.filePath);
      if (await f.exists()) {
        existing.add(f);
      } else {
        missing.add(d);
      }
    }
    if (missing.isEmpty) return existing;
    if (!mounted) return null;

    setState(() => _missingDocIds = {..._missingDocIds, ...missing.map((d) => d.id)});
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Anhänge nicht gefunden'),
        content: Text(
          'Folgende Dateien existieren nicht mehr am gespeicherten Ort:\n\n'
          '${missing.map((d) => '• ${d.fileName}\n  (${d.filePath})').join('\n')}\n\n'
          'Ohne diese Anhänge senden?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ohne diese senden'),
          ),
        ],
      ),
    );
    if (proceed != true) return null;
    return existing;
  }

  Future<void> _generateDraft() async {
    setState(() => _isGenerating = true);
    try {
      final profileDao = ref.read(settingsRepositoryProvider);
      final name =
          (await profileDao.getSettingByKey('userName'))?.value ?? 'Bewerber';
      final skills =
          (await profileDao.getSettingByKey('userSkills'))?.value ?? '';

      final position = widget.application.position;
      final company = widget.application.company;
      final contact =
          widget.application.contactName ?? 'Sehr geehrte Damen und Herren';

      final greeting = contact.contains('Sehr')
          ? contact
          : 'Sehr geehrte/r $contact';

      // Simple rule-based generation (Local Template)

      final draft =
          '''
$greeting,

hiermit bewerbe ich mich mit großem Interesse auf die Position als $position bei $company.

In meiner bisherigen Laufbahn konnte ich bereits wertvolle Erfahrungen sammeln${skills.trim().isEmpty ? '' : ', insbesondere in den Bereichen: $skills'}. Ich bin davon überzeugt, dass ich mit diesen Qualifikationen einen positiven Beitrag zu Ihrem Team leisten kann.

Meine vollständigen Bewerbungsunterlagen sende ich Ihnen gerne im Anhang bzw. auf Anfrage zu.

Ich freue mich sehr über die Möglichkeit eines persönlichen Gesprächs.

Mit freundlichen Grüßen

$name
''';

      if (mounted) {
        _bodyController.text = draft;
      }
    } on Exception catch (e, st) {
      log('An error occurred: $e', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler bei Entwurf-Generierung: $e')),
        );
      }
    } finally {
      if (mounted) { setState(() => _isGenerating = false); }
    }
  }

  Future<void> _sendEmail() async {
    if (_toController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Empfänger und Text dürfen nicht leer sein.'),
        ),
      );
      return;
    }

    final attachments = await _collectAttachments();
    if (attachments == null || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final smtpServer =
          (await settings.getSettingByKey('smtpServer'))?.value ?? '';
      final smtpPortStr =
          (await settings.getSettingByKey('smtpPort'))?.value ?? '465';
      final userEmail =
          (await settings.getSettingByKey('imapEmail'))?.value ?? '';
      if (!mounted) return;

      if (smtpServer.isEmpty || userEmail.isEmpty) {
        throw Exception(
          'SMTP-Einstellungen nicht konfiguriert! Bitte gehe in die Einstellungen.',
        );
      }

      final smtpPort = int.tryParse(smtpPortStr) ?? 465;

      await ref
          .read(smtpServiceProvider)
          .sendEmail(
            server: smtpServer,
            port: smtpPort,
            userEmail: userEmail,
            recipientEmail: _toController.text,
            subject: _subjectController.text,
            bodyText: _bodyController.text,
            attachments: attachments,
          );

      // E-Mail erfolgreich versendet -> Bewerbungsstatus per Teil-Update
      // anpassen (keine anderen Felder überschreiben).
      String? statusWarning;
      try {
        final current = await ref
            .read(applicationsRepositoryProvider)
            .getApplicationById(widget.application.id);
        final status = current?.status ?? widget.application.status;
        if (status == ApplicationStatus.offen) {
          await changeApplicationStatus(
            ref,
            id: widget.application.id,
            newStatus: ApplicationStatus.versendet,
            currentAppliedDate: current?.appliedDate,
            currentResponseDate: current?.responseDate,
          );
        } else if (current != null && current.appliedDate == null) {
          await setApplicationAppliedDate(ref, current.id, DateTime.now());
        }
      } catch (e, st) {
        log('Status-Update nach Versand fehlgeschlagen: $e', error: e, stackTrace: st);
        statusWarning = 'E-Mail gesendet, aber der Status konnte nicht aktualisiert werden: $e';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusWarning ?? 'E-Mail erfolgreich gesendet! 🚀'),
          backgroundColor: statusWarning == null ? Colors.green : Colors.orange,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e, st) {
      log('An error occurred: $e', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Senden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) { setState(() => _isLoading = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.send, color: Color(0xFF7C6AF7)),
                const SizedBox(width: 12),
                const Text(
                  'E-Mail senden',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _isGenerating ? null : _generateDraft,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.draw_outlined),
                  label: const Text('Text-Entwurf'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'An:',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Betreff:',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Schreibe deine Nachricht...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_documents.isNotEmpty) ...[
              const Text(
                'Anhänge:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _documents.map((doc) {
                  final isSelected = _selectedDocIds.contains(doc.id);
                  final isMissing = _missingDocIds.contains(doc.id);
                  return FilterChip(
                    label: Text(
                      isMissing ? '${doc.fileName} (Datei fehlt)' : doc.fileName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isMissing ? Colors.red : null,
                      ),
                    ),
                    tooltip: isMissing
                        ? 'Datei nicht gefunden: ${doc.filePath}'
                        : doc.filePath,
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedDocIds.add(doc.id);
                        } else {
                          _selectedDocIds.remove(doc.id);
                        }
                      });
                    },
                    avatar: Icon(
                      isMissing ? Icons.warning_amber : Icons.attach_file,
                      size: 16,
                      color: isMissing ? Colors.red : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendEmail,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Wird gesendet...' : 'Jetzt senden'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
