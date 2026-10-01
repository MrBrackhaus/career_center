import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' as quill;


import '../../../../domain/entities/template_entity.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/ai_cover_letter_provider.dart';

class AiCoverLetterDialog extends ConsumerStatefulWidget {
  /// Speichert das generierte Anschreiben (Quill-Delta als JSON).
  final Future<void> Function(String deltaJson) onCoverLetterGenerated;
  final String company;
  final String position;
  final String jobDescription;

  /// Bereits vorhandenes Anschreiben (Delta-JSON oder Text). Ist es nicht
  /// leer, wird vor dem Überschreiben nachgefragt.
  final String? existingCoverLetter;

  /// Bewerbung, der eine Sicherungskopie des alten Anschreibens zugeordnet
  /// wird.
  final int? applicationId;

  const AiCoverLetterDialog({
    super.key,
    required this.onCoverLetterGenerated,
    required this.company,
    required this.position,
    required this.jobDescription,
    this.existingCoverLetter,
    this.applicationId,
  });

  @override
  ConsumerState<AiCoverLetterDialog> createState() =>
      _AiCoverLetterDialogState();
}

class _AiCoverLetterDialogState extends ConsumerState<AiCoverLetterDialog> {
  TemplateEntity? _selectedCv;
  List<TemplateEntity> _cvTemplates = [];
  bool _isLoadingTemplates = true;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final repo = ref.read(templatesRepositoryProvider);
    final templates = await repo.getAllTemplates();
    final cvs = templates.where((t) => t.type == 'lebenslauf').toList();
    if (mounted) {
      setState(() {
        _cvTemplates = cvs;
        if (cvs.isNotEmpty) {
          _selectedCv = cvs.first;
        }
        _isLoadingTemplates = false;
      });
    }
  }

  String _extractPlainTextFromDelta(String jsonDelta) {
    try {
      final decoded = jsonDecode(jsonDelta);
      final doc = quill.Document.fromJson(decoded);
      return doc.toPlainText();
    } catch (e) {
      return jsonDelta; // Fallback: it's probably already plain text
    }
  }

  /// Fragt nach, ob ein vorhandenes Anschreiben überschrieben werden darf.
  /// Liefert `null` bei Abbruch, sonst ob eine Sicherung angelegt werden soll.
  Future<bool?> _confirmOverwrite() async {
    bool backup = true;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Vorhandenes Anschreiben ersetzen?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Für diese Bewerbung existiert bereits ein Anschreiben. '
                'Das neu generierte Anschreiben ersetzt es.',
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: backup,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Bisheriges Anschreiben als Vorlage sichern',
                ),
                onChanged: (v) => setStateDialog(() => backup = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ersetzen'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return null;
    return backup;
  }

  Future<void> _generate() async {
    if (_selectedCv == null && _cvTemplates.isNotEmpty) return;

    final existing = widget.existingCoverLetter;
    bool backupExisting = false;
    if (existing != null &&
        _extractPlainTextFromDelta(existing).trim().isNotEmpty) {
      final decision = await _confirmOverwrite();
      if (decision == null || !mounted) return;
      backupExisting = decision;
    }

    final dao = ref.read(settingsRepositoryProvider);

    // Baue das Nutzerprofil zusammen
    final name = (await dao.getSettingByKey('userName'))?.value ?? '';
    final email = (await dao.getSettingByKey('userEmail'))?.value ?? '';
    final phone = (await dao.getSettingByKey('userPhone'))?.value ?? '';
    final address = (await dao.getSettingByKey('userAddress'))?.value ?? '';
    final skills = (await dao.getSettingByKey('userSkills'))?.value ?? '';
    if (!mounted) return;

    String userProfile =
        "Name: $name\nEmail: $email\nTelefon: $phone\nAdresse: $address\nSkills: $skills\n";
    if (_selectedCv != null) {
      userProfile +=
          "\n=== LEBENSLAUF ===\n${_extractPlainTextFromDelta(_selectedCv!.content)}";
    }

    final result = await ref
        .read(aiCoverLetterProvider.notifier)
        .generateCoverLetter(
          userProfile: userProfile,
          company: widget.company,
          position: widget.position,
          jobDescription: widget.jobDescription,
        );

    if (result == null || !mounted) return;

    // Create Quill Document Delta
    final doc = quill.Document()..insert(0, result);
    final deltaJson = jsonEncode(doc.toDelta().toJson());

    setState(() {
      _isSaving = true;
      _saveError = null;
    });
    try {
      if (backupExisting && existing != null) {
        final now = DateTime.now();
        final stamp =
            '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} '
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        await ref.read(templatesRepositoryProvider).addTemplate(
              'Anschreiben (Sicherung $stamp) - ${widget.company}',
              'anschreiben',
              existing,
              applicationId: widget.applicationId,
            );
      }
      await widget.onCoverLetterGenerated(deltaJson);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveError = 'Speichern fehlgeschlagen: $e';
        });
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiCoverLetterProvider);

    return AlertDialog(
      title: const Text('✨ KI-Anschreiben generieren'),
      content: SizedBox(
        width: 400,
        child: _isLoadingTemplates
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wähle den Lebenslauf, der als Basis für die KI dienen soll:',
                  ),
                  const SizedBox(height: 16),
                  if (_cvTemplates.isEmpty)
                    const Text(
                      'Du hast noch keine Lebensläufe in "Meine Dokumente" hinterlegt. Das Anschreiben wird nur mit deinen Basis-Profildaten generiert.',
                      style: TextStyle(color: Colors.orange),
                    )
                  else
                    DropdownButtonFormField<TemplateEntity>(
                      initialValue: _selectedCv,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: _cvTemplates.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t.name));
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCv = val;
                        });
                      },
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Die KI analysiert nun die Stellenanzeige und deinen Werdegang. Das kann je nach Modellgröße ein paar Sekunden dauern.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (_saveError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _saveError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  if (aiState.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Fehler: ${aiState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: aiState.isLoading || _isSaving
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton.icon(
          onPressed: aiState.isLoading || _isSaving ? null : _generate,
          icon: aiState.isLoading || _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_awesome),
          label: const Text('Jetzt generieren'),
        ),
      ],
    );
  }
}
