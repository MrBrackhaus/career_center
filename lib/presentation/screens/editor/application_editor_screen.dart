import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';
import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../../core/utils/keyword_extractor.dart';

class ApplicationEditorScreen extends ConsumerStatefulWidget {
  final int applicationId;

  const ApplicationEditorScreen({super.key, required this.applicationId});

  @override
  ConsumerState<ApplicationEditorScreen> createState() => _ApplicationEditorScreenState();
}

class _ApplicationEditorScreenState extends ConsumerState<ApplicationEditorScreen> {
  late quill.QuillController _controller;
  bool _isLoading = true;
  bool _hasChanges = false;
  Application? _application;
  
  List<String> _missingKeywords = [];
  List<String> _foundKeywords = [];

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    final db = ref.read(databaseProvider);
    final app = await db.applicationsDao.getApplicationById(widget.applicationId);
    
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
    });

    setState(() {
      _isLoading = false;
    });
    
    // Initial analysis
    _runAtsAnalysis();
  }

  void _runAtsAnalysis() {
    if (_application?.jobDescriptionText?.isNotEmpty == true) {
      final requiredKeywords = KeywordExtractor.extractKeywords(_application!.jobDescriptionText!);
      final plainText = _controller.document.toPlainText();
      final matched = KeywordExtractor.findMatchingKeywords(plainText, requiredKeywords);
      
      setState(() {
        _missingKeywords = requiredKeywords.where((k) => !matched.contains(k)).toList();
        _foundKeywords = matched.toList();
      });
    }
  }

  @override
  void dispose() {
    if (!_isLoading) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final content = jsonEncode(_controller.document.toDelta().toJson());
    final db = ref.read(databaseProvider);
    
    final companion = ApplicationsCompanion(
      id: drift.Value(widget.applicationId),
      coverLetterContent: drift.Value(content),
    );
    
    await db.applicationsDao.updateApplication(companion);
    setState(() => _hasChanges = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anschreiben gespeichert.')));
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
          if (_hasChanges)
            IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Speichern'),
        ],
      ),
      body: Row(
        children: [
          // LEFT COLUMN: Structure & Resume Palette
          Expanded(
            flex: 2,
            child: _buildLeftSidebar(colorScheme),
          ),
          
          // MIDDLE COLUMN: Editor
          Expanded(
            flex: 6,
            child: _buildEditorArea(colorScheme),
          ),
          
          // RIGHT COLUMN: ATS Scanner & Analysis
          Expanded(
            flex: 2,
            child: _buildRightSidebar(colorScheme),
          ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Bausteine & Lebenslauf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildDraggableBlock('Starke Einleitung', 'Hiermit bewerbe ich mich...'),
                _buildDraggableBlock('Gehaltsvorstellung', 'Meine Gehaltsvorstellung liegt bei...'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDraggableBlock(String title, String contentPreview) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(contentPreview, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.drag_indicator),
        onTap: () {
          // Implement insertion on tap
        },
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
            border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
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
              showColorButton: false,
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
        
        // A4 Editor Area
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: AspectRatio(
                aspectRatio: 1 / 1.414,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface, // Adapts to light/dark mode
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
                  child: quill.QuillEditor.basic(
                    controller: _controller,
                    config: quill.QuillEditorConfig(
                      placeholder: 'Schreibe hier dein Anschreiben...',
                      padding: EdgeInsets.zero,
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                    ),
                  ),
                ),
              ),
            ),
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
            child: Text('Live Job-Fit (ATS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          if (_application?.jobDescriptionText == null || _application!.jobDescriptionText!.isEmpty)
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
                  const Text('Geforderte Skills', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_foundKeywords.isEmpty && _missingKeywords.isEmpty)
                    const Text('Keine Keywords gefunden.', style: TextStyle(color: Colors.grey, fontSize: 12))
                  else ...[
                    ..._foundKeywords.map((k) => _buildKeywordChip(context, k, true)),
                    ..._missingKeywords.map((k) => _buildKeywordChip(context, k, false)),
                  ],
                  const SizedBox(height: 24),
                  const Text('Tonalitäts-Check', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.warning, color: Colors.orange),
                    title: Text('Veraltete Floskel', style: TextStyle(fontSize: 13)),
                    subtitle: Text('"Hiermit bewerbe ich mich..."', style: TextStyle(fontSize: 12)),
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.applicationsDao.updateApplication(ApplicationsCompanion(
                  id: drift.Value(widget.applicationId),
                  jobDescriptionText: drift.Value(ctrl.text.trim()),
                ));
                final updatedApp = await db.applicationsDao.getApplicationById(widget.applicationId);
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
    final textColor = found ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(found ? Icons.check_circle : Icons.cancel, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              keyword, 
              style: TextStyle(
                color: textColor,
                decoration: found ? TextDecoration.none : TextDecoration.lineThrough,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
