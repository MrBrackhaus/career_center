import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:drift/drift.dart' as drift;

import 'dart:convert';
import 'dart:async';

import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../../core/utils/keyword_extractor.dart';
import '../../../core/utils/spell_checker.dart';
import 'editor_ruler.dart';
import '../../providers/ai_correction_provider.dart';
import '../../providers/document_template_provider.dart';

import 'package:intl/intl.dart';

class ApplicationEditorScreen extends ConsumerStatefulWidget {
  final int? applicationId;
  final Template? template;
  final String? initialType;

  const ApplicationEditorScreen({
    super.key,
    this.applicationId,
    this.template,
    this.initialType,
  });

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
  final FocusNode _editorFocusNode = FocusNode();
  final _nameController = TextEditingController();

  // Margins
  double _marginTop = 170.0;
  double _marginBottom = 75.0;

  String _currentDesignId = 'modern';
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userAddress = '';
  String _userZip = '';
  String _userCity = '';
  String _userProfession = '';

  // Header Editing Controllers
  final TextEditingController _headerCompanyNameCtrl = TextEditingController(text: 'Unternehmensname');
  final TextEditingController _headerContactNameCtrl = TextEditingController(text: 'Personalabteilung');
  final TextEditingController _headerCompanyAddressCtrl = TextEditingController(text: 'Adresse');
  final TextEditingController _headerDateCtrl = TextEditingController(text: 'Datum');
  
  final TextEditingController _headerUserEmailCtrl = TextEditingController(text: 'email');
  final TextEditingController _headerUserPhoneCtrl = TextEditingController(text: 'telefon');
  final TextEditingController _headerUserAddressCtrl = TextEditingController(text: 'adresse');

  final TextEditingController _headerUserNameCtrl = TextEditingController(text: 'Name');
  final TextEditingController _headerUserProfessionCtrl = TextEditingController(text: 'Beruf');


  double _marginLeft = 94.0;
  double _marginRight = 75.0;

  Timer? _spellCheckTimer;
  bool _isSpellChecking = false;
  List<Map<String, dynamic>> _grammarWarnings = [];

  // Design / Typography State
  String _currentFontFamily = 'Segoe UI';
  double _currentFontSize = 14;
  double _currentLineHeight = 1.5;
  Color _currentAccentColor = Colors.blue[900]!;

  List<String> _missingKeywords = [];
  List<String> _foundKeywords = [];

  Future<void> _runAiCorrection() async {
    final text = _controller.document.toPlainText();
    if (text.trim().isEmpty) return;

    final lang = SpellChecker.currentLanguage;
    final correctedText = await ref
        .read(aiCorrectionProvider.notifier)
        .correctText(text, lang);

    if (correctedText != null && correctedText.isNotEmpty && mounted) {
      final length = _controller.document.length;
      _controller.replaceText(
        0,
        length - 1,
        correctedText,
        const TextSelection.collapsed(offset: 0),
      );
    }
  }

  Future<void> _insertHeader() async {
    final lang = SpellChecker.currentLanguage;
    final templateService = ref.read(documentTemplateServiceProvider);
    final headerText = await templateService.generateHeader(_application, lang);

    _controller.document.insert(0, headerText);

    String subjectPrefix = 'Bewerbung als ';
    if (lang == 'en')
      subjectPrefix = 'Application for ';
    else if (lang == 'fr')
      subjectPrefix = 'Candidature pour le poste de ';
    else if (lang == 'es')
      subjectPrefix = 'Candidatura para el puesto de ';

    final subjectStart = headerText.indexOf(subjectPrefix);
    final subjectEnd = headerText.indexOf('\n', subjectStart);
    if (subjectStart != -1 && subjectEnd != -1) {
      _controller.formatText(
        subjectStart,
        subjectEnd - subjectStart,
        quill.Attribute.bold,
      );
    }
  }

