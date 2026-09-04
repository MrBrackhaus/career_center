import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:drift/drift.dart' as drift;

import 'dart:convert';
import 'dart:async';

import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../../core/utils/keyword_extractor.dart';

class ApplicationEditorScreen extends ConsumerStatefulWidget {
  final int applicationId;

  const ApplicationEditorScreen({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicationEditorScreen> createState() =>
      _ApplicationEditorScreenState();
}

class _ApplicationEditorScreenState
    extends ConsumerState<ApplicationEditorScreen> {
  late quill.QuillController _controller;
  bool _isLoading = true;
  bool _hasChanges = false;
  bool _isSaving = false;
  Timer? _autoSaveTimer;
  Application? _application;

  // Design / Typography State
  String _currentFontFamily = 'Arial';
  double _currentFontSize = 14;
  double _currentLineHeight = 1.5;
  Color _currentAccentColor = Colors.blue[900]!;

  List<String> _missingKeywords = [];
  List<String> _foundKeywords = [];

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    final db = ref.read(databaseProvider);
    final app = await db.applicationsDao.getApplicationById(
      widget.applicationId,
    );

    if (app == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    _application = app;
    quill.Document document;
    if (app.coverLetterContent?.isNotEmpty == true) {
      try {
        final decoded = jsonDecode(app.coverLetterContent!);
        document = quill.Document.fromJson(decoded);
      } catch (e) {
        document = quill.Document()..insert(0, app.coverLetterContent!);
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
      _runAtsAnalysis();

      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer(const Duration(seconds: 1), () {
        if (_hasChanges) _save();
      });
    });

    setState(() {
      _isLoading = false;
    });

    // Initial analysis
    _runAtsAnalysis();
  }

  void _runAtsAnalysis() {
    if (_application?.jobDescriptionText?.isNotEmpty == true) {
      final requiredKeywords = KeywordExtractor.extractKeywords(
        _application!.jobDescriptionText!,
      );
      final plainText = _controller.document.toPlainText();
      final matched = KeywordExtractor.findMatchingKeywords(
        plainText,
        requiredKeywords,
      );

      setState(() {
        _missingKeywords = requiredKeywords
            .where((k) => !matched.contains(k))
            .toList();
        _foundKeywords = matched.toList();
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    if (!_isLoading) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final content = jsonEncode(_controller.document.toDelta().toJson());
    final db = ref.read(databaseProvider);

    final companion = ApplicationsCompanion(
      id: drift.Value(widget.applicationId),
      coverLetterContent: drift.Value(content),
    );

    await db.applicationsDao.updateApplication(companion);
    setState(() {
      _hasChanges = false;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceVariant, // The 'Desk' background
      appBar: AppBar(
        title: Text('Anschreiben: ${_application?.company}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (_isSaving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_hasChanges)
                    const Icon(Icons.sync, color: Colors.grey, size: 16)
                  else
                    const Icon(Icons.cloud_done, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _isSaving
                        ? 'Speichert...'
                        : (_hasChanges ? 'Ungespeichert' : 'Gespeichert'),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // LEFT COLUMN: Structure & Resume Palette
          Expanded(flex: 2, child: _buildLeftSidebar(colorScheme)),

          // MIDDLE COLUMN: Editor
          Expanded(flex: 6, child: _buildEditorArea(colorScheme)),

          // RIGHT COLUMN: ATS Scanner & Analysis
          Expanded(flex: 2, child: _buildRightSidebar(colorScheme)),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.dashboard_customize), text: 'Bausteine'),
                  Tab(icon: Icon(Icons.format_paint), text: 'Design'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildBausteineTab(), _buildDesignTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesignTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Dokument-Design',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildDesignCard(
          'Klassisch',
          'Serife Schrift, seriös & zeitlos',
          'Times New Roman',
          12,
          1.5,
          _currentFontFamily == 'Times New Roman',
        ),
        _buildDesignCard(
          'Modern',
          'Klare Kanten, serifenlos',
          'Arial',
          14,
          1.6,
          _currentFontFamily == 'Arial' && _currentFontSize == 14,
        ),
        _buildDesignCard(
          'Kompakt',
          'Für viel Text auf einer Seite',
          'Arial',
          10,
          1.3,
          _currentFontFamily == 'Arial' && _currentFontSize == 10,
        ),
        const Divider(height: 32),
        const Text(
          'Farbe (Akzent)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildColorDot(Colors.black),
            _buildColorDot(Colors.blue[900]!),
            _buildColorDot(Colors.teal[800]!),
            _buildColorDot(Colors.deepOrange[800]!),
          ],
        ),
      ],
    );
  }

  Widget _buildColorDot(Color color) {
    final isSelected = _currentAccentColor == color;
    return InkWell(
      onTap: () {
        setState(() {
          _currentAccentColor = color;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.5),
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  void _applyDesign(String fontFamily, double size, double height) {
    setState(() {
      _currentFontFamily = fontFamily;
      _currentFontSize = size;
      _currentLineHeight = height;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Design angewendet!')));
  }

  Widget _buildDesignCard(
    String title,
    String subtitle,
    String font,
    double size,
    double height,
    bool isSelected,
  ) {
    return Card(
      elevation: 0,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceVariant,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _applyDesign(font, size, height),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBausteineTab() {
    final db = ref.read(databaseProvider);
    return StreamBuilder<List<Template>>(
      stream: db.templatesDao.watchTemplatesByType('textbaustein'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final templates = snapshot.data ?? [];
        if (templates.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Keine Textbausteine gefunden.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_to_photos),
                    label: const Text('Beispiele laden'),
                    onPressed: () async {
                      final samples = [
                        TemplatesCompanion.insert(
                          name: 'Einleitung Klassisch',
                          type: 'textbaustein',
                          content: drift.Value(
                            '[{"insert":"Sehr geehrte Damen und Herren,\\n\\nhiermit bewerbe ich mich mit großem Interesse auf die ausgeschriebene Position.\\n"}]',
                          ),
                        ),
                        TemplatesCompanion.insert(
                          name: 'Einleitung Dynamisch',
                          type: 'textbaustein',
                          content: drift.Value(
                            '[{"insert":"Sehr geehrte Damen und Herren,\\n\\nIhre Unternehmenswerte haben mich sofort begeistert, weshalb ich mich freue, mich Ihnen als engagierter Kandidat vorzustellen.\\n"}]',
                          ),
                        ),
                        TemplatesCompanion.insert(
                          name: 'Gehaltsvorstellung',
                          type: 'textbaustein',
                          content: drift.Value(
                            '[{"insert":"Meine Gehaltsvorstellungen liegen bei einem Bruttojahresgehalt von 55.000 Euro. Ein Einstieg ist ab dem 01.12. möglich.\\n"}]',
                          ),
                        ),
                        TemplatesCompanion.insert(
                          name: 'Teamfähigkeit',
                          type: 'textbaustein',
                          content: drift.Value(
                            '[{"insert":"In meinen bisherigen Projekten konnte ich stets durch eine starke Teamfähigkeit und lösungsorientierte Arbeitsweise überzeugen.\\n"}]',
                          ),
                        ),
                        TemplatesCompanion.insert(
                          name: 'Call to Action',
                          type: 'textbaustein',
                          content: drift.Value(
                            '[{"insert":"Ich freue mich sehr auf die Gelegenheit, Sie in einem persönlichen Gespräch von meiner Eignung zu überzeugen.\\n\\nMit freundlichen Grüßen\\n"}]',
                          ),
                        ),
                      ];
                      for (final t in samples) {
                        await db.templatesDao.insertTemplate(t);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final t = templates[index];
            return _buildDraggableBlock(t);
          },
        );
      },
    );
  }

  Widget _buildDraggableBlock(Template template) {
    // Generate a short preview of the text
    String preview = '...';
    try {
      if (template.content != null && template.content!.isNotEmpty) {
        final List<dynamic> ops = jsonDecode(template.content!);
        final doc = quill.Document.fromJson(ops);
        preview = doc.toPlainText().replaceAll('\n', ' ').trim();
      }
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (template.content != null) {
            try {
              final ops = jsonDecode(template.content!);
              final docToInsert = quill.Document.fromJson(ops);
              final length = docToInsert.length;
              final currentSelection = _controller.selection;

              _controller.document.insert(
                currentSelection.baseOffset,
                docToInsert.toPlainText(),
              );
              _controller.updateSelection(
                TextSelection.collapsed(
                  offset: currentSelection.baseOffset + length - 1,
                ),
                quill.ChangeSource.local,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Baustein eingefügt.')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fehler beim Einfügen: $e')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.add_circle_outline, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorArea(ColorScheme colorScheme) {
    return Column(
      children: [
        // Restricted Toolbar
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: quill.QuillSimpleToolbar(
            controller: _controller,
            config: quill.QuillSimpleToolbarConfig(
              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              showFontFamily: false,
              showFontSize: true,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: true,
              showBackgroundColorButton: false,
              showClearFormat: true,
              showAlignmentButtons: true,
              showLeftAlignment: true,
              showCenterAlignment: true,
              showRightAlignment: true,
              showJustifyAlignment: true,
              showHeaderStyle: false,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showLink: false,
              showUndo: true,
              showRedo: true,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
            ),
          ),
        ),

        // Google Docs Style Canvas
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Container(
                    width: 794, // A4 width at 96 DPI
                    constraints: BoxConstraints(
                      minHeight: 1123, // A4 height at 96 DPI
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    // DIN 5008 Margins: Top: 45mm/27mm, Bottom: 20mm, Left: 25mm, Right: 20mm
                    // 1mm ~= 3.78 pixels
                    padding: const EdgeInsets.only(
                      left: 94, // 25mm
                      right: 75, // 20mm
                      top: 170, // 45mm (first page)
                      bottom: 75, // 20mm
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: _currentFontFamily,
                        fontSize: _currentFontSize,
                        color: Colors.black,
                        height: _currentLineHeight,
                      ),
                      child: quill.QuillEditor.basic(
                        controller: _controller,
                        config: quill.QuillEditorConfig(
                          placeholder: 'Schreibe hier dein Anschreiben...',
                          padding: EdgeInsets.zero,
                          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                          autoFocus: false,
                          expands: false,
                          scrollable: false, // Let the SingleChildScrollView handle scrolling!
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRightSidebar(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(left: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Live Job-Fit (ATS)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (_application?.jobDescriptionText == null ||
              _application!.jobDescriptionText!.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.paste),
                label: const Text('Stellenanzeige einfügen'),
                onPressed: _pasteJobDescription,
              ),
            )
          else ...[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Geforderte Skills',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_foundKeywords.isEmpty && _missingKeywords.isEmpty)
                    const Text(
                      'Keine Keywords gefunden.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    )
                  else ...[
                    ..._foundKeywords.map(
                      (k) => _buildKeywordChip(context, k, true),
                    ),
                    ..._missingKeywords.map(
                      (k) => _buildKeywordChip(context, k, false),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Tonalitäts-Check',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.warning, color: Colors.orange),
                    title: Text(
                      'Veraltete Floskel',
                      style: TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      '"Hiermit bewerbe ich mich..."',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _pasteJobDescription() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Stellenanzeige einfügen'),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: ctrl,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Füge hier den Text der Stellenanzeige ein...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.applicationsDao.updateApplication(
                  ApplicationsCompanion(
                    id: drift.Value(widget.applicationId),
                    jobDescriptionText: drift.Value(ctrl.text.trim()),
                  ),
                );
                final updatedApp = await db.applicationsDao.getApplicationById(
                  widget.applicationId,
                );
                setState(() {
                  _application = updatedApp;
                });
                _runAtsAnalysis();
              }
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Speichern & Analysieren'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordChip(BuildContext context, String keyword, bool found) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = found ? Colors.green : colorScheme.onSurface.withOpacity(0.5);
    final textColor = found
        ? colorScheme.onSurface
        : colorScheme.onSurface.withOpacity(0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            found ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              keyword,
              style: TextStyle(
                color: textColor,
                decoration: found
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
