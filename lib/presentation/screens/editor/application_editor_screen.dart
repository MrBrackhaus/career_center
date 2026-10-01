import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart' as shared_prefs;
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../domain/entities/application_entity.dart';
import '../../../domain/entities/setting_entity.dart';
import '../../../domain/entities/template_entity.dart';
import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/editor_provider.dart';
import '../../providers/ai_correction_provider.dart';
import '../../providers/document_template_provider.dart';
import '../../providers/cv_provider.dart';
import '../../../core/utils/keyword_extractor.dart';
import '../../../core/utils/spell_checker.dart';
import '../../../core/utils/font_scanner.dart';
import '../../../core/utils/pdf_cv_generator.dart';
import '../../../core/themes/designs/document_design.dart';
import '../../../core/themes/designs/monogram_design.dart';
import '../../../core/themes/designs/modern_sidebar_design.dart';
import '../../../core/themes/designs/classic_design.dart';
import 'editor_ruler.dart';
import 'widgets/cv_work_experience_dialog.dart';
import 'widgets/cv_education_dialog.dart';
import 'widgets/cv_skill_dialog.dart';
import 'widgets/cv_language_dialog.dart';
import 'widgets/cv_custom_item_dialog.dart';

/// Settings-Schlüssel für das Lebenslauf-Profil im Master-/Vorlagenmodus.
const String _kCvProfileMasterKey = 'cvProfileMaster';

/// Settings-Schlüssel für Briefkopf-Felder einer Vorlage (ohne Bewerbung).
String _letterHeaderTemplateKey(int templateId) =>
    'letterHeaderTemplate_$templateId';

/// Momentaufnahme des zu speichernden Zustands, synchron erfasst, damit ein
/// Speichervorgang auch nach dem Schließen des Editors noch korrekt läuft.
class _SaveSnapshot {
  final int revision;
  final String deltaJsonString;
  final List<dynamic> deltaJson;
  final Map<String, String> cvProfile;
  final Map<String, String> letterHeader;
  final String name;
  final String type;