  void _insertFooter() {
    final len = _controller.document.length;
    final footer =
        "\n\nMit freundlichen Gruessen\n\n\nMax Mustermann\n\nAnlagen";
    _controller.document.insert(len - 1, footer);
  }

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  Future<void> _loadApplication() async {
    final db = ref.read(databaseProvider);
    final langSetting = await db.settingsDao.getSettingByKey(
      'spellCheckLanguage',
    );
    SpellChecker.loadDictionary(language: langSetting?.value ?? 'de');

    final nameSetting = await db.settingsDao.getSettingByKey('userName');
    final emailSetting = await db.settingsDao.getSettingByKey('userEmail');
    final phoneSetting = await db.settingsDao.getSettingByKey('userPhone');
    final addressSetting = await db.settingsDao.getSettingByKey('userAddress');
    final zipSetting = await db.settingsDao.getSettingByKey('userZip');
    final citySetting = await db.settingsDao.getSettingByKey('userCity');
    
    if (mounted) {
      setState(() {
        _userName = nameSetting?.value ?? 'Dein Name';
        _userEmail = emailSetting?.value ?? 'email@beispiel.de';
        _userPhone = phoneSetting?.value ?? '0123-456789';
        _userAddress = addressSetting?.value ?? 'Musterstraße 1';
        _userZip = zipSetting?.value ?? '12345';
        _userCity = citySetting?.value ?? 'Musterstadt';
          _userProfession = 'FACHINFORMATIKER FÜR SYSTEMINTEGRATION';
          
          _headerUserNameCtrl.text = _userName;
          _headerUserProfessionCtrl.text = _userProfession;
          _headerUserEmailCtrl.text = _userEmail;
          _headerUserPhoneCtrl.text = _userPhone;
          _headerUserAddressCtrl.text = '${_userAddress}\n${_userZip} ${_userCity}';
          
          _headerDateCtrl.text = "${_userCity.isNotEmpty ? _userCity : 'Stadt'}, den ${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}";
      });
    }


    _nameController.text = widget.template?.name ?? '';

    if (widget.applicationId == null && widget.template == null) {
      _application = null;
      _controller = quill.QuillController(
        document: quill.Document(),
        selection: const TextSelection.collapsed(offset: 0),
        config: const quill.QuillControllerConfig(
          clipboardConfig: quill.QuillClipboardConfig(
            enableExternalRichPaste: false,
          ),
        ),
      );
      _attachControllerListener();
      setState(() {
        _isLoading = false;
      });
      _runAtsAnalysis();
      return;
    }

    quill.Document document = quill.Document();

    if (widget.template != null) {
      if (widget.template?.content?.isNotEmpty == true) {
        try {
          final decoded = jsonDecode(widget.template!.content!);
          document = quill.Document.fromJson(decoded);
        } catch (e) {
          document = quill.Document()..insert(0, widget.template!.content!);
        }
      }
    } else if (widget.applicationId != null) {
      final app = await db.applicationsDao.getApplicationById(
        widget.applicationId!,
      );

      if (app == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      _application = app;
          _headerCompanyNameCtrl.text = app.company;
          _headerContactNameCtrl.text = app.contactName ?? 'Personalabteilung';
          _headerCompanyAddressCtrl.text = app.address ?? 'Musterstraße 1, 12345 Stadt';
      if (app.coverLetterContent?.isNotEmpty == true) {
        try {
          final decoded = jsonDecode(app.coverLetterContent!);
          document = quill.Document.fromJson(decoded);
        } catch (e) {
          document = quill.Document()..insert(0, app.coverLetterContent!);
        }
      }
    }

    _controller = quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      config: const quill.QuillControllerConfig(
        clipboardConfig: quill.QuillClipboardConfig(
          enableExternalRichPaste: false,
        ),
      ),
    );
    _attachControllerListener();
    setState(() {
      _isLoading = false;
    });
    _runAtsAnalysis();
  }

