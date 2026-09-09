import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart' as quill;

import '../../../../data/database/app_database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/ai_cover_letter_provider.dart';

class AiCoverLetterDialog extends ConsumerStatefulWidget {
  final Function(String) onCoverLetterGenerated;
  final String company;
  final String position;
  final String jobDescription;

  const AiCoverLetterDialog({
    super.key,
    required this.onCoverLetterGenerated,
    required this.company,
    required this.position,
    required this.jobDescription,
  });

  @override
  ConsumerState<AiCoverLetterDialog> createState() =>
      _AiCoverLetterDialogState();
}

class _AiCoverLetterDialogState extends ConsumerState<AiCoverLetterDialog> {
  Template? _selectedCv;
  List<Template> _cvTemplates = [];
  bool _isLoadingTemplates = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final dao = ref.read(databaseProvider).templatesDao;
    final templates = await dao.getAllTemplates();
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

  Future<void> _generate() async {
    if (_selectedCv == null && _cvTemplates.isNotEmpty) return;

    final dao = ref.read(databaseProvider).settingsDao;

    // Baue das Nutzerprofil zusammen
    final name = (await dao.getSettingByKey('userName'))?.value ?? '';
    final email = (await dao.getSettingByKey('userEmail'))?.value ?? '';
    final phone = (await dao.getSettingByKey('userPhone'))?.value ?? '';
    final address = (await dao.getSettingByKey('userAddress'))?.value ?? '';
    final skills = (await dao.getSettingByKey('userSkills'))?.value ?? '';

    String userProfile =
        "Name: $name\nEmail: $email\nTelefon: $phone\nAdresse: $address\nSkills: $skills\n";
    if (_selectedCv != null && _selectedCv!.content != null) {
      userProfile +=
          "\n=== LEBENSLAUF ===\n${_extractPlainTextFromDelta(_selectedCv!.content!)}";
    }

    final result = await ref
        .read(aiCoverLetterProvider.notifier)
        .generateCoverLetter(
          userProfile: userProfile,
          company: widget.company,
          position: widget.position,
          jobDescription: widget.jobDescription,
        );

    if (result != null && mounted) {
      // Create Quill Document Delta
      final doc = quill.Document()..insert(0, result);
      final deltaJson = jsonEncode(doc.toDelta().toJson());

      // Callback to form
      widget.onCoverLetterGenerated(deltaJson);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
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
                    DropdownButtonFormField<Template>(
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
          onPressed: aiState.isLoading
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton.icon(
          onPressed: aiState.isLoading ? null : _generate,
          icon: aiState.isLoading
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
