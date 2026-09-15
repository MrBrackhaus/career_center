import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/application_entity.dart';
import '../../../domain/entities/document_entity.dart';
import '../../../domain/models/application_form_dto.dart';

import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';

import '../../providers/smtp_provider.dart';
import 'dart:developer' show log;

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
    final docs = await ref.read(documentsRepositoryProvider)
        .watchDocumentsForApplication(widget.application.id)
        .first;
    if (mounted) {
      setState(() {
        _documents = docs;
        _selectedDocIds = docs.map((d) => d.id).toSet();
      });
    }
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

In meiner bisherigen Laufbahn konnte ich bereits wertvolle Erfahrungen sammeln, insbesondere in den Bereichen: $skills. Ich bin davon überzeugt, dass ich mit diesen Qualifikationen einen positiven Beitrag zu Ihrem Team leisten kann.

Meine vollständigen Bewerbungsunterlagen (inkl. Lebenslauf) befinden sich im Anhang dieser E-Mail.

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

    setState(() => _isLoading = true);
    try {

      final smtpServer =
          (await ref.read(settingsRepositoryProvider).getSettingByKey('smtpServer'))?.value ?? '';
      final smtpPortStr =
          (await ref.read(settingsRepositoryProvider).getSettingByKey('smtpPort'))?.value ?? '465';
      final userEmail =
          (await ref.read(settingsRepositoryProvider).getSettingByKey('imapEmail'))?.value ?? '';

      if (smtpServer.isEmpty || userEmail.isEmpty) {
        throw Exception(
          'SMTP-Einstellungen nicht konfiguriert! Bitte gehe in die Einstellungen.',
        );
      }

      final smtpPort = int.tryParse(smtpPortStr) ?? 465;

      final attachments = _documents
          .where((d) => _selectedDocIds.contains(d.id))
          .map((d) => File(d.filePath))
          .where((f) => f.existsSync())
          .toList();

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

      // E-Mail erfolgreich versendet -> Bewerbungsstatus anpassen
      if (widget.application.status == 'offen') {
        final dto = ApplicationFormDto(
          id: widget.application.id,
          company: widget.application.company,
          position: widget.application.position,
          status: 'versendet',
          notes: widget.application.notes,
          rejectionReason: widget.application.rejectionReason,
          appliedDate: DateTime.now(),
          followupDate: widget.application.followupDate,
          commuteCar: widget.application.commuteCar,
          salaryWish: widget.application.salaryWish,
          jobUrl: widget.application.jobUrl,
          companyUrl: widget.application.companyUrl,
          contactName: widget.application.contactName,
          contactEmail: widget.application.contactEmail,
          contactPhone: widget.application.contactPhone,
          address: widget.application.address,
          customFields: widget.application.customFields,
          jobDescriptionText: widget.application.jobDescriptionText,
        );
        await ref.read(applicationNotifierProvider).updateApplication(dto);
      }

      if (!mounted) return;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-Mail erfolgreich gesendet! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } on Exception catch (e, st) {
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
                  return FilterChip(
                    label: Text(
                      doc.fileName,
                      style: const TextStyle(fontSize: 12),
                    ),
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
                    avatar: const Icon(Icons.picture_as_pdf, size: 16),
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
