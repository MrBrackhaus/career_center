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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:convert';
import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../../l10n/app_localizations.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Template> _templates = [];
  bool _isLoading = true;

  // Prompt Generator state
  final _promptPositionController = TextEditingController();
  final _promptCompanyController = TextEditingController();
  final _promptSkillsController = TextEditingController();
  final _promptToneController = TextEditingController();
bool _initializedTone = false;
  String _generatedPrompt = '';

  @override
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTone) {
      _promptToneController.text = AppLocalizations.of(context)!.promptToneDefault;
      _initializedTone = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            tabs: [
              Tab(icon: Icon(Icons.description), text: AppLocalizations.of(context)!.templatesTabMy),
              Tab(icon: Icon(Icons.auto_awesome), text: 'Prompt Generator'),
              Tab(icon: Icon(Icons.library_books), text: AppLocalizations.of(context)!.templatesTabExamples),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTemplatesTab(),
                _buildPromptGeneratorTab(),
                _buildExamplesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _createNewTemplate,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // === TAB 1: MEINE VORLAGEN ===
  Widget _buildTemplatesTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.templatesEmpty, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context)!.templatesCreateFirst),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createNewTemplate,
              icon: const Icon(Icons.add),
              label: Text(AppLocalizations.of(context)!.templatesNew),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        IconData icon;
        switch (template.type) {
          case 'anschreiben':
            icon = Icons.mail_outline;
            break;
          case 'lebenslauf':
            icon = Icons.person_outline;
            break;
          default:
            icon = Icons.text_snippet_outlined;
        }

        return Card(
          child: ListTile(
            leading: Icon(icon, size: 32),
            title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              template.type.toUpperCase(),
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

  // === TAB 2: PROMPT GENERATOR ===
  Widget _buildPromptGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🤖 ' + AppLocalizations.of(context)!.promptTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.promptSubtitle, style: const TextStyle(color: Colors.grey)),
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
              hintText: 'z.B. 5 Jahre Netzwerktechnik, ITIL-Zertifikat, Teamführung',
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
              label: Text(AppLocalizations.of(context)!.promptGenerate, style: TextStyle(fontSize: 16)),
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
                                            const Text('Dein generierter Prompt:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: const Icon(Icons.copy),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: _generatedPrompt));
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("In die Zwischenablage kopiert!")));
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
                              ]
                            ],
                          ),
                        );
                      }

                      Widget _buildExamplesTab() {
                        final examples = [
                          {'type': 'ANSCHREIBEN', 'title': 'Initiativbewerbung', 'content': 'Sehr geehrte Damen und Herren,\n\nmit großem Interesse...'},
                          {'type': 'ANSCHREIBEN', 'title': 'Antwort auf Stellenanzeige', 'content': 'Sehr geehrte(r) Herr/Frau [Name],\n\nIhre Stellenanzeige...'},
                          {'type': 'TEXTBAUSTEIN', 'title': 'Erinnerung / Follow-up', 'content': 'Sehr geehrte(r) Herr/Frau [Name],\n\nich möchte mich kurz...'},
                          {'type': 'TEXTBAUSTEIN', 'title': 'Absage höflich beantworten', 'content': 'Sehr geehrte(r) Herr/Frau [Name],\n\nvielen Dank für Ihre Rückmeldung...'},
                        ];
                        
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: examples.length,
                          itemBuilder: (context, index) {
                            final ex = examples[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                leading: Icon(ex['type'] == 'ANSCHREIBEN' ? Icons.description : Icons.short_text),
                                title: Text(ex['title'] as String),
                                subtitle: Text(ex['type'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    width: double.infinity,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    child: SelectableText(ex['content'] as String, style: const TextStyle(fontFamily: 'monospace')),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      }

                      void _createNewTemplate() {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const _TemplateEditorPage(template: null))).then((_) => _loadTemplates());
                      }

                      void _editTemplate(Template template) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => _TemplateEditorPage(template: template))).then((_) => _loadTemplates());
                      }

                      void _deleteTemplate(Template template) async {
                        final db = ref.read(databaseProvider);
                        await db.templatesDao.deleteTemplate(template);
                        _loadTemplates();
                      }

                      void _generatePrompt() {
                        final position = _promptPositionController.text.trim();
                        final company = _promptCompanyController.text.trim();
                        final skills = _promptSkillsController.text.trim();
                        final tone = _promptToneController.text.trim();
                        
                        setState(() {
                          _generatedPrompt = '''Erstelle ein überzeugendes Bewerbungsanschreiben für folgende Stelle:
Position: $position
Firma: $company
Meine Skills: $skills
Tonalität: $tone''';
                        });
                      }
                    }

                    class _TemplateEditorPage extends ConsumerStatefulWidget {
                      final Template? template;
                      const _TemplateEditorPage({this.template});

                      @override
                      ConsumerState<_TemplateEditorPage> createState() => _TemplateEditorPageState();
                    }

                    class _TemplateEditorPageState extends ConsumerState<_TemplateEditorPage> {
                      late quill.QuillController _controller;
                      bool _hasChanges = false;
                      final _nameController = TextEditingController();

                      @override
                      void initState() {
                        super.initState();
                        _nameController.text = widget.template?.name ?? '';
                        quill.Document document;
                        if (widget.template?.content?.isNotEmpty == true) {
                          try {
                            final decoded = jsonDecode(widget.template!.content!);
                            document = quill.Document.fromJson(decoded);
                          } catch (e) {
                            document = quill.Document()..insert(0, widget.template!.content!);
                          }
                        } else {
                          document = quill.Document();
                        }
                        _controller = quill.QuillController(
                          document: document,
                          selection: const TextSelection.collapsed(offset: 0),
                        );
                        _controller.addListener(() {
                          if (!_hasChanges) setState(() => _hasChanges = true);
                        });
                        _nameController.addListener(() {
                          if (!_hasChanges) setState(() => _hasChanges = true);
                        });
                      }

                      @override
                      void dispose() {
                        _controller.dispose();
                        _nameController.dispose();
                        super.dispose();
                      }

                      void _save() async {
                        final content = jsonEncode(_controller.document.toDelta().toJson());
                        final name = _nameController.text.isNotEmpty ? _nameController.text : 'Neue Vorlage';
                        final db = ref.read(databaseProvider);
                        if (widget.template == null) {
                          final newTemplate = TemplatesCompanion(
                            name: drift.Value(name),
                            type: const drift.Value('anschreiben'),
                            content: drift.Value(content),
                            createdAt: drift.Value(DateTime.now()),
                          );
                          await db.templatesDao.insertTemplate(newTemplate);
                        } else {
                          final template = TemplatesCompanion(
                            id: drift.Value(widget.template!.id),
                            name: drift.Value(name),
                            type: drift.Value(widget.template!.type),
                            content: drift.Value(content),
                          );
                          await db.templatesDao.updateTemplate(template);
                        }
                        if (mounted) Navigator.pop(context);
                      }

                      @override
                      Widget build(BuildContext context) {
                        return Scaffold(
                          appBar: AppBar(
                            title: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Vorlagenname'),
                              style: const TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            actions: [
                              if (_hasChanges)
                                IconButton(icon: const Icon(Icons.save), onPressed: _save),
                            ],
                          ),
                          body: Column(
                            children: [
                              quill.QuillSimpleToolbar(
                                controller: _controller,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: quill.QuillEditor.basic(
                                    controller: _controller,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
