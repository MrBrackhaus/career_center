import '../../../l10n/app_localizations.dart';

/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:file_selector/file_selector.dart';

import 'email_composer_dialog.dart';
import '../../providers/application_form_notifier.dart';
import '../../providers/ai_settings_provider.dart';
import '../../../core/services/document_intelligence_service.dart';
import '../../../core/services/document_storage_service.dart';
import '../../../domain/enums/application_status.dart';
import '../../../domain/enums/document_type.dart';
import '../../../domain/models/extraction_result.dart';

import 'dart:convert';

import 'package:pdfrx/pdfrx.dart';
import 'package:desktop_drop/desktop_drop.dart';

import 'widgets/web_reader_widget.dart';
import 'widgets/notes_widget.dart';
import 'widgets/documents_widget.dart';
import 'widgets/basic_data_tab.dart';
import 'widgets/emails_contacts_tab.dart';
import 'application_form_state_bundle.dart';
import 'custom_fields_codec.dart';

import '../../../domain/models/application_form_dto.dart';
import '../../providers/database_provider.dart';
import '../../providers/applications_provider.dart';
import 'dart:developer' show log;

class SaveIntent extends Intent {
  const SaveIntent();
}

class CloseIntent extends Intent {
  const CloseIntent();
}

/// Tab-Indizes im Bearbeiten-Modus:
/// 0 = Grunddaten, 1 = E-Mails/Kontakte, 2 = Dokumente, 3 = Notizen.
class _FormTab {
  static const int basic = 0;
  static const int documents = 2;
  static const int count = 4;
}

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final int? applicationId;
  final String? initialUrl;
  final String? initialHtml;
  final String? initialScreenshotBase64;

  const ApplicationFormScreen({
    super.key,
    this.applicationId,
    this.initialUrl,
    this.initialHtml,
    this.initialScreenshotBase64,
  });

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  // Controllers statt initialValue – damit Auto-Fill das Widget sofort aktualisiert
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _notesController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  final _commutCarController = TextEditingController();
  final _salaryWishController = TextEditingController();
  final _jobUrlController =
      TextEditingController(); // Normales Formularfeld für Job-Link
  final _autoFillUrlController =
      TextEditingController(); // Nur für das Magic-Auto-Fill Feld
  final _companyUrlController = TextEditingController();
  // Kontakt-Felder
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _jobDescriptionTextController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  /// Zuletzt gespeicherte benutzerdefinierte Felder (inkl. Felder, die nicht
  /// mehr in der Spaltenkonfiguration stehen – diese bleiben beim Speichern
  /// erhalten).
  Map<String, String> _storedCustomFields = {};

  String _status = ApplicationStatus.offen;
  DateTime? _appliedDate;
  DateTime? _followUpDate;
  List<String> _activeCustomColumns = [];
  bool _isLoading = false;
  bool _isAutoFilling = false;
  bool _isSaving = false;
  bool _isDragging = false;
  ExtractionResult? _lastExtractionResult;

  /// Momentaufnahme der Formularwerte nach Laden/Speichern – für die
  /// Erkennung ungespeicherter Änderungen.
  String? _savedSnapshot;

  // Split-View State
  String? _loadedPdfPath;
  String? _loadedWebContent;
  String? _loadedWebUrl;
  String? _activeMarkerField; // Which field is waiting for text selection
  String? _pendingScreenshotBase64;

  bool get _isEditing => widget.applicationId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _isEditing ? _FormTab.count : 1,
      vsync: this,
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _pendingScreenshotBase64 = widget.initialScreenshotBase64;
    _loadCustomColumns();
    if (_isEditing) {
      _loadApplication();
    } else {
      _isLoading = false;
      _savedSnapshot = _snapshot();
      if (widget.initialUrl != null || widget.initialHtml != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _autoFillFromInjectedData(widget.initialUrl, widget.initialHtml);
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _notesController.dispose();
    _rejectionReasonController.dispose();
    _commutCarController.dispose();
    _salaryWishController.dispose();
    _jobUrlController.dispose();
    _autoFillUrlController.dispose();
    _companyUrlController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _addressController.dispose();
    _jobDescriptionTextController.dispose();
    for (final c in _customFieldControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Ungespeicherte Änderungen ───────────────────────────────────────────

  Map<String, String> _customFieldInputs() => {
    for (final e in _customFieldControllers.entries) e.key: e.value.text,
  };

  String _snapshot() {
    return json.encode({
      'company': _companyController.text,
      'position': _positionController.text,
      'notes': _notesController.text,
      'rejection': _rejectionReasonController.text,
      'commute': _commutCarController.text,
      'salary': _salaryWishController.text,
      'jobUrl': _jobUrlController.text,
      'companyUrl': _companyUrlController.text,
      'contactName': _contactNameController.text,
      'contactEmail': _contactEmailController.text,
      'contactPhone': _contactPhoneController.text,
      'address': _addressController.text,
      'jd': _jobDescriptionTextController.text,
      'custom': mergeCustomFields(_storedCustomFields, _customFieldInputs()),
      'status': _status,
      'applied': _appliedDate?.toIso8601String(),
      'followUp': _followUpDate?.toIso8601String(),
    });
  }

  bool get _isDirty {
    if (_isLoading) return false;
    if (_savedSnapshot == null) return false;
    return _snapshot() != _savedSnapshot;
  }

  /// Schließt das Formular; fragt bei ungespeicherten Änderungen nach.
  Future<void> _requestClose() async {
    if (_isDirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ungespeicherte Änderungen'),
          content: const Text(
            'Du hast Änderungen, die noch nicht gespeichert sind. '
            'Formular trotzdem schließen und die Änderungen verwerfen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Weiter bearbeiten'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Verwerfen',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    if (mounted) context.pop();
  }

  // ── Laden ───────────────────────────────────────────────────────────────

  Future<void> _loadCustomColumns() async {
    try {
      final dao = ref.read(settingsRepositoryProvider);
      final colsSetting = await dao.getSettingByKey('customColumns');
      if (!mounted) return;
      if (colsSetting != null && colsSetting.value.isNotEmpty) {
        final cols = colsSetting.value
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        final wasClean = !_isDirty;
        setState(() {
          _activeCustomColumns = cols;
          for (final col in cols) {
            _customFieldControllers.putIfAbsent(
              col,
              () => TextEditingController(text: _storedCustomFields[col] ?? ''),
            );
          }
        });
        if (wasClean && _savedSnapshot != null) _savedSnapshot = _snapshot();
      }
    } catch (e, st) {
      log('Benutzerdefinierte Spalten konnten nicht geladen werden: $e',
          error: e, stackTrace: st);
    }
  }

  Future<void> _autoFillFromInjectedData(String? url, String? html) async {
    setState(() {
      _isAutoFilling = true;
      _loadedPdfPath = null;
      _loadedWebContent = html;
      _loadedWebUrl = url;
      _activeMarkerField = null;
      if (url != null) {
        _autoFillUrlController.text = url;
        _jobUrlController.text = url;
      }
    });

    try {
      if (html != null) {
        final service = DocumentIntelligenceService();
        final result = await service.analyzeDocument(
          html,
          source: DocumentSource.url,
        );
        if (!mounted) return;
        await _applyExtractionResult(result, showFeedback: false);
      }
      if (!mounted) return;
      setState(() => _isAutoFilling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Daten direkt aus dem Browser übernommen!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, st) {
      log('An error occurred: $e', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _isAutoFilling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Fehler beim Auslesen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);
    try {
      final app = await ref
          .read(applicationsRepositoryProvider)
          .getApplicationById(widget.applicationId!);
      if (!mounted) return;
      if (app == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bewerbung wurde nicht gefunden.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _companyController.text = app.company;
        _positionController.text = app.position;
        _status = normalizeApplicationStatus(
          app.status,
          fallback: ApplicationStatus.offen,
        );
        _notesController.text = app.notes ?? '';
        _rejectionReasonController.text = app.rejectionReason ?? '';
        _appliedDate = app.appliedDate;
        _followUpDate = app.followupDate;
        _commutCarController.text = app.commuteCar?.toString() ?? '';
        _salaryWishController.text = app.salaryWish?.toString() ?? '';
        _jobUrlController.text = app.jobUrl ?? '';
        _companyUrlController.text = app.companyUrl ?? '';

        _contactNameController.text = app.contactName ?? '';
        _contactEmailController.text = app.contactEmail ?? '';
        _contactPhoneController.text = app.contactPhone ?? '';
        _addressController.text = app.address ?? '';
        _jobDescriptionTextController.text = app.jobDescriptionText ?? '';

        _storedCustomFields = decodeCustomFields(app.customFields);
        for (final entry in _storedCustomFields.entries) {
          _customFieldControllers[entry.key]?.text = entry.value;
        }
        _isLoading = false;
      });
      _savedSnapshot = _snapshot();
    } catch (e, st) {
      log('Bewerbung konnte nicht geladen werden: $e', error: e, stackTrace: st);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der Bewerbung: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Übernimmt Status und Bewerbungsdatum aus der Datenbank (z.B. nachdem
  /// der E-Mail-Dialog die Bewerbung als versendet markiert hat), ohne
  /// andere, evtl. ungespeicherte Eingaben anzutasten.
  Future<void> _refreshStatusFromDatabase() async {
    try {
      final app = await ref
          .read(applicationsRepositoryProvider)
          .getApplicationById(widget.applicationId!);
      if (!mounted || app == null) return;
      final wasClean = !_isDirty;
      setState(() {
        _status = normalizeApplicationStatus(
          app.status,
          fallback: ApplicationStatus.offen,
        );
        _appliedDate = app.appliedDate;
      });
      if (wasClean) _savedSnapshot = _snapshot();
    } catch (e, st) {
      log('Status konnte nicht neu geladen werden: $e', error: e, stackTrace: st);
    }
  }

  Future<void> _openEmailComposer() async {
    try {
      final app = await ref
          .read(applicationsRepositoryProvider)
          .getApplicationById(widget.applicationId!);
      if (!mounted || app == null) return;
      final sent = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => EmailComposerDialog(application: app),
      );
      if (sent == true && mounted) {
        await _refreshStatusFromDatabase();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ── Auto-Fill ───────────────────────────────────────────────────────────

  Future<void> _autoFillFromUrl() async {
    var url = _autoFillUrlController.text.trim().replaceAll(RegExp(r'\s+'), '');
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte erst eine URL eingeben.')));
      return;
    }

    setState(() {
      _isAutoFilling = true;
      _loadedPdfPath = null;
      _loadedWebUrl = url;
      _activeMarkerField = null;
    });

    try {
      await ref.read(applicationFormNotifierProvider.notifier).extractFromUrl(url);
      if (!mounted) return;
      final state = ref.read(applicationFormNotifierProvider);

      if (state.loadedWebContent != null) {
        setState(() => _loadedWebContent = state.loadedWebContent);
      }

      if (_jobUrlController.text.trim().isEmpty || !_isEditing) {
        _jobUrlController.text = url;
      }

      if (state.result != null) {
        await _applyExtractionResult(state.result!);
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('CaptchaDetectedException')) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Captcha / Blockierung erkannt'),
              content: const Text(
                'Die Webseite blockiert das automatische Auslesen.\n'
                'Bitte lade die Seite als PDF herunter und probiere den PDF-Upload.'
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK, verstanden')),
              ],
            ),
          );
        } else if (e.toString().contains('NoDataFoundException')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Keine Daten gefunden. Die Seite nutzt evtl. clientseitiges Rendering.'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Laden der URL: $e'), backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }

  Future<void> _handleDroppedFiles(DropDoneDetails details) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;

    final tabIndex = _tabController.index;

    // Dokumente-Tab: Dateien als Dokumente ablegen.
    if (_isEditing && tabIndex == _FormTab.documents) {
      await importDocumentFiles(
        context,
        ref,
        widget.applicationId!,
        details.files.map((f) => f.path).toList(),
      );
      return;
    }

    // Auslesen nur im Grunddaten-Tab.
    if (tabIndex != _FormTab.basic) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dateien können im Tab "Grunddaten" (zum Auslesen) oder im Tab '
            '"Dokumente" (zum Ablegen) abgelegt werden.',
          ),
        ),
      );
      return;
    }

    if (_isLoading) return;

    final xfile = details.files.first;
    if (!xfile.name.toLowerCase().endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte nur PDF-Dateien ablegen.')),
      );
      return;
    }

    try {
      final bytes = await xfile.readAsBytes();
      if (!mounted) return;
      setState(() {
        _isAutoFilling = true;
        _loadedPdfPath = xfile.path;
        _loadedWebContent = null;
        _loadedWebUrl = null;
        _activeMarkerField = null;
      });

      String text = '';
      try {
        final doc = await PdfDocument.openData(bytes);
        final StringBuffer textBuf = StringBuffer();
        for (var page in doc.pages) {
          final pageText = await page.loadText();
          if (pageText != null) {
            textBuf.writeln(pageText.fullText);
          }
        }
        text = textBuf.toString().replaceAll(' ', ' ');
        doc.dispose();
      } on Exception catch (e, st) {
        log('An error occurred: $e', error: e, stackTrace: st);
        throw Exception('Fehler bei der PDF-Textextraktion mit pdfrx: $e');
      }
      if (!mounted) return;

      final service = DocumentIntelligenceService();
      final result = await service.analyzeDocument(
        text,
        source: DocumentSource.pdf,
      );
      if (!mounted) return;

      await _applyExtractionResult(result);
    } catch (e, st) {
      log('An error occurred: $e', error: e, stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim PDF auslesen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }

  Future<void> _autoFillFromPdf() async {
    final typeGroup = const XTypeGroup(label: 'PDF', extensions: ['pdf']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null || !mounted) return;

    setState(() {
      _isAutoFilling = true;
      _loadedPdfPath = file.path;
      _loadedWebContent = null;
      _loadedWebUrl = null;
      _activeMarkerField = null;
    });

    try {
      final bytes = await file.readAsBytes();
      await ref.read(applicationFormNotifierProvider.notifier).extractFromPdfBytes(bytes);
      if (!mounted) return;
      final result = ref.read(applicationFormNotifierProvider).result;
      if (result != null) {
        await _applyExtractionResult(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim PDF auslesen: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isAutoFilling = false);
    }
  }

  /// Bereinigt evtl. HTML aus dem Rohtext der Stellenanzeige.
  static String _cleanJobDescription(String raw) {
    String jd = raw;
    if (jd.contains('<html') ||
        jd.contains('<!DOCTYPE') ||
        jd.contains('<body')) {
      try {
        final doc = html_parser.parse(jd);
        doc
            .querySelectorAll('script, style, noscript')
            .forEach((e) => e.remove());
        jd = doc.body?.text ?? doc.documentElement?.text ?? jd;
      } on Exception catch (e, st) {
        log('An error occurred: $e', error: e, stackTrace: st);
        debugPrint('HTML parsing error: $e');
      }
      // Fallback falls immer noch HTML-Reste vorhanden sind
      if (jd.contains('<html') ||
          jd.contains('<!DOCTYPE') ||
          jd.contains('<body')) {
        jd = jd.replaceAll(
          RegExp(
            r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
            caseSensitive: false,
          ),
          '',
        );
        jd = jd.replaceAll(
          RegExp(
            r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>',
            caseSensitive: false,
          ),
          '',
        );
        jd = jd.replaceAll(RegExp(r'<[^>]+>'), ' ');
      }
      jd = jd.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    return jd;
  }

  /// Wendet ein ExtractionResult auf die Formularfelder an.
  ///
  /// Bereits ausgefüllte Felder werden nur nach Rückfrage überschrieben;
  /// ansonsten werden nur leere Felder befüllt.
  /// Zeigt Confidence-basierte Warnungen an.
  Future<void> _applyExtractionResult(
    ExtractionResult result, {
    bool showFeedback = true,
  }) async {
    final fields = result.fields;

    // Geplante Text-Änderungen: Label -> (Controller, neuer Wert)
    final textUpdates = <String, (TextEditingController, String)>{};
    void plan(String label, TextEditingController c, String? value,
        {int? maxLength}) {
      if (value == null) return;
      final v = value.trim();
      if (v.isEmpty) return;
      if (maxLength != null && v.length >= maxLength) return;
      textUpdates[label] = (c, v);
    }

    plan('Position', _positionController, fields.position?.value, maxLength: 100);
    plan('Firma', _companyController, fields.company?.value, maxLength: 100);
    plan('E-Mail', _contactEmailController, fields.contactEmail?.value);
    plan('Telefon', _contactPhoneController, fields.contactPhone?.value);
    plan('Firmen-Website', _companyUrlController, fields.companyUrl?.value);
    plan('Ansprechperson', _contactNameController, fields.contactName?.value);
    plan('Adresse', _addressController, fields.address?.value);
    plan('Notizen', _notesController, fields.notes?.value);
    if (result.rawText.isNotEmpty) {
      plan(
        'Stellenanzeige (Volltext)',
        _jobDescriptionTextController,
        _cleanJobDescription(result.rawText),
      );
    }

    final DateTime? newApplied = fields.applicationDate?.value;
    final String? newStatus = fields.applicationStatus != null
        ? normalizeApplicationStatus(
            fields.applicationStatus!.value,
            fallback: _status,
          )
        : null;

    // Konflikte: Felder, die bereits einen anderen Wert haben.
    final conflicts = <String>[
      for (final e in textUpdates.entries)
        if (e.value.$1.text.trim().isNotEmpty &&
            e.value.$1.text.trim() != e.value.$2)
          e.key,
      if (newApplied != null &&
          _appliedDate != null &&
          !DateUtils.isSameDay(newApplied, _appliedDate))
        'Bewerbungsdatum',
      if (newStatus != null &&
          _status != ApplicationStatus.offen &&
          newStatus != _status)
        'Status',
    ];

    bool overwrite = true;
    if (conflicts.isNotEmpty) {
      final choice = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Vorhandene Angaben überschreiben?'),
          content: Text(
            'Folgende Felder sind bereits ausgefüllt und würden durch die '
            'ausgelesenen Werte ersetzt:\n\n• ${conflicts.join('\n• ')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Nur leere Felder füllen'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Überschreiben'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      overwrite = choice == true;
    }

    setState(() {
      _lastExtractionResult = result;
      for (final e in textUpdates.values) {
        final controller = e.$1;
        if (overwrite || controller.text.trim().isEmpty) {
          controller.text = e.$2;
        }
      }
      if (newApplied != null && (overwrite || _appliedDate == null)) {
        _appliedDate = newApplied;
      }
      if (newStatus != null &&
          (overwrite || _status == ApplicationStatus.offen)) {
        _status = newStatus;
      }
      _isAutoFilling = false;
    });

    if (!mounted || !showFeedback) return;

    // ── Confidence-basiertes UI-Feedback ──────────────────────────────────
    final typeLabel = result.documentType.label;
    final confidence = (result.typeConfidence * 100).toInt();
    final fieldCount = result.fields.filledFieldCount;

    if (result.needsReview) {
      // Unter 30% – unsicher
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ $typeLabel erkannt ($confidence% Sicherheit). $fieldCount Felder ausgefüllt – bitte manuell prüfen!',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (!result.isReliable) {
      // 30-60% – mittlere Sicherheit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🟡 $typeLabel erkannt ($confidence%). $fieldCount Felder ausgefüllt – einige Felder prüfen.',
          ),
          backgroundColor: Colors.amber.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      // Über 60% – sicher
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ $typeLabel erkannt ($confidence%). $fieldCount Felder automatisch ausgefüllt.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleAiFeedbackCorrection(
    ExtractionResult result,
    DocumentType newType,
  ) {
    DocumentIntelligenceService().learnFromCorrection(result.rawText, newType);
    setState(() {
      _lastExtractionResult = ExtractionResult(
        documentType: newType,
        typeConfidence: 1.0,
        fields: result.fields,
        warnings: result.warnings,
        source: result.source,
        rawText: result.rawText,
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'KI hat gelernt: Neues Muster für "${newType.name}" gespeichert!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bewerbung löschen?'),
        content: const Text('Diese Bewerbung wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Löschen',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final app = await ref
          .read(applicationsRepositoryProvider)
          .getApplicationById(widget.applicationId!);
      if (app != null) {
        await ref.read(applicationNotifierProvider).deleteApplication(app);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Löschen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String get _dropHint {
    if (_isEditing && _tabController.index == _FormTab.documents) {
      return 'Dateien hier ablegen, um sie als Dokument zu speichern';
    }
    if (_tabController.index == _FormTab.basic) {
      return 'PDF hier ablegen zum Auslesen';
    }
    return 'Hier ist kein Ablegen möglich';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _isEditing;
    final isAiEnabled = ref.watch(aiSettingsProvider).value?.isAiEnabled ?? false;
    final loc = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _requestClose();
      },
      child: Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyS): const SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const CloseIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(onInvoke: (intent) => _save()),
          CloseIntent: CallbackAction<CloseIntent>(onInvoke: (intent) => _requestClose()),
        },
        child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Bewerbung bearbeiten' : 'Neue Bewerbung'),
          actions: [
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.edit_document),
                  label: const Text('Anschreiben'),
                  onPressed: () {
                    context.push(
                      '/applications/${widget.applicationId}/editor',
                    );
                  },
                ),
              ),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FilledButton.icon(
                  onPressed: _openEmailComposer,
                  icon: const Icon(Icons.send),
                  label: const Text('Bewerbung senden'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C6AF7),
                  ),
                ),
              ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: loc.formTabBasic),
              if (isEditing)
                Tab(text: isAiEnabled ? loc.formTabEmails : 'Kontakte'),
              if (isEditing)
                Tab(text: loc.formTabDocs),
              if (isEditing)
                Tab(text: loc.formTabNotes),
            ],
          ),
        ),
        body: DropTarget(
          onDragDone: _handleDroppedFiles,
          onDragEntered: (detail) => setState(() => _isDragging = true),
          onDragExited: (detail) => setState(() => _isDragging = false),
          child: Stack(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _KeepAlive(child: _buildSplitView(context, isEditing)),
                        if (isEditing)
                          EmailsAndContactsTab(
                            applicationId: widget.applicationId!,
                            showEmails: isAiEnabled,
                          ),
                        if (isEditing)
                          DocumentsWidget(applicationId: widget.applicationId!),
                        if (isEditing)
                          NotesWidget(applicationId: widget.applicationId!),
                      ],
                    ),
              if (_isDragging)
                Container(
                  color: Colors.blue.withValues(alpha: 0.2),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _tabController.index == _FormTab.documents
                              ? Icons.upload_file
                              : Icons.picture_as_pdf,
                          size: 64,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _dropHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    )));
  }

  bool get _hasDocumentPreview =>
      _loadedPdfPath != null || _loadedWebContent != null;

  Widget _buildSplitView(BuildContext context, bool isEditing) {
    final bundle = ApplicationFormStateBundle(
      formKey: _formKey,
      companyController: _companyController,
      positionController: _positionController,
      notesController: _notesController,
      rejectionReasonController: _rejectionReasonController,
      commutCarController: _commutCarController,
      salaryWishController: _salaryWishController,
      jobUrlController: _jobUrlController,
      autoFillUrlController: _autoFillUrlController,
      companyUrlController: _companyUrlController,
      contactNameController: _contactNameController,
      contactEmailController: _contactEmailController,
      contactPhoneController: _contactPhoneController,
      addressController: _addressController,
      jobDescriptionTextController: _jobDescriptionTextController,
      customFieldControllers: _customFieldControllers,
      status: _status,
      appliedDate: _appliedDate,
      followUpDate: _followUpDate,
      activeCustomColumns: _activeCustomColumns,
      isAutoFilling: _isAutoFilling,
      isSaving: _isSaving,
      lastExtractionResult: _lastExtractionResult,
      isEditing: isEditing,
      activeMarkerField: _activeMarkerField,
      onMarkerToggled: (field) {
        setState(() {
          _activeMarkerField = _activeMarkerField == field ? null : field;
        });
      },
      onSave: _save,
      onAutoFillFromUrl: _autoFillFromUrl,
      onCoverLetterGenerated: (deltaJson) {},
      onAutoFillFromPdf: _autoFillFromPdf,
      onStatusChange: (val) => setState(() => _status = val),
      onAppliedDateChange: (val) => setState(() => _appliedDate = val),
      onFollowUpDateChange: (val) => setState(() => _followUpDate = val),
      onAiFeedbackCorrection: _handleAiFeedbackCorrection,
      onDelete: isEditing ? _handleDelete : null,
    );
    final formWidget = BasicDataTab(bundle: bundle);

    if (!_hasDocumentPreview) {
      return formWidget;
    }

    return Row(
      children: [
        // Left: Form
        Expanded(child: formWidget),
        // Right: Document Preview
        Expanded(child: _buildDocumentPreview(context)),
      ],
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadedPdfPath != null) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: Column(
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PDF-Vorschau',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (_activeMarkerField != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '🎯 Markiere Text für: $_activeMarkerField',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => setState(() {
                      _loadedPdfPath = null;
                      _activeMarkerField = null;
                    }),
                    tooltip: 'Vorschau schließen',
                  ),
                ],
              ),
            ),
            // PDF Viewer
            Expanded(
              child: PdfViewer.file(
                _loadedPdfPath!,
                params: PdfViewerParams(
                  backgroundColor: Colors.white,
                  textSelectionParams: PdfTextSelectionParams(
                    onTextSelectionChange: (selection) async {
                      if (selection.hasSelectedText) {
                        final selectedText = await selection.getSelectedText();
                        if (selectedText.isNotEmpty &&
                            _activeMarkerField != null) {
                          _applyMarkerText(selectedText);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_loadedWebContent != null) {
      return WebReaderWidget(
        htmlContent: _loadedWebContent!,
        url: _loadedWebUrl,
        onTextSelected: (text) {
          if (_activeMarkerField != null) {
            _applyMarkerText(text);
          }
        },
      );
    }

    return const SizedBox.shrink();
  }

  void _applyMarkerText(String text) {
    final field = _activeMarkerField;
    if (field == null) return;

    final TextEditingController? target = switch (field) {
      FormMarkerField.company => _companyController,
      FormMarkerField.position => _positionController,
      FormMarkerField.address => _addressController,
      FormMarkerField.contactName => _contactNameController,
      FormMarkerField.contactEmail => _contactEmailController,
      FormMarkerField.contactPhone => _contactPhoneController,
      FormMarkerField.companyUrl => _companyUrlController,
      FormMarkerField.jobUrl => _jobUrlController,
      _ => null,
    };

    setState(() {
      target?.text = text.trim();
      _activeMarkerField = null;
    });

    if (target == null) {
      log('Unbekanntes Marker-Feld: $field');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feld "$field" kann nicht per Markierung befüllt werden.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "$field" wurde übernommen.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (_isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte warten, die Bewerbung wird noch geladen …')),
      );
      return;
    }
    final formState = _formKey.currentState;
    if (formState == null) {
      // Grunddaten-Tab ist (noch) nicht aufgebaut – dorthin wechseln.
      _tabController.animateTo(_FormTab.basic);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte prüfe die Grunddaten und speichere dann erneut.'),
        ),
      );
      return;
    }
    if (!formState.validate()) {
      if (_tabController.index != _FormTab.basic) {
        _tabController.animateTo(_FormTab.basic);
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Custom fields als JSON – Felder ohne aktuellen Controller (nicht mehr
      // konfigurierte Spalten) bleiben erhalten.
      final customFieldsJson =
          mergeCustomFields(_storedCustomFields, _customFieldInputs());

      final jdRaw = _jobDescriptionTextController.text;
      final jdClean = jdRaw.isEmpty ? '' : _cleanJobDescription(jdRaw);

      final dto = ApplicationFormDto(
        id: widget.applicationId,
        company: _companyController.text.trim(),
        position: _positionController.text.trim(),
        status: _status,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        rejectionReason:
            _status == ApplicationStatus.absage && _rejectionReasonController.text.isNotEmpty
                ? _rejectionReasonController.text
                : null,
        appliedDate: _appliedDate,
        followupDate: _followUpDate,
        commuteCar: int.tryParse(_commutCarController.text),
        salaryWish: int.tryParse(_salaryWishController.text),
        jobUrl: _jobUrlController.text.isEmpty ? null : _jobUrlController.text,
        companyUrl:
            _companyUrlController.text.isEmpty ? null : _companyUrlController.text,
        contactName:
            _contactNameController.text.isEmpty ? null : _contactNameController.text,
        contactEmail:
            _contactEmailController.text.isEmpty ? null : _contactEmailController.text,
        contactPhone:
            _contactPhoneController.text.isEmpty ? null : _contactPhoneController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        customFields: customFieldsJson,
        jobDescriptionText: jdClean.isEmpty ? null : jdClean,
      );

      int insertedId;
      if (widget.applicationId != null) {
        insertedId = widget.applicationId!;
        await ref
            .read(applicationNotifierProvider)
            .updateApplication(dto);
      } else {
        insertedId = await ref
            .read(applicationNotifierProvider)
            .addApplication(dto);
      }
      _storedCustomFields = decodeCustomFields(customFieldsJson);

      // Save pending screenshot if it exists
      if (_pendingScreenshotBase64 != null) {
        try {
          final bytes = base64Decode(_pendingScreenshotBase64!.split(',').last);
          final path = await DocumentStorageService.writeBytes(
            bytes,
            'Stellenanzeige_Screenshot.png',
          );
          await ref.read(documentsRepositoryProvider).addDocument(
            insertedId,
            'Stellenanzeige_Screenshot.png',
            path,
            'png',
          );
          _pendingScreenshotBase64 =
              null; // Clear it so it won't be saved again if edited
        } catch (e, st) {
          log('An error occurred: $e', error: e, stackTrace: st);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Bewerbung gespeichert, aber der Screenshot der Stellenanzeige konnte nicht abgelegt werden: $e',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      if (!mounted) return;
      _savedSnapshot = _snapshot();
      context.pop();
    } catch (e, st) {
      log('Speichern fehlgeschlagen: $e', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

/// Hält den Grunddaten-Tab am Leben, damit Formularzustand und FormKey beim
/// Tab-Wechsel erhalten bleiben.
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
