import 'package:flutter/material.dart';

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:file_selector/file_selector.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../editor/application_editor_screen.dart';
import 'widgets/ki_workspace_chat.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Template> _templates = [];
  bool _isLoading = true;

  final _promptPositionController = TextEditingController();
  final _promptCompanyController = TextEditingController();
  final _promptSkillsController = TextEditingController();
  final _promptToneController = TextEditingController();
  bool _initializedTone = false;
  String _generatedPrompt = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTone) {
      _promptToneController.text = AppLocalizations.of(context)!
          .promptToneDefault;
      _initializedTone = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final dao = ref.read(databaseProvider).templatesDao;
    final templates = await dao.getAllTemplates();
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _promptPositionController.dispose();
    _promptCompanyController.dispose();
    _promptSkillsController.dispose();
    _promptToneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.person_outline), text: 'Lebensläufe'),
              Tab(icon: Icon(Icons.mail_outline), text: 'Anschreiben'),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'KI-Workspace'),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Prompt Generator'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplatesList('lebenslauf'),
                _buildTemplatesList('anschreiben'),
                _buildKiWorkspaceTab(),
                _buildPromptGeneratorTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          (_tabController.index == 0 || _tabController.index == 1)
          ? FloatingActionButton(
              onPressed: () => _createNewTemplate(
                _tabController.index == 0 ? 'lebenslauf' : 'anschreiben',
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTemplatesList(String type) {
    final filtered = _templates.where((t) => t.type == type).toList();
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Noch keine Dokumente', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _createNewTemplate(type),
              icon: const Icon(Icons.add),
              label: Text('Neues Dokument anlegen'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final template = filtered[index];
        IconData icon = type == 'lebenslauf'
            ? Icons.person_outline
            : Icons.mail_outline;

        return Card(
          child: ListTile(
            leading: Icon(icon, size: 32),
            title: Text(
              template.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              template.applicationId != null
                  ? ' (Verknüpft)'
                  : (template.filePath != null
                        ? ' (Original-PDF)'
                        : template.type.toUpperCase()),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editTemplate(template),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteTemplate(template),
                ),
              ],
            ),
            onTap: () => _editTemplate(template),
          ),
        );
      },
    );
  }

  Widget _buildKiWorkspaceTab() {
    return const KiWorkspaceChat();
  }

  void _createNewTemplate(String type) async {
    if (type == 'lebenslauf') {
      final action = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Neuen Lebenslauf anlegen'),
          content: const Text(
            'Möchtest du einen komplett leeren Lebenslauf anlegen oder deinen bestehenden Lebenslauf aus einer PDF-Datei importieren?',
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'empty'),
              icon: const Icon(Icons.insert_drive_file),
              label: const Text('Leeres Dokument'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, 'pdf'),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Aus PDF importieren'),
            ),
          ],
        ),
      );

      if (action == null) return;

      if (action == 'pdf') {
        try {
          final typeGroup = const XTypeGroup(label: 'PDF', extensions: ['pdf']);
          final file = await openFile(acceptedTypeGroups: [typeGroup]);
          if (file == null) return;

          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Lese PDF aus...')));
          }

          final bytes = await file.readAsBytes();
          final doc = await PdfDocument.openData(bytes);
          final StringBuffer textBuf = StringBuffer();
          for (var page in doc.pages) {
            final pageText = await page.loadText();
            if (pageText != null) {
              textBuf.writeln(pageText.fullText);
            }
          }
          doc.dispose();

          final resultText = textBuf.toString().replaceAll('\u00A0', ' ');

          final appDir = await getApplicationDocumentsDirectory();
          final savedPdfPath = p.join(
            appDir.path,
            'JobTracker',
            'Templates',
            file.name,
          );
          await File(savedPdfPath).create(recursive: true);
          await File(file.path).copy(savedPdfPath);

          final newTemplate = TemplatesCompanion(
            name: drift.Value(file.name),
            type: const drift.Value('lebenslauf'),
            content: drift.Value(resultText),
            filePath: drift.Value(savedPdfPath),
            createdAt: drift.Value(DateTime.now()),
          );

          final db = ref.read(databaseProvider);
          await db.templatesDao.insertTemplate(newTemplate);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Lebenslauf-PDF erfolgreich als Original importiert!',
                ),
                backgroundColor: Colors.green,
              ),
            );
            _loadTemplates();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Fehler beim Import: '),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        return;
      }
    }

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ApplicationEditorScreen(template: null, initialType: type),
        ),
      ).then((_) => _loadTemplates());
    }
  }

  void _editTemplate(Template template) {
    if (template.filePath != null && template.filePath!.isNotEmpty) {
      if (Platform.isWindows) {
        Process.run('explorer', [template.filePath!]);
      } else if (Platform.isMacOS) {
        Process.run('open', [template.filePath!]);
      } else if (Platform.isLinux) {
        Process.run('xdg-open', [template.filePath!]);
      }
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ApplicationEditorScreen(template: template),
      ),
    ).then((_) => _loadTemplates());
  }

  void _deleteTemplate(Template template) async {
    final db = ref.read(databaseProvider);
    await db.templatesDao.deleteTemplate(template);
    _loadTemplates();
  }

  Widget _buildPromptGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤖 ${AppLocalizations.of(context)!.promptTitle}',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.promptSubtitle,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _promptPositionController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.promptPosition,
              hintText: 'z.B. IT-Systemadministrator',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.work),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptCompanyController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.promptCompany,
              hintText: 'z.B. Musterfirma GmbH',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptSkillsController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.promptSkills,
              hintText:
                  'z.B. 5 Jahre Netzwerktechnik, ITIL-Zertifikat, Teamführung',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.star),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptToneController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.promptTone,
              hintText: 'z.B. professionell, locker, motiviert',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tune),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _generatePrompt,
              icon: const Icon(Icons.auto_awesome),
              label: Text(
                AppLocalizations.of(context)!.promptGenerate,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (_generatedPrompt.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dein generierter Prompt:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _generatedPrompt),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("In die Zwischenablage kopiert!"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_generatedPrompt),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _generatePrompt() {
    final position = _promptPositionController.text.trim();
    final company = _promptCompanyController.text.trim();
    final skills = _promptSkillsController.text.trim();
    final tone = _promptToneController.text.trim();

    setState(() {
      _generatedPrompt =
          '''Erstelle ein überzeugendes Bewerbungsanschreiben für folgende Stelle:
Position: $position
Firma: $company
Meine Skills: $skills
Tonalität: $tone''';
    });
  }
}
