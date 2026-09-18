import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' as shared_prefs;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/application_entity.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';


import 'dart:convert';
import 'dart:async';

import '../../../../domain/entities/template_entity.dart';
import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/editor_provider.dart';
import '../../../core/utils/keyword_extractor.dart';
import '../../../core/utils/spell_checker.dart';
import '../../../core/utils/font_scanner.dart';
import 'editor_ruler.dart';
import '../../providers/ai_correction_provider.dart';
import '../../providers/document_template_provider.dart';
import '../../../core/themes/designs/document_design.dart';
import '../../../core/themes/designs/monogram_design.dart';
import 'widgets/cv_work_experience_dialog.dart';
import 'widgets/cv_education_dialog.dart';
import 'widgets/cv_skill_dialog.dart';
import 'widgets/cv_language_dialog.dart';
import 'widgets/cv_custom_item_dialog.dart';
import '../../providers/cv_provider.dart';
import '../../../core/themes/designs/modern_sidebar_design.dart';
import '../../../../data/database/app_database.dart';

import 'widgets/cv_work_experience_dialog.dart';
import 'widgets/cv_education_dialog.dart';
import 'widgets/cv_skill_dialog.dart';
import 'widgets/cv_language_dialog.dart';
import 'widgets/cv_custom_item_dialog.dart';
import '../../providers/cv_provider.dart';
import '../../../core/themes/designs/modern_sidebar_design.dart';

import '../../../core/themes/designs/classic_design.dart';

class ApplicationEditorScreen extends ConsumerStatefulWidget {
  final int? applicationId;
  final TemplateEntity? template;
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
  ApplicationEntity? _application;
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
  final TextEditingController _headerCompanyNameCtrl = TextEditingController(
    text: 'Unternehmensname',
  );
  final TextEditingController _headerContactNameCtrl = TextEditingController(
    text: 'Personalabteilung',
  );
  final TextEditingController _headerCompanyAddressCtrl = TextEditingController(
    text: 'Adresse',
  );
  final TextEditingController _headerDateCtrl = TextEditingController(
    text: 'Datum',
  );

  final TextEditingController _headerUserEmailCtrl = TextEditingController(
    text: 'email',
  );
  final TextEditingController _headerUserPhoneCtrl = TextEditingController(
    text: 'telefon',
  );
  final TextEditingController _headerUserAddressCtrl = TextEditingController(
    text: 'adresse',
  );

  final TextEditingController _headerUserNameCtrl = TextEditingController(
    text: 'Name',
  );
  final TextEditingController _headerUserProfessionCtrl = TextEditingController(
    text: 'Beruf',
  );

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
  Color _currentTextColor = Colors.black87;

  List<String> _missingKeywords = [];
  List<String> _foundKeywords = [];

  bool _showLeftSidebar = true;
  bool _showRightSidebar = true;
  bool _isCvMode = false;

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
    if (lang == 'en') {
      subjectPrefix = 'ApplicationEntity for ';
    } else if (lang == 'fr') {
      subjectPrefix = 'Candidature pour le poste de ';
    } else if (lang == 'es') {
      subjectPrefix = 'Candidatura para el puesto de ';
    }

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

  Future<void> _insertFooter() async {
    final len = _controller.document.length;
    _controller.document.insert(len - 1, "\n\nMit freundlichen Grüßen\n\n");
    
    // Load signature
    final prefs = await shared_prefs.SharedPreferences.getInstance();
    final signatureBase64 = prefs.getString('user_signature');
    if (signatureBase64 != null) {
      _controller.document.insert(_controller.document.length - 1, "\n");
      _controller.document.insert(_controller.document.length - 1, quill.BlockEmbed.image("data:image/png;base64,$signatureBase64"));
      _controller.document.insert(_controller.document.length - 1, "\n\n");
    } else {
      _controller.document.insert(_controller.document.length - 1, "\n\n");
    }

    // Name
    final name = 'Max Mustermann';
    _controller.document.insert(_controller.document.length - 1, "$name\n\nAnlagen");
  }

  // CV State
  String? _cvProfileImagePath;

