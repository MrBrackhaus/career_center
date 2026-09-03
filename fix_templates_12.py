path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Keep only up to line 263
new_lines = lines[:263]

missing_code = """
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Dein generierter Prompt:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: const Icon(Icons.copy),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: _generatedPrompt));
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.promptCopied)));
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
                          {'type': 'ANSCHREIBEN', 'title': 'Initiativbewerbung', 'content': 'Sehr geehrte Damen und Herren,\\n\\nmit großem Interesse...'},
                          {'type': 'ANSCHREIBEN', 'title': 'Antwort auf Stellenanzeige', 'content': 'Sehr geehrte(r) Herr/Frau [Name],\\n\\nIhre Stellenanzeige...'},
                          {'type': 'TEXTBAUSTEIN', 'title': 'Erinnerung / Follow-up', 'content': 'Sehr geehrte(r) Herr/Frau [Name],\\n\\nich möchte mich kurz...'},
                          {'type': 'TEXTBAUSTEIN', 'title': 'Absage höflich beantworten', 'content': 'Sehr geehrte(r) Herr/Frau [Name],\\n\\nvielen Dank für Ihre Rückmeldung...'},
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
                          final newTemplate = drift.TemplatesCompanion(
                            name: drift.Value(name),
                            type: const drift.Value('anschreiben'),
                            content: drift.Value(content),
                            createdAt: drift.Value(DateTime.now()),
                          );
                          await db.templatesDao.insertTemplate(newTemplate);
                        } else {
                          final template = drift.TemplatesCompanion(
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
                              quill.QuillToolbar.simple(
                                configurations: quill.QuillSimpleToolbarConfigurations(
                                  controller: _controller,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: quill.QuillEditor.basic(
                                    configurations: quill.QuillEditorConfigurations(
                                      controller: _controller,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
"""

with open(path, 'w', encoding='utf-8') as f:
    f.write(''.join(new_lines) + missing_code)

print("Restored cleanly!")
