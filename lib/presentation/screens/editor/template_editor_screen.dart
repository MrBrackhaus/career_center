import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:convert';
import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';

class TemplateEditorScreen extends ConsumerStatefulWidget {
  final Template? template;
  
  const TemplateEditorScreen({super.key, this.template});

  @override
  ConsumerState<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
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

  void _insertVariable(String variable) {
    final index = _controller.selection.baseOffset;
    final length = _controller.selection.extentOffset - index;
    _controller.replaceText(index, length, variable, null);
    _controller.moveCursorToPosition(index + variable.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: TextField(
          controller: _nameController,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Vorlagenname'),
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          if (_hasChanges)
            IconButton(icon: const Icon(Icons.save), onPressed: _save, tooltip: 'Speichern'),
        ],
      ),
      body: Column(
        children: [
          // Restricted Toolbar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: quill.QuillSimpleToolbar(
              controller: _controller,
              config: quill.QuillSimpleToolbarConfig(
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
          
          // Smart Variables Toolbar
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text('Variablen:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(width: 16),
                  ActionChip(
                    label: const Text('+ Unternehmen'),
                    onPressed: () => _insertVariable('{{COMPANY_NAME}}'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('+ Position'),
                    onPressed: () => _insertVariable('{{POSITION}}'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('+ Ansprechpartner'),
                    onPressed: () => _insertVariable('{{CONTACT_NAME}}'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('+ Datum'),
                    onPressed: () => _insertVariable('{{DATE}}'),
                  ),
                ],
              ),
            ),
          ),
          
          // A4 Editor Area
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AspectRatio(
                  aspectRatio: 1 / 1.414, // DIN A4 proportion
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48), // Simulate page margins
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
      ),
    );
  }
}