  Future<void> _pickProfileImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: ['jpg', 'png', 'jpeg'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      setState(() => _cvProfileImagePath = file.path);
    }
  }

  final _cvNameCtrl = TextEditingController(text: 'Michael Kurz');
  final _cvTitleCtrl = TextEditingController(
    text: 'Fachinformatiker für Systemintegration',
  );
  final _cvIntroCtrl = TextEditingController(
    text: 'Lösungsorientierter Fachinformatiker...',
  );
  final _cvEmailCtrl = TextEditingController(text: 'bewerbung.kurz@gmail.com');
  final _cvPhoneCtrl = TextEditingController(text: '0157 / 3 7879 672');
  final _cvAddressCtrl = TextEditingController(
    text: 'Breyeller Str. 114, 41334 Nettetal',
  );
  final _cvBirthplaceCtrl = TextEditingController(text: 'Berlin / Zehlendorf');
  final _cvBirthdateCtrl = TextEditingController(text: '06.12.1984');
  final _cvMaritalStatusCtrl = TextEditingController(text: 'Ledig');




  @override
  void initState() {
    super.initState();
    _loadApplication();
    FontScanner.loadSystemFonts().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadApplication() async {
    
    final langSetting = await ref.read(settingsRepositoryProvider).getSettingByKey(
      'spellCheckLanguage',
    );
    SpellChecker.loadDictionary(language: langSetting?.value ?? 'de');

    final nameSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('userName');
    final emailSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('userEmail');
    final phoneSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('userPhone');
    final addressSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('userAddress');
    final zipSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('userZip');
    final citySetting = await ref.read(settingsRepositoryProvider).getSettingByKey('userCity');

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
        _headerUserAddressCtrl.text = '$_userAddress\n$_userZip $_userCity';

        _headerDateCtrl.text =
            "${_userCity.isNotEmpty ? _userCity : 'Stadt'}, den ${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}";
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
      if (widget.template!.content.isNotEmpty) {
        try {
          final decoded = jsonDecode(widget.template!.content);
          document = quill.Document.fromJson(decoded);
        } catch (e) {
          document = quill.Document()..insert(0, widget.template!.content);
        }
      }
    } else if (widget.applicationId != null) {
      final app = await ref.read(applicationsRepositoryProvider).getApplicationById(
        widget.applicationId!,
      );

      if (app != null) {
        _application = app;
        _headerCompanyNameCtrl.text = app.company;
        _headerContactNameCtrl.text = app.contactName ?? 'Personalabteilung';
        _headerCompanyAddressCtrl.text =
            app.address ?? 'Musterstraße 1, 12345 Stadt';
        if (app.coverLetterContent?.isNotEmpty == true) {
          try {
            final decoded = jsonDecode(app.coverLetterContent!);
            document = quill.Document.fromJson(decoded);
          } catch (e) {
            document = quill.Document()..insert(0, app.coverLetterContent!);
          }
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
    try {
      final content = jsonEncode(_controller.document.toDelta().toJson());

      if (widget.applicationId != null) {
        await ref.read(applicationNotifierProvider).updateCoverLetterContent(
          widget.applicationId!,
          content,
        );
      } else {
        // Save as TemplateEntity
        final name = _nameController.text.trim().isEmpty
            ? 'Neues Dokument'
            : _nameController.text.trim();
        final type = widget.template?.type ?? widget.initialType ?? 'anschreiben';

        await ref.read(templateEditorProvider.notifier).saveTemplate(
          existingId: widget.template?.id,
          name: name,
          type: type,
          deltaJson: _controller.document.toDelta().toJson(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Als Vorlage gespeichert.')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _hasChanges = false;
          _isSaving = false;
        });
      }
    }
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
      backgroundColor:
          colorScheme.surfaceContainerHighest, // The 'Desk' background
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: widget.applicationId != null
                  ? Text('Anschreiben: ${_application?.company}')
                  : TextField(
                      controller: _nameController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Dokumentname (z.B. Lebenslauf)',
                        counterText: '',
                        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                    ),
            ),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Anschreiben'),
                  icon: Icon(Icons.edit_document),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Lebenslauf'),
                  icon: Icon(Icons.contact_page),
                ),
              ],
              selected: {_isCvMode},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isCvMode = newSelection.first;
                });
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showLeftSidebar
                  ? Icons.keyboard_double_arrow_left
                  : Icons.keyboard_double_arrow_right,
            ),
            tooltip: 'Linke Seitenleiste umschalten',
            onPressed: () =>
                setState(() => _showLeftSidebar = !_showLeftSidebar),
          ),
          IconButton(
            icon: Icon(
              _showRightSidebar
                  ? Icons.keyboard_double_arrow_right
                  : Icons.keyboard_double_arrow_left,
            ),
            tooltip: 'Rechte Seitenleiste umschalten',
            onPressed: () =>
                setState(() => _showRightSidebar = !_showRightSidebar),
          ),
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
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.save, size: 16),
                    label: const Text('Speichern'),
                    onPressed: () {
                      _save();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dokument gespeichert.')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF Export'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PDF Export folgt im nächsten Schritt!',
                          ),
                        ),
                      );
                    },
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
          if (_showLeftSidebar)
            Expanded(
              flex: 2,
              child: _isCvMode
                  ? _buildCvLeftSidebar(colorScheme)
                  : _buildLeftSidebar(colorScheme),
            ),

          // MIDDLE COLUMN: Editor
          Expanded(
            flex: 6,
            child: _isCvMode
                ? _buildCvArea(colorScheme)
                : _buildEditorArea(colorScheme),
          ),

          // RIGHT COLUMN: ATS Scanner & Analysis
          if (_showRightSidebar && !_isCvMode)
            Expanded(flex: 2, child: _buildRightSidebar(colorScheme)),
        ],
      ),
    );
  }


  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null) return '';
    final startStr = '${start.month.toString().padLeft(2, '0')}/${start.year}';
    if (end == null) return '$startStr - Heute';
    final endStr = '${end.month.toString().padLeft(2, '0')}/${end.year}';
    return '$startStr - $endStr';
  }

  DocumentDesign _getDesign() {
    switch (_currentDesignId) {
      case 'klassisch':
      case 'kompakt':
        return const ClassicDesign();
      case 'modern':
        return const ModernSidebarDesign();
      case 'monogram':
      default:
        return const MonogramDesign();
    }
  }

  Widget _buildCvArea(ColorScheme colorScheme) {
    DocumentDesign design = _getDesign();
    final cvAsync = ref.watch(cvProvider(widget.applicationId));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: cvAsync.when(
                data: (cvState) => Container(
                  width: 794,
                  constraints: const BoxConstraints(minHeight: 1123),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: design.buildCurriculumVitae(
                    context,
                    _currentAccentColor,
                    CvData(
                      initials: _cvNameCtrl.text.split(' ').where((e) => e.isNotEmpty).map((e) => e[0].toUpperCase()).take(2).join(''),
                      name: _cvNameCtrl.text,
                      title: _cvTitleCtrl.text,
                      textColor: _currentTextColor,
                      introText: _cvIntroCtrl.text,
                      email: _cvEmailCtrl.text,
                      phone: _cvPhoneCtrl.text,
                      address: _cvAddressCtrl.text,
                      birthplace: _cvBirthplaceCtrl.text,
                      birthdate: _cvBirthdateCtrl.text,
                      maritalStatus: _cvMaritalStatusCtrl.text,
                      profileImagePath: _cvProfileImagePath,
                      experiences: cvState.experiences.map((e) => CvTimelineItem(
                        dateRange: _formatDateRange(e.startDate, e.endDate),
                        title: e.position,
                        subtitle: e.company,
                        description: e.description ?? '',
                      )).toList(),
                      educations: cvState.educations.map((e) => CvTimelineItem(
                        dateRange: _formatDateRange(e.startDate, e.endDate),
                        title: e.degree,
                        subtitle: e.institution,
                        description: e.description ?? '',
                      )).toList(),
                      skills: cvState.skills,
                      languages: cvState.languages,
                      customItems: cvState.customItems,
                      pageMargins: EdgeInsets.only(left: _marginLeft, top: _marginTop, right: _marginRight, bottom: _marginBottom),
                    ),
                  ),
                ),
                loading: () => const SizedBox(width: 794, height: 1123, child: Center(child: CircularProgressIndicator())),
                error: (e, s) => SizedBox(width: 794, height: 1123, child: Center(child: Text('Fehler: $e'))),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCvLeftSidebar(ColorScheme colorScheme) {
    final cvAsync = ref.watch(cvProvider(widget.applicationId));
    
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
                  Tab(icon: Icon(Icons.list_alt), text: 'Daten'),
                  Tab(icon: Icon(Icons.format_paint), text: 'Design'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  cvAsync.when(
                    data: (cvState) => ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildCvFormGroup('Persönliche Daten', Icons.person, [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            title: const Text('Bewerbungsfoto', style: TextStyle(fontSize: 12)),
                            subtitle: Text(_cvProfileImagePath != null ? 'Foto ausgewählt' : 'Kein Foto', style: const TextStyle(fontSize: 10)),
                            trailing: TextButton(onPressed: _pickProfileImage, child: const Text('Auswählen', style: TextStyle(fontSize: 12))),
                          ),
                          const Divider(height: 1),
                          _buildSidebarTextField('Name', _cvNameCtrl),
                          _buildSidebarTextField('Berufsbezeichnung', _cvTitleCtrl),
                          _buildSidebarTextField('Intro-Text', _cvIntroCtrl, maxLines: 3),
                          _buildSidebarTextField('E-Mail', _cvEmailCtrl, keyboardType: TextInputType.emailAddress),
                          _buildSidebarTextField('Telefon', _cvPhoneCtrl, keyboardType: TextInputType.phone),
                          _buildSidebarTextField('Anschrift', _cvAddressCtrl),
                          _buildSidebarTextField('Geburtsort', _cvBirthplaceCtrl),
                          _buildSidebarTextField('Geburtsdatum', _cvBirthdateCtrl, keyboardType: TextInputType.datetime),
                          _buildSidebarTextField('Familienstand', _cvMaritalStatusCtrl),
                        ]),
                        _buildCvFormGroup('Berufserfahrung', Icons.work, [
                          ...cvState.experiences.map((exp) => ListTile(
                            title: Text(exp.position, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text('${_formatDateRange(exp.startDate, exp.endDate)} | ${exp.company}', style: const TextStyle(fontSize: 10)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () async { 
                                  final result = await showDialog(context: context, builder: (_) => CvWorkExperienceDialog(initialData: {'company': exp.company, 'position': exp.position, 'startDate': exp.startDate, 'endDate': exp.endDate, 'isCurrent': exp.isCurrent, 'description': exp.description}));
                                  if (result != null) {
                                    ref.read(cvNotifierProvider).updateWorkExperience(widget.applicationId, CvWorkExperience(id: exp.id, applicationId: exp.applicationId, company: result['company'], position: result['position'], startDate: result['startDate'], endDate: result['endDate'], isCurrent: result['isCurrent'], description: result['description']));
                                  }
                                }),
                                IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () { ref.read(cvNotifierProvider).deleteWorkExperience(widget.applicationId, exp.id); }),
                              ],
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FilledButton.icon(onPressed: () async { 
                              final result = await showDialog(context: context, builder: (_) => const CvWorkExperienceDialog());
                              if (result != null) {
                                ref.read(cvNotifierProvider).addWorkExperience(widget.applicationId, result['company'], result['position'], result['startDate'], result['endDate'], result['isCurrent'], result['description']);
                              }
                            }, icon: const Icon(Icons.add), label: const Text('Neue Station hinzufügen')),
                          ),
                        ]),
                        _buildCvFormGroup('Ausbildung', Icons.school, [
                          ...cvState.educations.map((edu) => ListTile(
                            title: Text(edu.degree, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text('${_formatDateRange(edu.startDate, edu.endDate)} | ${edu.institution}', style: const TextStyle(fontSize: 10)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () async { 
                                  final result = await showDialog(context: context, builder: (_) => CvEducationDialog(initialData: {'institution': edu.institution, 'degree': edu.degree, 'startDate': edu.startDate, 'endDate': edu.endDate, 'description': edu.description}));
                                  if (result != null) {
                                    ref.read(cvNotifierProvider).updateEducation(widget.applicationId, CvEducation(id: edu.id, applicationId: edu.applicationId, institution: result['institution'], degree: result['degree'], startDate: result['startDate'], endDate: result['endDate'], description: result['description']));
                                  }
                                }),
                                IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () { ref.read(cvNotifierProvider).deleteEducation(widget.applicationId, edu.id); }),
                              ],
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FilledButton.icon(onPressed: () async { 
                              final result = await showDialog(context: context, builder: (_) => const CvEducationDialog());
                              if (result != null) {
                                ref.read(cvNotifierProvider).addEducation(widget.applicationId, result['institution'], result['degree'], result['startDate'], result['endDate'], result['description']);
                              }
                            }, icon: const Icon(Icons.add), label: const Text('Ausbildung hinzufügen')),
                          ),
                        ]),
                        _buildCvFormGroup('Fähigkeiten', Icons.star, [
                          ...cvState.skills.map((skill) => ListTile(
                            title: Text(skill.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text('Level: ${skill.level}/5', style: const TextStyle(fontSize: 10)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () async { 
                                  final result = await showDialog(context: context, builder: (_) => CvSkillDialog(initialData: {'name': skill.name, 'level': skill.level}));
                                  if (result != null) {
                                    ref.read(cvNotifierProvider).updateSkill(widget.applicationId, CvSkill(id: skill.id, applicationId: skill.applicationId, name: result['name'], level: result['level']));
                                  }
                                }),
                                IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () { ref.read(cvNotifierProvider).deleteSkill(widget.applicationId, skill.id); }),
                              ],
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FilledButton.icon(onPressed: () async { 
                              final result = await showDialog(context: context, builder: (_) => const CvSkillDialog());
                              if (result != null) {
                                ref.read(cvNotifierProvider).addSkill(widget.applicationId, result['name'], result['level']);
                              }
                            }, icon: const Icon(Icons.add), label: const Text('Skill hinzufügen')),
                          ),
                        ]),
                        _buildCvFormGroup('Sprachen', Icons.language, [
                          ...cvState.languages.map((lang) => ListTile(
                            title: Text(lang.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text(lang.level, style: const TextStyle(fontSize: 10)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () async { 
                                  final result = await showDialog(context: context, builder: (_) => CvLanguageDialog(initialData: {'name': lang.name, 'level': lang.level}));
                                  if (result != null) {
                                    ref.read(cvNotifierProvider).updateLanguage(widget.applicationId, CvLanguage(id: lang.id, applicationId: lang.applicationId, name: result['name'], level: result['level']));
                                  }
                                }),
                                IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () { ref.read(cvNotifierProvider).deleteLanguage(widget.applicationId, lang.id); }),
                              ],
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FilledButton.icon(onPressed: () async { 
                              final result = await showDialog(context: context, builder: (_) => const CvLanguageDialog());
                              if (result != null) {
                                ref.read(cvNotifierProvider).addLanguage(widget.applicationId, result['name'], result['level']);
                              }
                            }, icon: const Icon(Icons.add), label: const Text('Sprache hinzufügen')),
                          ),
                        ]),
                        _buildCvFormGroup('Eigener Abschnitt', Icons.category, [
                          ...cvState.customItems.map((item) => ListTile(
                            title: Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text('${item.sectionName}${item.subtitle != null && item.subtitle!.isNotEmpty ? " | " + item.subtitle! : ""}', style: const TextStyle(fontSize: 10)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 16), onPressed: () async { 
                                  final result = await showDialog(context: context, builder: (_) => CvCustomItemDialog(initialData: {'sectionName': item.sectionName, 'title': item.title, 'subtitle': item.subtitle, 'dateRange': item.dateRange, 'description': item.description}));
                                  if (result != null) {
                                    ref.read(cvNotifierProvider).updateCustomItem(widget.applicationId, item.id, result['sectionName'], result['title'], result['subtitle'], result['dateRange'], result['description'], item.sortOrder);
                                  }
                                }),
                                IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () { ref.read(cvNotifierProvider).deleteCustomItem(widget.applicationId, item.id); }),
                              ],
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FilledButton.icon(onPressed: () async { 
                              final result = await showDialog(context: context, builder: (_) => const CvCustomItemDialog());
                              if (result != null) {
                                ref.read(cvNotifierProvider).addCustomItem(widget.applicationId, result['sectionName'], result['title'], result['subtitle'], result['dateRange'], result['description'], 0);
                              }
                            }, icon: const Icon(Icons.add), label: const Text('Abschnitt hinzufügen')),
                          ),
                        ]),
                      ],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Fehler: $e')),
                  ),
                  _buildDesignTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: (value) => setState(() {}),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCvFormGroup(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        children: children,
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
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
        _buildDesignCard(
          'Klassisch',
          'Serife Schrift, seriös & zeitlos',
          'klassisch',
        ),
        _buildDesignCard('Modern', 'Klare Kanten, serifenlos', 'modern'),
        _buildDesignCard('Kompakt', 'Für viel Text auf einer Seite', 'kompakt'),
        _buildDesignCard(
          'Monogram',
          'Professionelles Layout mit blauem Monogramm',
          'monogram',
        ),

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
        if (!_isCvMode) ...[
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
        ],
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
    return Semantics(
      button: true,
      label: 'Farbe auswählen: 0x${color.toARGB32().toRadixString(16)}',
      child: InkWell(
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
                : Colors.grey.withValues(alpha: 0.5),
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    ));
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

  Widget _buildDesignCard(String title, String subtitle, String designId) {
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
    
    return StreamBuilder<List<TemplateEntity>>(
      stream: ref.read(templatesRepositoryProvider).watchTemplatesByType('textbaustein'),
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
                        {'name': 'Standard-Einleitung', 'type': 'textbaustein', 'content': '[{"insert":"Sehr geehrte Damen und Herren,\\n\\nmit großem Interesse habe ich Ihre Stellenanzeige gelesen und bewerbe mich hiermit um die ausgeschriebene Position.\\n"}]'},
                        {'name': 'Einleitung Dynamisch', 'type': 'textbaustein', 'content': '[{"insert":"Sehr geehrte Damen und Herren,\\n\\nIhre Unternehmenswerte haben mich sofort begeistert, weshalb ich mich freue, mich Ihnen als engagierter Kandidat vorzustellen.\\n"}]'},
                        {'name': 'Gehaltsvorstellung', 'type': 'textbaustein', 'content': '[{"insert":"Meine Gehaltsvorstellungen liegen bei einem Bruttojahresgehalt von 55.000 Euro. Ein Einstieg ist ab dem 01.12. möglich.\\n"}]'},
                        {'name': 'Teamfähigkeit', 'type': 'textbaustein', 'content': '[{"insert":"In meinen bisherigen Projekten konnte ich stets durch eine starke Teamfähigkeit und lösungsorientierte Arbeitsweise überzeugen.\\n"}]'},
                        {'name': 'Call to Action', 'type': 'textbaustein', 'content': '[{"insert":"Ich freue mich sehr auf die Gelegenheit, Sie in einem persönlichen Gespräch von meiner Eignung zu überzeugen.\\n\\nMit freundlichen Grüßen\\n"}]'},
                      ];
                      for (final t in samples) {
                        await ref.read(templatesRepositoryProvider).addTemplate( t['name']!,
                          t['type']!,
                          t['content']!,
                        );
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

  Widget _buildDraggableBlock(TemplateEntity template) {
    // Generate a short preview of the text
    String preview = '...';
    try {
      if (template.content.isNotEmpty) {
        final List<dynamic> ops = jsonDecode(template.content);
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
          if (template.content.isNotEmpty) {
            try {
              final ops = jsonDecode(template.content);
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

  Widget _buildEditableText(
    TextEditingController controller,
    double fontSize, {
    FontWeight? fontWeight,
    int? maxLines = 1,
    Color color = Colors.black87,
    TextAlign textAlign = TextAlign.left,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
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
    DocumentDesign design = _getDesign();
    
    return design.buildCoverLetterHeader(
      context, 
      CoverLetterDesignContext(
        accentColor: _currentAccentColor,
        textColor: _currentTextColor,
        companyNameCtrl: _headerCompanyNameCtrl,
        contactNameCtrl: _headerContactNameCtrl,
        companyAddressCtrl: _headerCompanyAddressCtrl,
        dateCtrl: _headerDateCtrl,
        userNameCtrl: _headerUserNameCtrl,
        userProfessionCtrl: _headerUserProfessionCtrl,
        userEmailCtrl: _headerUserEmailCtrl,
        userPhoneCtrl: _headerUserPhoneCtrl,
        userAddressCtrl: _headerUserAddressCtrl,
      )
    );
  }

  Widget _buildProfessionalFooter() {
    if (_currentDesignId != 'monogram') return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _currentAccentColor, width: 3)),
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
                        items: FontScanner.getEditorFontMap(),
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
                onPressed: ref.watch(aiCorrectionProvider.select((s) => s.isCorrecting))
                    ? null
                    : _runAiCorrection,
                icon: ref.watch(aiCorrectionProvider.select((s) => s.isCorrecting))
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
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
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
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            // DIN 5008 Margins: Top: 45mm/27mm, Bottom: 20mm, Left: 25mm, Right: 20mm
                            // 1mm ~= 3.78 pixels
                            padding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: _marginLeft, right: _marginRight, top: _marginTop, bottom: _marginBottom),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        _buildProfessionalHeader(),
                                        DefaultTextStyle(
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
                                              paragraph:
                                                  quill.DefaultTextBlockStyle(
                                                    TextStyle(
                                                      fontFamily:
                                                          _currentFontFamily,
                                                      fontSize:
                                                          _currentFontSize,
                                                      color: Colors.black,
                                                      height:
                                                          _currentLineHeight,
                                                    ),
                                                    quill.HorizontalSpacing(
                                                      0,
                                                      0,
                                                    ),
                                                    quill.VerticalSpacing(0, 0),
                                                    quill.VerticalSpacing(0, 0),
                                                    null,
                                                  ),
                                            ),
                                            placeholder: 'Schreibe hier dein Anschreiben...',
                                            padding: EdgeInsets.zero,
                                            embedBuilders:
                                                FlutterQuillEmbeds.editorBuilders(),
                                            autoFocus: true,
                                            expands: false,
                                            scrollable: false, // Let the SingleChildScrollView handle scrolling!
                                          ),
                                        ),
                                      ),
                                        const SizedBox(
                                          height: 60,
                                        ), // Space so text doesn't hit the footer
                                      ],
                                    ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: _buildProfessionalFooter(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ],
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
                      leading: Icon(Icons.error_outline, color: Colors.red),
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
                                                  if (mounted) {
                                                    setState(() {
                                                      _grammarWarnings = issues;
                                                    });
                                                  }
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
                                        leading: Icon(Icons.visibility_off),
                                        title: Text('Wort ignorieren'),
                                        onTap: () {
                                          SpellChecker.ignoreWord(
                                            w['title'] as String,
                                          );
                                          final plainText = _controller.document
                                              .toPlainText();
                                          SpellChecker.checkText(plainText)
                                              .then((issues) {
                                                if (mounted) {
                                                  setState(() {
                                                    _grammarWarnings = issues;
                                                  });
                                                }
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
                await ref.read(applicationNotifierProvider).updateJobDescription(
                  widget.applicationId!,
                  ctrl.text.trim(),
                );
                final repo = ref.read(applicationsRepositoryProvider);
                final updatedApp = await repo.getApplicationById(
                  widget.applicationId!,
                );
                setState(() {
                  _application = updatedApp;
                });
                _runAtsAnalysis();
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: Text('Speichern & Analysieren'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordChip(BuildContext context, String keyword, bool found) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = found
        ? Colors.green
        : colorScheme.onSurface.withValues(alpha: 0.5);
    final textColor = found
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.5);

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