  const _SaveSnapshot({
    required this.revision,
    required this.deltaJsonString,
    required this.deltaJson,
    required this.cvProfile,
    required this.letterHeader,
    required this.name,
    required this.type,
  });
}

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
  bool _controllerCreated = false;
  StreamSubscription<quill.DocChange>? _docChangesSub;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _disposed = false;
  Timer? _autoSaveTimer;
  ApplicationEntity? _application;
  final FocusNode _editorFocusNode = FocusNode();
  final _nameController = TextEditingController();

  // Speicher-Status: Jede echte Änderung erhöht [_revision]; nach einem
  // erfolgreichen Speichern wird [_savedRevision] auf den Stand zum
  // Speicherbeginn gesetzt. Änderungen während des Speicherns bleiben so
  // "ungespeichert" und werden beim nächsten Autosave mitgenommen.
  int _revision = 0;
  int _savedRevision = 0;
  /// Zählt nur Änderungen am Quill-Dokument (für KI-Korrektur).
  int _docRevision = 0;
  bool get _hasChanges => _revision != _savedRevision;
  Future<bool> _saveChain = Future.value(true);

  /// ID der Vorlage im Vorlagenmodus; nach dem ersten Insert gesetzt.
  int? _templateId;

  /// Bisheriger Inhalt von `applications.cvContent` (andere Schlüssel bleiben
  /// beim Speichern erhalten).
  Map<String, dynamic> _cvContentMap = {};
  String _lastPersonalSnapshot = '';

  /// Zuletzt gespeicherter (bzw. geladener) Stand von Profil und Briefkopf –
  /// unveränderte Werte werden nicht erneut geschrieben, damit spätere
  /// Änderungen in den Einstellungen weiterhin als Vorbelegung greifen.
  String _persistedCvProfileJson = '';
  String _persistedLetterHeaderJson = '';

  // Vor dem Laden erfasste Abhängigkeiten – auch nach dispose nutzbar.
  late final ApplicationNotifier _applicationNotifier;
  late final TemplateEditorNotifier _templateEditorNotifier;
  late final SettingsRepository _settingsRepository;
  late final Stream<List<TemplateEntity>> _textbausteinStream;
  final Map<String, String> _blockPreviewCache = {};

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
  bool _isExportingPdf = false;
  List<Map<String, dynamic>> _grammarWarnings = [];

  // Design / Typography State
  String _currentFontFamily = 'Segoe UI';
  double _currentFontSize = 14;
  double _currentLineHeight = 1.5;
  Color _currentAccentColor = Colors.blue[900]!;
  final Color _currentTextColor = Colors.black87;

  List<String> _missingKeywords = [];
  List<String> _foundKeywords = [];

  bool _showLeftSidebar = true;
  bool _showRightSidebar = true;
  bool _isCvMode = false;

  void _safeSetState(VoidCallback fn) {
    if (mounted && !_disposed) setState(fn);
  }

  void _showSnack(String message) {
    if (!mounted || _disposed) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _runAiCorrection() async {
    final text = _controller.document.toPlainText();
    if (text.trim().isEmpty) return;

    // Stand zum Zeitpunkt der Anfrage merken: Tippt der Nutzer währenddessen
    // weiter, darf die Antwort seine Änderungen nicht überschreiben.
    final revisionAtRequest = _docRevision;
    final lang = SpellChecker.currentLanguage;
    final correctedText = await ref
        .read(aiCorrectionProvider.notifier)
        .correctText(text, lang);

    if (!mounted || _disposed) return;
    if (correctedText == null || correctedText.isEmpty) return;

    if (_docRevision != revisionAtRequest ||
        _controller.document.toPlainText() != text) {
      _showSnack(
        'Das Dokument wurde während der KI-Korrektur geändert – '
        'Korrektur wurde nicht übernommen. Bitte erneut ausführen.',
      );
      return;
    }

    final length = _controller.document.length;
    _controller.replaceText(
      0,
      length - 1,
      correctedText,
      const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _insertHeader() async {
    final lang = SpellChecker.currentLanguage;
    final templateService = ref.read(documentTemplateServiceProvider);
    final headerText = await templateService.generateHeader(_application, lang);
    if (!mounted || _disposed) return;

    _controller.replaceText(0, 0, headerText, null);

    String subjectPrefix = 'Bewerbung als ';
    if (lang == 'en') {
      subjectPrefix = 'Application for ';
    } else if (lang == 'fr') {
      subjectPrefix = 'Candidature pour le poste de ';
    } else if (lang == 'es') {
      subjectPrefix = 'Candidatura para el puesto de ';
    }

    final subjectStart = headerText.indexOf(subjectPrefix);
    final subjectEnd =
        subjectStart == -1 ? -1 : headerText.indexOf('\n', subjectStart);
    if (subjectStart != -1 && subjectEnd != -1) {
      _controller.formatText(
        subjectStart,
        subjectEnd - subjectStart,
        quill.Attribute.bold,
      );
    }
  }

  Future<void> _insertFooter() async {
    final prefs = await shared_prefs.SharedPreferences.getInstance();
    final signatureBase64 = prefs.getString('user_signature');
    if (!mounted || _disposed) return;

    // replaceText (statt document.insert) benachrichtigt Listener, damit
    // Autosave und Analyse greifen.
    void append(Object data) {
      _controller.replaceText(_controller.document.length - 1, 0, data, null);
    }

    append('\n\nMit freundlichen Grüßen\n\n');
    if (signatureBase64 != null) {
      append('\n');
      append(quill.BlockEmbed.image('data:image/png;base64,$signatureBase64'));
      append('\n\n');
    } else {
      append('\n\n');
    }

    final headerName = _headerUserNameCtrl.text.trim();
    final name = headerName.isNotEmpty ? headerName : _userName.trim();
    append(name.isNotEmpty ? '$name\n\nAnlagen' : 'Anlagen');
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
      _safeSetState(() => _cvProfileImagePath = file.path);
      _onPersonalFieldChanged();
    }
  }

  // Lebenslauf-Felder starten leer und werden aus dem Profil (Einstellungen) vorbelegt.
  final _cvNameCtrl = TextEditingController();
  final _cvTitleCtrl = TextEditingController();
  final _cvIntroCtrl = TextEditingController();
  final _cvEmailCtrl = TextEditingController();
  final _cvPhoneCtrl = TextEditingController();
  final _cvAddressCtrl = TextEditingController();
  final _cvBirthplaceCtrl = TextEditingController();
  final _cvBirthdateCtrl = TextEditingController();
  final _cvMaritalStatusCtrl = TextEditingController();

  /// Controller, deren Inhalt gespeichert wird (Dokumentname, Lebenslauf-
  /// Profil & Briefkopf).
  List<TextEditingController> get _persistedControllers => [
    _nameController,
    _cvNameCtrl,
    _cvTitleCtrl,
    _cvIntroCtrl,
    _cvEmailCtrl,
    _cvPhoneCtrl,
    _cvAddressCtrl,
    _cvBirthplaceCtrl,
    _cvBirthdateCtrl,
    _cvMaritalStatusCtrl,
    _headerCompanyNameCtrl,
    _headerContactNameCtrl,
    _headerCompanyAddressCtrl,
    _headerDateCtrl,
    _headerUserProfessionCtrl,
  ];

  List<TextEditingController> get _allTextControllers => [
    _nameController,
    _headerCompanyNameCtrl,
    _headerContactNameCtrl,
    _headerCompanyAddressCtrl,
    _headerDateCtrl,
    _headerUserEmailCtrl,
    _headerUserPhoneCtrl,
    _headerUserAddressCtrl,
    _headerUserNameCtrl,
    _headerUserProfessionCtrl,
    _cvNameCtrl,
    _cvTitleCtrl,
    _cvIntroCtrl,
    _cvEmailCtrl,
    _cvPhoneCtrl,
    _cvAddressCtrl,
    _cvBirthplaceCtrl,
    _cvBirthdateCtrl,
    _cvMaritalStatusCtrl,
  ];

  Map<String, String> _cvProfileData() => {
    'name': _cvNameCtrl.text,
    'title': _cvTitleCtrl.text,
    'intro': _cvIntroCtrl.text,
    'email': _cvEmailCtrl.text,
    'phone': _cvPhoneCtrl.text,
    'address': _cvAddressCtrl.text,
    'birthplace': _cvBirthplaceCtrl.text,
    'birthdate': _cvBirthdateCtrl.text,
    'maritalStatus': _cvMaritalStatusCtrl.text,
    'profileImagePath': _cvProfileImagePath ?? '',
  };

  Map<String, String> _letterHeaderData() => {
    'companyName': _headerCompanyNameCtrl.text,
    'contactName': _headerContactNameCtrl.text,
    'companyAddress': _headerCompanyAddressCtrl.text,
    'date': _headerDateCtrl.text,
    'userProfession': _headerUserProfessionCtrl.text,
  };

  String _personalSnapshot() => jsonEncode({
    'cv': _cvProfileData(),
    'header': _letterHeaderData(),
    'documentName': _nameController.text,
  });

  /// Listener für Profil-/Briefkopf-Felder: markiert nur bei echter
  /// Textänderung als geändert (Controller melden auch Cursorbewegungen).
  void _onPersonalFieldChanged() {
    if (_isLoading || _disposed) return;
    final snapshot = _personalSnapshot();
    if (snapshot == _lastPersonalSnapshot) return;
    _lastPersonalSnapshot = snapshot;
    _markDirty();
  }

  void _applyCvProfile(Map<String, dynamic> p) {
    String? v(String key) {
      final value = p[key];
      return value is String ? value : null;
    }

    _cvNameCtrl.text = v('name') ?? _cvNameCtrl.text;
    _cvTitleCtrl.text = v('title') ?? _cvTitleCtrl.text;
    _cvIntroCtrl.text = v('intro') ?? _cvIntroCtrl.text;
    _cvEmailCtrl.text = v('email') ?? _cvEmailCtrl.text;
    _cvPhoneCtrl.text = v('phone') ?? _cvPhoneCtrl.text;
    _cvAddressCtrl.text = v('address') ?? _cvAddressCtrl.text;
    _cvBirthplaceCtrl.text = v('birthplace') ?? _cvBirthplaceCtrl.text;
    _cvBirthdateCtrl.text = v('birthdate') ?? _cvBirthdateCtrl.text;
    _cvMaritalStatusCtrl.text = v('maritalStatus') ?? _cvMaritalStatusCtrl.text;
    final image = v('profileImagePath');
    if (image != null) {
      _cvProfileImagePath = image.isEmpty ? null : image;
    }
  }

  void _applyLetterHeader(Map<String, dynamic> h) {
    String? v(String key) {
      final value = h[key];
      return value is String ? value : null;
    }

    _headerCompanyNameCtrl.text = v('companyName') ?? _headerCompanyNameCtrl.text;
    _headerContactNameCtrl.text = v('contactName') ?? _headerContactNameCtrl.text;
    _headerCompanyAddressCtrl.text =
        v('companyAddress') ?? _headerCompanyAddressCtrl.text;
    _headerDateCtrl.text = v('date') ?? _headerDateCtrl.text;
    _headerUserProfessionCtrl.text =
        v('userProfession') ?? _headerUserProfessionCtrl.text;
  }

  static Map<String, dynamic>? _decodeJsonMap(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  static quill.QuillController _createController(quill.Document document) {
    return quill.QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      // ignore: experimental_member_use
      config: const quill.QuillControllerConfig(
        // ignore: experimental_member_use
        clipboardConfig: quill.QuillClipboardConfig(
          // ignore: experimental_member_use
          enableExternalRichPaste: false,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _templateId = widget.template?.id;
    _applicationNotifier = ref.read(applicationNotifierProvider);
    _templateEditorNotifier = ref.read(templateEditorProvider.notifier);
    _settingsRepository = ref.read(settingsRepositoryProvider);
    _textbausteinStream = ref
        .read(templatesRepositoryProvider)
        .watchTemplatesByType('textbaustein');
    _loadApplication();
    FontScanner.loadSystemFonts().then((_) {
      _safeSetState(() {});
    });
  }

  Future<void> _loadApplication() async {
    quill.Document document = quill.Document();
    try {
      final settings = _settingsRepository;
      final langSetting = await settings.getSettingByKey('spellCheckLanguage');
      SpellChecker.loadDictionary(language: langSetting?.value ?? 'de');

      final nameSetting = await settings.getSettingByKey('userName');
      final emailSetting = await settings.getSettingByKey('userEmail');
      final phoneSetting = await settings.getSettingByKey('userPhone');
      final addressSetting = await settings.getSettingByKey('userAddress');
      final zipSetting = await settings.getSettingByKey('userZip');
      final citySetting = await settings.getSettingByKey('userCity');
      final birthdateSetting = await settings.getSettingByKey('userBirthdate');
      final masterProfile = _decodeJsonMap(
        (await settings.getSettingByKey(_kCvProfileMasterKey))?.value,
      );
      if (!mounted) return;

      _userName = nameSetting?.value ?? 'Dein Name';
      _userEmail = emailSetting?.value ?? 'email@beispiel.de';
      _userPhone = phoneSetting?.value ?? '0123-456789';
      _userAddress = addressSetting?.value ?? 'Musterstraße 1';
      _userZip = zipSetting?.value ?? '12345';
      _userCity = citySetting?.value ?? 'Musterstadt';
      _userProfession = '';

      _headerUserNameCtrl.text = _userName;
      _headerUserProfessionCtrl.text = _userProfession;
      _headerUserEmailCtrl.text = _userEmail;
      _headerUserPhoneCtrl.text = _userPhone;
      _headerUserAddressCtrl.text = '$_userAddress\n$_userZip $_userCity';

      // Fallback-Kette für das Lebenslauf-Profil:
      // Einstellungen -> Master-Profil -> gespeichertes Profil der Bewerbung.
      _cvNameCtrl.text = nameSetting?.value ?? '';
      _cvEmailCtrl.text = emailSetting?.value ?? '';
      _cvPhoneCtrl.text = phoneSetting?.value ?? '';
      _cvAddressCtrl.text = [
        addressSetting?.value ?? '',
        '${zipSetting?.value ?? ''} ${citySetting?.value ?? ''}'.trim(),
      ].where((e) => e.isNotEmpty).join(', ');
      _cvBirthdateCtrl.text = birthdateSetting?.value ?? '';
      if (masterProfile != null) _applyCvProfile(masterProfile);

      _headerDateCtrl.text =
          "${_userCity.isNotEmpty ? _userCity : 'Stadt'}, den ${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}";

      _nameController.text = widget.template?.name ?? '';

      if (widget.template != null) {
        if (widget.template!.content.isNotEmpty) {
          try {
            final decoded = jsonDecode(widget.template!.content);
            document = quill.Document.fromJson(decoded);
          } catch (e) {
            document = quill.Document()..insert(0, widget.template!.content);
          }
        }
        final templateHeader = _decodeJsonMap(
          (await settings.getSettingByKey(
            _letterHeaderTemplateKey(widget.template!.id),
          ))?.value,
        );
        if (!mounted) return;
        if (templateHeader != null) _applyLetterHeader(templateHeader);
      } else if (widget.applicationId != null) {
        final app = await ref
            .read(applicationsRepositoryProvider)
            .getApplicationById(widget.applicationId!);
        if (!mounted) return;

        if (app != null) {
          _application = app;
          _headerCompanyNameCtrl.text = app.company;
          _headerContactNameCtrl.text = app.contactName ?? 'Personalabteilung';
          _headerCompanyAddressCtrl.text =
              app.address ?? 'Musterstraße 1, 12345 Stadt';

          final cvContent = app.cvContent;
          final stored = _decodeJsonMap(cvContent);
          if (stored != null) {
            _cvContentMap = stored;
          } else if (cvContent != null && cvContent.trim().isNotEmpty) {
            // Unbekannter Altinhalt: nicht verwerfen, sondern mitführen.
            _cvContentMap = {'legacyText': cvContent};
          }
          final profile = _cvContentMap['cvProfile'];
          if (profile is Map) {
            _applyCvProfile(Map<String, dynamic>.from(profile));
          }
          final header = _cvContentMap['letterHeader'];
          if (header is Map) {
            _applyLetterHeader(Map<String, dynamic>.from(header));
          }

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
    } catch (e, stack) {
      debugPrint('Editor: Laden fehlgeschlagen: $e\n$stack');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _showSnack('Dokument konnte nicht vollständig geladen werden: $e'),
        );
      }
    }

    if (!mounted) return;
    _controller = _createController(document);
    _controllerCreated = true;
    _attachControllerListener();
    _lastPersonalSnapshot = _personalSnapshot();
    _persistedCvProfileJson = jsonEncode(_cvProfileData());
    _persistedLetterHeaderJson = jsonEncode(_letterHeaderData());
    for (final c in _persistedControllers) {
      c.addListener(_onPersonalFieldChanged);
    }
    setState(() {
      _isLoading = false;
    });
    _runAtsAnalysis();
  }

  void _attachControllerListener() {
    // Nur echte Dokumentänderungen zählen – Auswahl-/Cursoränderungen
    // benachrichtigen den Controller ebenfalls, ändern aber nichts.
    _docChangesSub = _controller.document.changes.listen((_) {
      if (_disposed) return;
      _docRevision++;
      _markDirty();

      // Debounce ALL analysis (keywords + spelling) so we never call
      // setState during active typing → cursor stays stable.
      _spellCheckTimer?.cancel();
      _spellCheckTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted || _disposed) return;
        _runAtsAnalysis();
      });
    });
  }

  void _markDirty() {
    final wasClean = !_hasChanges;
    _revision++;
    if (wasClean) _safeSetState(() {});

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 2), () {
      if (_hasChanges && !_disposed) _save();
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

    _safeSetState(() => _isSpellChecking = true);
    SpellChecker.checkText(plainText).then((issues) {
      _safeSetState(() {
        _missingKeywords = newMissing;
        _foundKeywords = newFound;
        _grammarWarnings = issues;
        _isSpellChecking = false;
      });
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _autoSaveTimer?.cancel();
    _spellCheckTimer?.cancel();
    // Ausstehende Änderungen beim Verlassen sichern. Der Snapshot wird
    // synchron erfasst; der Schreibvorgang läuft ohne setState weiter.
    if (_controllerCreated && _hasChanges) {
      _save();
    }
    _docChangesSub?.cancel();
    for (final c in _persistedControllers) {
      c.removeListener(_onPersonalFieldChanged);
    }
    for (final c in _allTextControllers) {
      c.dispose();
    }
    _editorFocusNode.dispose();
    if (_controllerCreated) {
      _controller.dispose();
    }
    super.dispose();
  }

  _SaveSnapshot _captureSnapshot() {
    final delta = _controller.document.toDelta().toJson();
    return _SaveSnapshot(
      revision: _revision,
      deltaJson: delta,
      deltaJsonString: jsonEncode(delta),
      cvProfile: _cvProfileData(),
      letterHeader: _letterHeaderData(),
      name: _nameController.text.trim().isEmpty
          ? 'Neues Dokument'
          : _nameController.text.trim(),
      type: widget.template?.type ?? widget.initialType ?? 'anschreiben',
    );
  }

  /// Speichert den aktuellen Stand. Speichervorgänge werden nacheinander
  /// ausgeführt; liefert false bei einem Fehler (Änderungen bleiben dann als
  /// ungespeichert markiert).
  Future<bool> _save() {
    if (!_controllerCreated) return Future.value(true);
    final snapshot = _captureSnapshot();
    final result = _saveChain.then((_) => _persist(snapshot));
    _saveChain = result.catchError((_) => false);
    return result;
  }

  Future<bool> _persist(_SaveSnapshot s) async {
    if (s.revision <= _savedRevision) return true; // bereits gespeichert
    _safeSetState(() => _isSaving = true);
    try {
      final appId = widget.applicationId;
      final cvProfileJson = jsonEncode(s.cvProfile);
      final letterHeaderJson = jsonEncode(s.letterHeader);
      final cvProfileChanged = cvProfileJson != _persistedCvProfileJson;
      final letterHeaderChanged =
          letterHeaderJson != _persistedLetterHeaderJson;

      if (appId != null) {
        await _applicationNotifier.updateCoverLetterContent(
          appId,
          s.deltaJsonString,
        );
        if (cvProfileChanged || letterHeaderChanged) {
          // Andere Schlüssel in cvContent bleiben erhalten.
          final merged = Map<String, dynamic>.from(_cvContentMap)
            ..['cvProfile'] = s.cvProfile
            ..['letterHeader'] = s.letterHeader;
          await _applicationNotifier.updateCvContent(appId, jsonEncode(merged));
          _cvContentMap = merged;
        }
      } else {
        // Vorlage: ID nach dem ersten Insert merken, sonst entstünde bei
        // jedem Autosave eine neue Vorlage.
        final templateId = await _templateEditorNotifier.saveTemplate(
          existingId: _templateId,
          name: s.name,
          type: s.type,
          deltaJson: s.deltaJson,
        );
        _templateId = templateId;
        if (cvProfileChanged) {
          await _settingsRepository.insertOrUpdateSetting(
            SettingEntity(key: _kCvProfileMasterKey, value: cvProfileJson),
          );
        }
        if (letterHeaderChanged) {
          await _settingsRepository.insertOrUpdateSetting(
            SettingEntity(
              key: _letterHeaderTemplateKey(templateId),
              value: letterHeaderJson,
            ),
          );
        }
      }
      _persistedCvProfileJson = cvProfileJson;
      _persistedLetterHeaderJson = letterHeaderJson;
      if (s.revision > _savedRevision) _savedRevision = s.revision;
      return true;
    } catch (e, stack) {
      debugPrint('Editor: Speichern fehlgeschlagen: $e\n$stack');
      _showSnack('Speichern fehlgeschlagen: $e');
      return false;
    } finally {
      _safeSetState(() => _isSaving = false);
    }
  }

  CvData _buildCvData(CvDataState cvState) {
    return CvData(
      initials: initialsFromName(_cvNameCtrl.text),
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
        dateRange: _formatDateRange(e.startDate, e.endDate, isCurrent: e.isCurrent),
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
    );
  }

  Future<void> _exportPdf() async {
    if (_isExportingPdf) return;
    _safeSetState(() => _isExportingPdf = true);
    try {
      final Uint8List bytes;
      final String suggestedName;
      if (_isCvMode) {
        final cvState = await ref.read(cvProvider(widget.applicationId).future);
        bytes = await PdfCvGenerator.generatePdf(
          _buildCvData(cvState),
          _currentDesignId,
          _currentAccentColor,
        );
        suggestedName = _pdfFileName('Lebenslauf');
      } else {
        bytes = await PdfCvGenerator.generateCoverLetterPdf(
          header: CoverLetterPdfHeader(
            senderName: _headerUserNameCtrl.text,
            senderProfession: _headerUserProfessionCtrl.text,
            senderAddress: _headerUserAddressCtrl.text,
            senderPhone: _headerUserPhoneCtrl.text,
            senderEmail: _headerUserEmailCtrl.text,
            companyName: _headerCompanyNameCtrl.text,
            contactName: _headerContactNameCtrl.text,
            companyAddress: _headerCompanyAddressCtrl.text,
            date: _headerDateCtrl.text,
          ),
          deltaOps: _controller.document.toDelta().toJson(),
          designId: _currentDesignId,
          accentColor: _currentAccentColor,
          pageMargins: EdgeInsets.only(left: _marginLeft, top: _marginTop, right: _marginRight, bottom: _marginBottom),
          fontSizePx: _currentFontSize,
          lineHeight: _currentLineHeight,
        );
        suggestedName = _pdfFileName('Anschreiben');
      }
      if (!mounted || _disposed) return;

      final location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );
      if (location == null) return; // abgebrochen
      var path = location.path;
      if (!path.toLowerCase().endsWith('.pdf')) path = '$path.pdf';
      await File(path).writeAsBytes(bytes, flush: true);
      _showSnack('PDF gespeichert: $path');
    } catch (e, stack) {
      debugPrint('Editor: PDF-Export fehlgeschlagen: $e\n$stack');
      _showSnack('PDF-Export fehlgeschlagen: $e');
    } finally {
      _safeSetState(() => _isExportingPdf = false);
    }
  }

  String _pdfFileName(String prefix) {
    final suffix = _application?.company ?? _nameController.text;
    final raw = suffix.trim().isEmpty ? prefix : '${prefix}_$suffix';
    return '${raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.pdf';
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
                    onPressed: () async {
                      _autoSaveTimer?.cancel();
                      final ok = await _save();
                      if (ok) _showSnack('Dokument gespeichert.');
                    },
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    icon: _isExportingPdf
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf, size: 16),
                    label: Text(
                      _isCvMode ? 'Lebenslauf als PDF' : 'Anschreiben als PDF',
                    ),
                    onPressed: _isExportingPdf ? null : _exportPdf,
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


  String _formatDateRange(DateTime? start, DateTime? end, {bool isCurrent = false}) {
    if (start == null) return '';
    final startStr = '${start.month.toString().padLeft(2, '0')}/${start.year}';
    if (end == null || isCurrent) return '$startStr - Heute';
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
                    _buildCvData(cvState),
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
                        if (widget.applicationId != null &&
                            cvState.experiences.isEmpty &&
                            cvState.educations.isEmpty &&
                            cvState.skills.isEmpty &&
                            cvState.languages.isEmpty &&
                            cvState.customItems.isEmpty)
                          _buildCopyFromMasterBanner(colorScheme),
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
                                ref.read(cvNotifierProvider).addCustomItem(widget.applicationId, result['sectionName'], result['title'], result['subtitle'], result['dateRange'], result['description']);
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

  Widget _buildCopyFromMasterBanner(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Für diese Bewerbung gibt es noch keine Lebenslauf-Einträge.',
              style: TextStyle(fontSize: 12, color: colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.copy_all, size: 16),
              label: const Text('Aus Master-Lebenslauf übernehmen'),
              onPressed: _copyFromMasterCv,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyFromMasterCv() async {
    final appId = widget.applicationId;
    if (appId == null) return;
    try {
      final copied = await ref.read(cvNotifierProvider).copyFromMaster(appId);
      _showSnack(
        copied == 0
            ? 'Der Master-Lebenslauf enthält noch keine Einträge.'
            : '$copied Einträge aus dem Master-Lebenslauf übernommen.',
      );
    } catch (e) {
      _showSnack('Übernahme fehlgeschlagen: $e');
    }
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
      stream: _textbausteinStream,
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

  /// Klartext eines Bausteins (gecacht, damit nicht bei jedem Build neu
  /// dekodiert wird).
  String _blockPlainText(TemplateEntity template) {
    final content = template.content;
    if (content.isEmpty) return '';
    final cached = _blockPreviewCache[content];
    if (cached != null) return cached;
    var text = content;
    try {
      text = quill.Document.fromJson(jsonDecode(content)).toPlainText();
    } catch (_) {}
    if (_blockPreviewCache.length > 200) _blockPreviewCache.clear();
    return _blockPreviewCache[content] = text;
  }

  void _insertBlock(TemplateEntity template) {
    final text = _blockPlainText(template);
    if (text.isEmpty) return;
    final docLength = _controller.document.length;
    final selection = _controller.selection;
    final offset = selection.baseOffset < 0
        ? docLength - 1
        : selection.baseOffset.clamp(0, docLength - 1);
    // replaceText benachrichtigt Listener (Autosave/Analyse) und setzt den
    // Cursor hinter den eingefügten Text.
    _controller.replaceText(
      offset,
      0,
      text,
      TextSelection.collapsed(offset: offset + text.length),
    );
    _showSnack('Baustein eingefügt.');
  }

  Widget _buildDraggableBlock(TemplateEntity template) {
    final plain = _blockPlainText(template).replaceAll('\n', ' ').trim();
    final preview = plain.isEmpty ? '...' : plain;

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
        onTap: () => _insertBlock(template),
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
                          offset: _marginTop,
                        ),
                      ),
                      Column(
                        children: [
                          // Horizontal Ruler
                          EditorRuler(
                            isHorizontal: true,
                            length: 794,
                            offset: _marginLeft,
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
                                              Navigator.pop(context); // close dialog
                                              _replaceFlaggedWord(
                                                w['title'] as String,
                                                w['offset'] as int,
                                                s,
                                              );
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
                                          Navigator.pop(
                                            context,
                                          ); // close dialog
                                          _recheckSpelling();
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
                if (widget.applicationId == null)
                  Text(
                    'Keyword-Analyse ist nur für Anschreiben einer Bewerbung verfügbar.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  )
                else if (_application?.jobDescriptionText == null ||
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

  Future<void> _pasteJobDescription() async {
    final appId = widget.applicationId;
    if (appId == null) return;
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => const _JobDescriptionDialog(),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    try {
      await ref
          .read(applicationNotifierProvider)
          .updateJobDescription(appId, text.trim());
      final updatedApp = await ref
          .read(applicationsRepositoryProvider)
          .getApplicationById(appId);
      if (!mounted || _disposed) return;
      setState(() {
        _application = updatedApp;
      });
      _runAtsAnalysis();
    } catch (e) {
      _showSnack('Stellenanzeige konnte nicht gespeichert werden: $e');
    }
  }

  void _recheckSpelling() {
    if (_disposed) return;
    SpellChecker.checkText(_controller.document.toPlainText()).then((issues) {
      _safeSetState(() => _grammarWarnings = issues);
    });
  }

  /// Ersetzt ein gemeldetes Wort. Da sich der Text seit der Prüfung geändert
  /// haben kann, wird zuerst geprüft, ob an [offset] noch [word] steht; sonst
  /// wird das nächstgelegene Vorkommen (als ganzes Wort) gesucht.
  void _replaceFlaggedWord(String word, int offset, String replacement) {
    final plain = _controller.document.toPlainText();
    final target = _findWordNear(plain, word, offset);
    if (target == null) {
      _showSnack('"$word" wurde im Text nicht mehr gefunden.');
      _recheckSpelling();
      return;
    }
    try {
      _controller.replaceText(target, word.length, replacement, null);
    } catch (e) {
      _showSnack('Korrektur fehlgeschlagen.');
    }
    _recheckSpelling();
  }

  static int? _findWordNear(String text, String word, int offset) {
    bool isWordChar(int index) =>
        index >= 0 &&
        index < text.length &&
        RegExp(r'\p{L}', unicode: true).hasMatch(text[index]);
    bool matchesAt(int i) =>
        i >= 0 &&
        i + word.length <= text.length &&
        text.substring(i, i + word.length) == word &&
        !isWordChar(i - 1) &&
        !isWordChar(i + word.length);

    if (matchesAt(offset)) return offset;
    int? best;
    var start = text.indexOf(word);
    while (start != -1) {
      if (matchesAt(start) &&
          (best == null || (start - offset).abs() < (best - offset).abs())) {
        best = start;
      }
      start = text.indexOf(word, start + 1);
    }
    return best;
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

/// Dialog zum Einfügen der Stellenanzeige; besitzt seinen eigenen Controller,
/// der mit dem Dialog sauber entsorgt wird.
class _JobDescriptionDialog extends StatefulWidget {
  const _JobDescriptionDialog();

  @override
  State<_JobDescriptionDialog> createState() => _JobDescriptionDialogState();
}

class _JobDescriptionDialogState extends State<_JobDescriptionDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Stellenanzeige einfügen'),
      content: SizedBox(
        width: 500,
        child: TextField(
          controller: _ctrl,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'Füge hier den Text der Stellenanzeige ein...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _ctrl.text),
          child: const Text('Speichern & Analysieren'),
        ),
      ],
    );
  }
}
