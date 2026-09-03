import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/smtp_provider.dart';
import '../../providers/applications_provider.dart';
import '../../../core/services/generative_ai_service.dart';

class EmailComposerDialog extends ConsumerStatefulWidget {
  final Application application;

  const EmailComposerDialog({super.key, required this.application});

  @override
  ConsumerState<EmailComposerDialog> createState() => _EmailComposerDialogState();
}

class _EmailComposerDialogState extends ConsumerState<EmailComposerDialog> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isLoading = false;
  bool _isGenerating = false;
  List<Document> _documents = [];
  Set<int> _selectedDocIds = {};

  @override
  void initState() {
    super.initState();
    _toController.text = widget.application.contactEmail ?? '';
    _subjectController.text = 'Bewerbung als ${widget.application.position}';
    _loadDocuments();
  }
  
  Future<void> _loadDocuments() async {
    final db = ref.read(databaseProvider);
    final docs = await db.documentsDao.getDocumentsForApplication(widget.application.id);
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
      final db = ref.read(databaseProvider);
      final profileDao = db.settingsDao;
      final name = (await profileDao.getSettingByKey('userName'))?.value ?? 'Bewerber';
      final skills = (await profileDao.getSettingByKey('userSkills'))?.value ?? '';
      
      final prompt = '''
Schreibe eine sehr gute, professionelle E-Mail für eine Bewerbung.
Position: ${widget.application.position}
Firma: ${widget.application.company}
Ansprechpartner: ${widget.application.contactName ?? 'Sehr geehrte Damen und Herren,'}
Bewerber Name: $name
Meine Fähigkeiten: $skills

Die E-Mail soll direkt versandfertig sein, ohne Platzhalter, in der "Ich"-Form. Bitte füge am Ende an, dass sich meine vollständigen Bewerbungsunterlagen (inkl. Lebenslauf) im Anhang befinden. Keine Betreffzeile im Text, nur der reine E-Mail-Body. Sei präzise und überzeugend.
''';
      
      final aiService = GenerativeAiService();
      final draft = await aiService.generateText(prompt);
      
      if (mounted && draft != null) {
        _bodyController.text = draft;
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler bei KI-Generierung: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _sendEmail() async {
    if (_toController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Empfänger und Text dürfen nicht leer sein.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final db = ref.read(databaseProvider);
      
      final smtpServer = (await db.settingsDao.getSettingByKey('smtpServer'))?.value ?? '';
      final smtpPortStr = (await db.settingsDao.getSettingByKey('smtpPort'))?.value ?? '465';
      final userEmail = (await db.settingsDao.getSettingByKey('imapEmail'))?.value ?? '';
      
      if (smtpServer.isEmpty || userEmail.isEmpty) {
        throw Exception('SMTP-Einstellungen nicht konfiguriert! Bitte gehe in die Einstellungen.');
      }
      
      final smtpPort = int.tryParse(smtpPortStr) ?? 465;
      
      final attachments = _documents
          .where((d) => _selectedDocIds.contains(d.id))
          .map((d) => File(d.filePath))
          .toList();

      await ref.read(smtpServiceProvider).sendEmail(
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
        await db.applicationsDao.updateApplication(widget.application.copyWith(
          status: 'versendet',
          appliedDate: drift.Value(DateTime.now()),
        ));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-Mail erfolgreich gesendet! 🚀'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler beim Senden: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.send, color: Color(0xFF7C6AF7)),
                const SizedBox(width: 12),
                const Text('E-Mail senden', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _isGenerating ? null : _generateDraft,
                  icon: _isGenerating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                  label: const Text('KI-Entwurf'),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C6AF7)),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(labelText: 'An:', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Betreff:', border: OutlineInputBorder()),
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
              const Text('Anhänge:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _documents.map((doc) {
                  final isSelected = _selectedDocIds.contains(doc.id);
                  return FilterChip(
                    label: Text(doc.fileName, style: const TextStyle(fontSize: 12)),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) _selectedDocIds.add(doc.id);
                        else _selectedDocIds.remove(doc.id);
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
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Abbrechen')),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendEmail,
                  icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
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