  void _attachControllerListener() {
    _controller.addListener(() {
      if (!_hasChanges) setState(() => _hasChanges = true);

      // Debounce ALL analysis (keywords + spelling) so we never call
      // setState during active typing → cursor stays stable.
      _spellCheckTimer?.cancel();
      _spellCheckTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _runAtsAnalysis();
      });

      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer(const Duration(seconds: 2), () {
        if (_hasChanges) _save();
      });
    });
  }

  void _runAtsAnalysis() {
    final plainText = _controller.document.toPlainText();

    List<String> newMissing = _missingKeywords;
    List<String> newFound = _foundKeywords;

    if (_application?.jobDescriptionText?.isNotEmpty == true) {
      final requiredKeywords = KeywordExtractor.extractKeywords(
        _application!.jobDescriptionText!,
      );
      final matched = KeywordExtractor.findMatchingKeywords(
        plainText,
        requiredKeywords,
      );
      newMissing = requiredKeywords.where((k) => !matched.contains(k)).toList();
      newFound = matched.toList();
    }

    setState(() => _isSpellChecking = true);
    SpellChecker.checkText(plainText).then((issues) {
      if (!mounted) return;
      setState(() {
        _missingKeywords = newMissing;
        _foundKeywords = newFound;
        _grammarWarnings = issues;
        _isSpellChecking = false;
      });
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _spellCheckTimer?.cancel();
    _editorFocusNode.dispose();
    if (!_isLoading) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final content = jsonEncode(_controller.document.toDelta().toJson());
    final db = ref.read(databaseProvider);

    if (widget.applicationId != null) {
      final companion = ApplicationsCompanion(
        id: drift.Value(widget.applicationId!),
        coverLetterContent: drift.Value(content),
      );
      await db.applicationsDao.updateApplication(companion);
    } else {
      // Save as template
      final name = _nameController.text.trim().isEmpty
          ? 'Neues Dokument'
          : _nameController.text.trim();
      final type = widget.template?.type ?? widget.initialType ?? 'anschreiben';

      if (widget.template != null) {
        final companion = TemplatesCompanion(
          id: drift.Value(widget.template!.id),
          name: drift.Value(name),
          type: drift.Value(type),
          content: drift.Value(content),
        );
        await db.templatesDao.updateTemplate(companion);
      } else {
        final companion = TemplatesCompanion(
          name: drift.Value(name),
          type: drift.Value(type),
          content: drift.Value(content),
          createdAt: drift.Value(DateTime.now()),
        );
        await db.templatesDao.insertTemplate(companion);
        // Da wir kein Template-Objekt haben, navigieren wir am besten zurÃ¼ck oder zeigen "Gespeichert" an
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Als Vorlage gespeichert.')),
        );
      }
    }

    setState(() {
      _hasChanges = false;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AiCorrectionState>(aiCorrectionProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest, // The 'Desk' background
      appBar: AppBar(
        title: widget.applicationId != null
            ? Text('Anschreiben: ${_application?.company}')
            : TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Dokumentname (z.B. Lebenslauf)',
                ),
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
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
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
        Text(
          'Dokument-Design',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 16),
        _buildDesignCard('Klassisch', 'Serife Schrift, seriös & zeitlos', 'klassisch'),
        _buildDesignCard('Modern', 'Klare Kanten, serifenlos', 'modern'),
        _buildDesignCard('Kompakt', 'Für viel Text auf einer Seite', 'kompakt'),
        _buildDesignCard('Monogram', 'Professionelles Layout mit blauem Monogramm', 'monogram'),
        
          Divider(height: 32),
          
        Text(
          'Seitenränder',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        _buildMarginSlider(
          'Oben',
          _marginTop,
          (v) => setState(() => _marginTop = v),
          37.8,
          226.8,
        ), // 10mm - 60mm
        _buildMarginSlider(
          'Unten',
          _marginBottom,
          (v) => setState(() => _marginBottom = v),
          37.8,
          151.2,
        ), // 10mm - 40mm
        _buildMarginSlider(
          'Links',
          _marginLeft,
          (v) => setState(() => _marginLeft = v),
          37.8,
          151.2,
        ),
        _buildMarginSlider(
          'Rechts',
          _marginRight,
          (v) => setState(() => _marginRight = v),
          37.8,
          151.2,
        ),
        Divider(height: 32),
        Text(
          'DIN 5008 Elemente',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _insertHeader(),
          icon: Icon(Icons.contact_mail),
          label: Text('Briefkopf einfuegen'),
          style: FilledButton.styleFrom(alignment: Alignment.centerLeft),
        ),
        SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _insertFooter,
          icon: Icon(Icons.draw),
          label: Text('Unterschrift & Fusszeile einfuegen'),
          style: FilledButton.styleFrom(alignment: Alignment.centerLeft),
        ),
        Divider(height: 32),
        Text(
          'Farbe (Akzent)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        SizedBox(height: 8),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildColorDot(Colors.black),
              _buildColorDot(Colors.grey[800]!),
              _buildColorDot(Colors.blueGrey[800]!),
              _buildColorDot(Colors.blue[900]!),
              _buildColorDot(Colors.lightBlue[800]!),
              _buildColorDot(Colors.indigo[800]!),
              _buildColorDot(Colors.purple[800]!),
              _buildColorDot(Colors.teal[800]!),
              _buildColorDot(Colors.green[800]!),
              _buildColorDot(Colors.deepOrange[800]!),
              _buildColorDot(Colors.red[800]!),
              _buildColorDot(Colors.brown[800]!),
            ],
          ),
          const SizedBox(height: 60),
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
                ? _currentAccentColor
                : Colors.grey.withOpacity(0.5),
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  void _applyDesign(String designId) {
    setState(() {
      _currentDesignId = designId;
      if (designId == 'klassisch') {
        _currentFontFamily = 'Times New Roman';
        _currentFontSize = 12;
        _currentLineHeight = 1.5;
      } else if (designId == 'modern') {
        _currentFontFamily = 'Segoe UI';
        _currentFontSize = 14;
        _currentLineHeight = 1.6;
      } else if (designId == 'kompakt') {
        _currentFontFamily = 'Arial';
        _currentFontSize = 10;
        _currentLineHeight = 1.3;
      } else if (designId == 'monogram') {
        _currentFontFamily = 'Segoe UI';
        _currentFontSize = 12;
        _currentLineHeight = 1.5;
      }
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Design angewendet!')));
  }

  Widget _buildMarginSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
    double min,
    double max,
  ) {
    final mm = (value / 3.78).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '$label: $mm mm',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildDesignCard(
    String title,
    String subtitle,
    String designId,
  ) {
    bool isSelected = _currentDesignId == designId;
    return Card(
      elevation: 0,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected
              ? _currentAccentColor
              : Theme.of(context).colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _applyDesign(designId),
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
                  Text(
                    'Keine Textbausteine gefunden.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add_to_photos),
                    label: Text('Beispiele laden'),
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
          padding: EdgeInsets.all(8),
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
      margin: EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
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

  
  Widget _buildEditableText(TextEditingController controller, double fontSize, {FontWeight? fontWeight, int? maxLines = 1, Color color = Colors.black87, TextAlign textAlign = TextAlign.left}) {
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight),
      textAlign: textAlign,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildProfessionalHeader() {
    if (_currentDesignId != 'monogram') return const SizedBox.shrink();
    
    final name = _userName.trim().isNotEmpty ? _userName.trim() : 'Max Mustermann';
    final initials = name.split(' ').where((e) => e.isNotEmpty).map((e) => e[0].toUpperCase()).take(2).join('');

    return Padding(
      padding: const EdgeInsets.only(left: 94, right: 75, top: 50, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: _currentAccentColor, width: 3),
                    bottom: BorderSide(color: _currentAccentColor, width: 3),
                  ),
                ),
                padding: const EdgeInsets.only(left: 12, bottom: 4, right: 12, top: 4),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF374151),
                    letterSpacing: -2,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditableText(_headerUserNameCtrl, 32, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937)),
                    const SizedBox(height: 4),
                    _buildEditableText(_headerUserProfessionCtrl, 14, color: const Color(0xFF4B5563)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'PERSÖNLICHE DATEN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _currentAccentColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: _currentAccentColor),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('E-MAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildEditableText(_headerUserEmailCtrl, 12, color: const Color(0xFF4B5563)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ANSCHRIFT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildEditableText(_headerUserAddressCtrl, 12, color: const Color(0xFF4B5563), maxLines: null),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TELEFON', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildEditableText(_headerUserPhoneCtrl, 12, color: const Color(0xFF4B5563)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditableText(_headerCompanyNameCtrl, 12),
                    _buildEditableText(_headerContactNameCtrl, 12),
                    _buildEditableText(_headerCompanyAddressCtrl, 12, maxLines: null),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                child: _buildEditableText(_headerDateCtrl, 12, textAlign: TextAlign.right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalFooter() {
    if (_currentDesignId != 'monogram') return SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      height: 20,
      margin: EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _currentAccentColor, width: 3),
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: quill.QuillSimpleToolbar(
                  controller: _controller,
                  config: quill.QuillSimpleToolbarConfig(
                    embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                    buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                      fontSize: quill.QuillToolbarFontSizeButtonOptions(
                        items: {
                          '8pt': '8.0',
                          '9pt': '9.0',
                          '10pt': '10.0',
                          '11pt': '11.0',
                          '12pt': '12.0',
                          '14pt': '14.0',
                          '18pt': '18.0',
                          '24pt': '24.0',
                          'Standard': '0',
                        },
                      ),
                      fontFamily: quill.QuillToolbarFontFamilyButtonOptions(
                        items: {
                          'Segoe UI (Original)': 'Segoe UI',
                          'Calibri': 'Calibri',
                          'Arial': 'Arial',
                          'Roboto': 'Roboto',
                          'Times New Roman': 'Times New Roman',
                          'Cambria': 'Cambria',
                          'Georgia': 'Georgia',
                          'Verdana': 'Verdana',
                          'Tahoma': 'Tahoma',
                          'Courier': 'Courier',
                          'Standard': 'Clear',
                        },
                      ),
                    ),
                    showFontFamily: true,
                    showFontSize: true,
                    showBoldButton: true,
                    showItalicButton: true,
                    showUnderLineButton: true,
                    showStrikeThrough: true,
                    showInlineCode: false,
                    showColorButton: true,
                    showBackgroundColorButton: true,
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
                    showIndent: true,
                    showLink: true,
                    showUndo: true,
                    showRedo: true,
                    showDirection: false,
                    showSearchButton: false,
                    showSubscript: false,
                    showSuperscript: false,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: ref.watch(aiCorrectionProvider).isCorrecting
                    ? null
                    : _runAiCorrection,
                icon: ref.watch(aiCorrectionProvider).isCorrecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_fix_high),
                label: Text('KI Korrektur'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Google Docs Style Canvas
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vertical Ruler
                      Padding(
                        padding: EdgeInsets.only(
                          top: 24,
                        ), // Offset for the horizontal ruler height
                        child: EditorRuler(
                          isHorizontal: false,
                          length: 1123,
                          offset: 170,
                        ),
                      ),
                      Column(
                        children: [
                          // Horizontal Ruler
                          EditorRuler(
                            isHorizontal: true,
                            length: 794,
                            offset: 94,
                          ),
                          Container(
                            width: 794, // A4 width at 96 DPI
                            constraints: BoxConstraints(
                              minHeight: 1123, // A4 height at 96 DPI
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            // DIN 5008 Margins: Top: 45mm/27mm, Bottom: 20mm, Left: 25mm, Right: 20mm
                            // 1mm ~= 3.78 pixels
                            padding: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildProfessionalHeader(),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: 94, // 25mm
                                        right: 75, // 20mm
                                        top: _currentDesignId != 'monogram' ? 170 : 40,
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
                                          focusNode: _editorFocusNode,
                                          controller: _controller,
                                          config: quill.QuillEditorConfig(
                                            customStyles: quill.DefaultStyles(
                                              paragraph: quill.DefaultTextBlockStyle(
                                                TextStyle(
                                                  fontFamily: _currentFontFamily,
                                                  fontSize: _currentFontSize,
                                                  color: Colors.black,
                                                  height: _currentLineHeight,
                                                ),
                                                quill.HorizontalSpacing(0, 0),
                                                quill.VerticalSpacing(0, 0),
                                                quill.VerticalSpacing(0, 0),
                                                null,
                                              ),
                                            ),
                                            placeholder:
                                                'Schreibe hier dein Anschreiben...',
                                            padding: EdgeInsets.zero,
                                            embedBuilders:
                                                FlutterQuillEmbeds.editorBuilders(),
                                            autoFocus: true,
                                            expands: false,
                                            scrollable: false, // Let the SingleChildScrollView handle scrolling!
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  _buildProfessionalFooter(),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Live Job-Fit (ATS)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text(
                  'Rechtschreibung (Offline)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                if (_isSpellChecking)
                  Center(child: CircularProgressIndicator(strokeWidth: 2))
                else if (_grammarWarnings.isEmpty)
                  Text(
                    'Keine Fehler gefunden.',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  )
                else
                  ..._grammarWarnings.map(
                    (w) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      title: Text(
                        w['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.wavy,
                          decorationColor: Colors.red,
                        ),
                      ),
                      subtitle: Text(
                        w['subtitle'] as String,
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (c) => FutureBuilder<List<String>>(
                            future: SpellChecker.getSuggestions(
                              w['title'] as String,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 16),
                                      Text('Suche Vorschl\u00e4ge...'),
                                    ],
                                  ),
                                );
                              }

                              final suggestions = snapshot.data ?? [];
                              return AlertDialog(
                                title: Text(
                                  'Korrektur f\u00fcr "${w['title']}"',
                                ),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      if (suggestions.isEmpty)
                                        Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Keine passenden W\u00f6rter gefunden.',
                                          ),
                                        )
                                      else
                                        ...suggestions.map(
                                          (s) => ListTile(
                                            title: Text(s),
                                            trailing: Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                            ),
                                            onTap: () {
                                              try {
                                                _controller.replaceText(
                                                  w['offset'] as int,
                                                  w['length'] as int,
                                                  s,
                                                  null,
                                                );
                                                final plainText = _controller
                                                    .document
                                                    .toPlainText();
                                                SpellChecker.checkText(
                                                  plainText,
                                                ).then((issues) {
                                                  if (mounted)
                                                    setState(() {
                                                      _grammarWarnings = issues;
                                                    });
                                                });
                                              } catch (e) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Korrektur fehlgeschlagen.',
                                                        ),
                                                      ),
                                                    );
                                              }
                                              Navigator.pop(
                                                context,
                                              ); // close dialog
                                            },
                                          ),
                                        ),
                                      Divider(),
                                      ListTile(
                                        leading: Icon(
                                          Icons.visibility_off,
                                        ),
                                        title: Text('Wort ignorieren'),
                                        onTap: () {
                                          SpellChecker.ignoreWord(
                                            w['title'] as String,
                                          );
                                          final plainText = _controller.document
                                              .toPlainText();
                                          SpellChecker.checkText(plainText)
                                              .then((issues) {
                                                if (mounted)
                                                  setState(() {
                                                    _grammarWarnings = issues;
                                                  });
                                              });
                                          Navigator.pop(
                                            context,
                                          ); // close dialog
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Abbrechen'),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                      trailing: Icon(Icons.chevron_right, size: 16),
                    ),
                  ),
                Divider(height: 32),
                Text(
                  'Keywords (Stellenanzeige)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                if (_application?.jobDescriptionText == null ||
                    _application!.jobDescriptionText!.isEmpty)
                  ElevatedButton.icon(
                    icon: Icon(Icons.paste),
                    label: Text('Anzeige einfügen'),
                    onPressed: _pasteJobDescription,
                  )
                else ...[
                  if (_foundKeywords.isEmpty && _missingKeywords.isEmpty)
                    Text(
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pasteJobDescription() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Stellenanzeige einfügen'),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: ctrl,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Füge hier den Text der Stellenanzeige ein...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                final db = ref.read(databaseProvider);
                await db.applicationsDao.updateApplication(
                  ApplicationsCompanion(
                    id: drift.Value(widget.applicationId!),
                    jobDescriptionText: drift.Value(ctrl.text.trim()),
                  ),
                );
                final updatedApp = await db.applicationsDao.getApplicationById(
                  widget.applicationId!,
                );
                setState(() {
                  _application = updatedApp;
                });
                _runAtsAnalysis();
              }
              if (context.mounted) Navigator.pop(ctx);
            },
            child: Text('Speichern & Analysieren'),
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
      padding: EdgeInsets.only(bottom: 4.0),
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
