import '../../../l10n/app_localizations.dart';
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:html/parser.dart' as html_parser;
import 'package:file_selector/file_selector.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../data/database/app_database.dart';
import 'email_composer_dialog.dart';
import '../../../core/utils/file_picker_web.dart' if (dart.library.io) 'package:file_selector/file_selector.dart';
import '../../../core/services/document_intelligence_service.dart';
import '../../../domain/enums/document_type.dart';
import '../../../domain/models/extraction_result.dart';
import '../../providers/document_intelligence_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'widgets/web_reader_widget.dart';
import 'widgets/notes_widget.dart';
import 'widgets/contacts_widget.dart';
import 'widgets/documents_widget.dart';
import 'widgets/basic_data_tab.dart';
import 'widgets/emails_contacts_tab.dart';
import 'application_form_state_bundle.dart';
import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/imap_provider.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  final int? applicationId;
  final String? initialUrl;
  final String? initialHtml;
  final String? initialScreenshotBase64;

  const ApplicationFormScreen({
    Key? key,
    this.applicationId,
    this.initialUrl,
    this.initialHtml,
    this.initialScreenshotBase64,
  }) : super(key: key);

  @override
  ConsumerState<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers statt initialValue Ã¢â‚¬â€œ damit Auto-Fill das Widget sofort aktualisiert
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _notesController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  final _commutCarController = TextEditingController();
  final _salaryWishController = TextEditingController();
  final _jobUrlController = TextEditingController(); // Normales Formularfeld fÃƒÂ¼r Job-Link
  final _autoFillUrlController = TextEditingController(); // Nur fÃƒÂ¼r das Magic-Auto-Fill Feld
  final _companyUrlController = TextEditingController(); 
  // Kontakt-Felder
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _addressController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};

  String _status = 'offen';
  DateTime? _appliedDate;
  DateTime? _followUpDate;
  List<String> _activeCustomColumns = [];
  bool _isLoading = false;
  bool _isAutoFilling = false;
  bool _isDragging = false;
  ExtractionResult? _lastExtractionResult;
  
  // Split-View State
  String? _loadedPdfPath;
  String? _loadedWebContent;
  String? _loadedWebUrl;
  String? _activeMarkerField; // Which field is waiting for text selection
  String? _pendingScreenshotBase64;

  @override
  void initState() {
    super.initState();
    _pendingScreenshotBase64 = widget.initialScreenshotBase64;
    _loadCustomColumns();
    if (widget.applicationId != null) {
      _loadApplication();
    } else {
      _isLoading = false;
      if (widget.initialUrl != null || widget.initialHtml != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _autoFillFromInjectedData(widget.initialUrl, widget.initialHtml);
        });
      }
    }
  }

  @override
  void dispose() {
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
    for (final c in _customFieldControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _loadCustomColumns() async {
    final dao = ref.read(databaseProvider).settingsDao;
    final colsSetting = await dao.getSettingByKey('customColumns');
    if (colsSetting != null && colsSetting.value.isNotEmpty) {
      final cols = colsSetting.value
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      setState(() {
        _activeCustomColumns = cols;
        for (final col in cols) {
          _customFieldControllers.putIfAbsent(col, () => TextEditingController());
        }
      });
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
        _applyExtractionResult(result);
      }
      setState(() => _isAutoFilling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('? Daten direkt aus dem Browser Ã¼bernommen!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isAutoFilling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('? Fehler beim Auslesen: '), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);
    final app = await ref.read(applicationsRepositoryProvider).getApplicationById(widget.applicationId!);
    setState(() {
      _companyController.text = app.company;
      _positionController.text = app.position;
      _status = app.status;
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

      if (app.customFields != null && app.customFields!.isNotEmpty) {
        try {
          final decoded = json.decode(app.customFields!) as Map<String, dynamic>;
          for (final entry in decoded.entries) {
            _customFieldControllers[entry.key]?.text = entry.value.toString();
          }
        } catch (_) {}
      }
      _isLoading = false;
    });
  }

  Future<void> _autoFillFromUrl() async {
    var url = _autoFillUrlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte erst eine URL eingeben.')),
      );
      return;
    }
    setState(() {
      _isAutoFilling = true;
      _loadedPdfPath = null;
      _loadedWebUrl = url;
      _activeMarkerField = null;
    });

    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 10));
      request.headers.set('User-Agent',
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
      request.headers.set('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
      request.headers.set('Accept-Language', 'de-DE,de;q=0.9,en-US;q=0.8');
      final response = await request.close().timeout(const Duration(seconds: 10));
      final bytes = await response.expand((chunk) => chunk).toList().timeout(const Duration(seconds: 10));
      final body = utf8.decode(bytes, allowMalformed: true);
      client.close();

      // Check for common captchas (e.g. Cloudflare, reCAPTCHA, Jobcenter blocking)
      if (body.contains('Cloudflare') && body.contains('captcha-bypass') || 
          body.toLowerCase().contains('you have been blocked') ||
          (url.contains('arbeitsagentur.de') && body.contains('SicherheitsprÃƒÂ¼fung'))) {
        setState(() => _isAutoFilling = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Ã¢Å¡Â Ã¯Â¸Â Captcha / Blockierung erkannt'),
              content: const Text(
                  'Die Webseite blockiert das automatische Auslesen (oft bei Jobcenter / Arbeitsagentur oder Stepstone).\n\n'
                  'Bitte ÃƒÂ¶ffne die Seite im Browser, lÃƒÂ¶se das Captcha, drÃƒÂ¼cke Strg+P (Drucken) und speichere die Seite als PDF.\n'
                  'Lade diese PDF dann hier hoch, um die Daten inkl. Kontaktdaten auszulesen.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK, verstanden'),
                )
              ],
            ),
          );
        }
        return;
      }
      
      // Save HTML for reader mode
      setState(() => _loadedWebContent = body);

      final service = DocumentIntelligenceService();
      final result = await service.analyzeDocument(
        body,
        source: DocumentSource.url,
      );

      // Force job URL
      _jobUrlController.text = url;
      
      _applyExtractionResult(result);
      setState(() => _isAutoFilling = false);

      if (mounted) {
        if (result.fields.position == null && result.fields.company == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ã¢Å¡Â Ã¯Â¸Â Keine Daten gefunden Ã¢â‚¬â€œ diese Seite nutzt evtl. clientseitiges Rendering. Lade die Seite als PDF herunter und probiere den PDF-Upload.'),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ã¢Å“â€¦ Daten aus Webseite extrahiert'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isAutoFilling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ã¢Â Å’ Fehler beim Laden der URL: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleDroppedFiles(DropDoneDetails details) async {
    setState(() => _isDragging = false);
    if (details.files.isEmpty) return;
    
    final xfile = details.files.first;
    if (!xfile.name.toLowerCase().endsWith('.pdf')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte nur PDF-Dateien ablegen.')));
      return;
    }

    try {
      final bytes = await xfile.readAsBytes();
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
        text = textBuf.toString().replaceAll('\u00A0', ' ');
        doc.dispose();
      } catch (e) {
        throw Exception('Fehler bei der PDF-Textextraktion mit pdfrx: $e');
      }

      final service = DocumentIntelligenceService();
      final result = await service.analyzeDocument(
        text,
        source: DocumentSource.pdf,
      );

      _applyExtractionResult(result);

    } catch (e) {
      setState(() => _isAutoFilling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim PDF auslesen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _autoFillFromPdf() async {
    try {
      final typeGroup = const XTypeGroup(label: 'PDF', extensions: ['pdf']);
      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file == null) return;
      
      final bytes = await file.readAsBytes();
      
      setState(() {
        _isAutoFilling = true;
        _loadedPdfPath = file.path;
        _loadedWebContent = null;
        _loadedWebUrl = null;
        _activeMarkerField = null;
      });
      
      // Text extrahieren mit pdfrx (rein Dart/Flutter, MIT-Lizenz)
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
        text = textBuf.toString().replaceAll('\u00A0', ' ');
        doc.dispose();
      } catch (e) {
        throw Exception('Fehler bei der PDF-Textextraktion mit pdfrx: $e');
      }

      // Ã¢â€ â‚¬Ã¢â€ â‚¬ Neuer intelligenter Service Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬Ã¢â€ â‚¬
      final service = DocumentIntelligenceService();
      final result = await service.analyzeDocument(
        text,
        source: DocumentSource.pdf,
      );

      _applyExtractionResult(result);

    } catch (e) {
      setState(() => _isAutoFilling = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ã¢ÂÅ’ Fehler beim PDF auslesen: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Wendet ein ExtractionResult auf die Formularfelder an.
  ///
  /// Wird von _autoFillFromPdf und _autoFillFromUrl gemeinsam genutzt.
  /// Zeigt Confidence-basierte Warnungen an.
  void _applyExtractionResult(ExtractionResult result) {
    final fields = result.fields;

    setState(() {
      _lastExtractionResult = result;
      if (fields.position != null && fields.position!.value.length < 100) {
        _positionController.text = fields.position!.value;
      }
      if (fields.company != null && fields.company!.value.length < 100) {
        _companyController.text = fields.company!.value;
      }
      if (fields.applicationDate != null) {
        _appliedDate = fields.applicationDate!.value;
      }
      if (fields.contactEmail != null) {
        _contactEmailController.text = fields.contactEmail!.value;
      }
      if (fields.contactPhone != null) {
        _contactPhoneController.text = fields.contactPhone!.value;
      }
      if (fields.companyUrl != null) {
        _companyUrlController.text = fields.companyUrl!.value;
      }
      if (fields.contactName != null) {
        _contactNameController.text = fields.contactName!.value;
      }
      if (fields.address != null) {
        _addressController.text = fields.address!.value;
      }
      if (fields.notes != null) {
        _notesController.text = fields.notes!.value;
      }
      if (fields.applicationStatus != null) {
        _status = fields.applicationStatus!.value;
      }
      _isAutoFilling = false;
    });

    if (!mounted) return;

    // Ã¢â€â‚¬Ã¢â€â‚¬ Confidence-basiertes UI-Feedback Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    final typeLabel = result.documentType.label;
    final confidence = (result.typeConfidence * 100).toInt();
    final fieldCount = result.fields.filledFieldCount;

    if (result.needsReview) {
      // Unter 30% Ã¢â‚¬â€œ unsicher
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ã¢Å¡Â Ã¯Â¸Â $typeLabel erkannt ($confidence% Sicherheit). $fieldCount Felder ausgefÃƒÂ¼llt Ã¢â‚¬â€œ bitte manuell prÃƒÂ¼fen!',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    } else if (!result.isReliable) {
      // 30-60% Ã¢â‚¬â€œ mittlere Sicherheit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ã°Å¸Å¸Â¡ $typeLabel erkannt ($confidence%). $fieldCount Felder ausgefÃƒÂ¼llt Ã¢â‚¬â€œ einige Felder prÃƒÂ¼fen.',
          ),
          backgroundColor: Colors.amber.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      // ÃƒÅ“ber 60% Ã¢â‚¬â€œ sicher
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ã¢Å“â€¦ $typeLabel erkannt ($confidence%). $fieldCount Felder automatisch ausgefÃƒÂ¼llt.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleAiFeedbackCorrection(ExtractionResult result, DocumentType newType) {
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
        content: Text('KI hat gelernt: Neues Muster fÃƒÂ¼r "${newType.name}" gespeichert!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bewerbung lÃƒÂ¶schen?'),
        content: const Text('Diese Bewerbung wirklich lÃƒÂ¶schen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('LÃƒÂ¶schen',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final app = await ref
          .read(applicationsRepositoryProvider)
          .getApplicationById(widget.applicationId!);
      await ref
          .read(applicationNotifierProvider)
          .deleteApplication(app);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.applicationId != null;
    final tabCount = isEditing ? 4 : 1;

    return DefaultTabController(
      length: tabCount,
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
                    context.push('/applications/${widget.applicationId}/editor');
                  },
                ),
              ),
            if (isEditing)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FilledButton.icon(
                  onPressed: () async {
                    final app = await ref.read(databaseProvider).applicationsDao.getApplicationById(widget.applicationId!);
                    if (app != null && context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => EmailComposerDialog(application: app),
                      );
                    }
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Bewerbung senden'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C6AF7),
                  ),
                ),
              ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: AppLocalizations.of(context)!.formTabBasic),
              if (isEditing) Tab(text: AppLocalizations.of(context)!.formTabEmails),
              if (isEditing) Tab(text: AppLocalizations.of(context)!.formTabDocs),
              if (isEditing) Tab(text: AppLocalizations.of(context)!.formTabNotes),
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
                    children: [
                      _buildSplitView(context, isEditing),
                      if (isEditing) EmailsAndContactsTab(applicationId: widget.applicationId!),
                      if (isEditing) DocumentsWidget(applicationId: widget.applicationId!),
                      if (isEditing) NotesWidget(applicationId: widget.applicationId!),
                    ],
                  ),
              if (_isDragging)
                Container(
                  color: Colors.blue.withOpacity(0.2),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 64, color: Colors.blue),
                        SizedBox(height: 16),
                        Text('PDF hier ablegen zum Auslesen', style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasDocumentPreview => _loadedPdfPath != null || _loadedWebContent != null;

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
      customFieldControllers: _customFieldControllers,
      status: _status,
      appliedDate: _appliedDate,
      followUpDate: _followUpDate,
      activeCustomColumns: _activeCustomColumns,
      isAutoFilling: _isAutoFilling,
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
        Expanded(
          child: _buildDocumentPreview(context),
        ),
      ],
    );
  }

  Widget _buildDocumentPreview(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loadedPdfPath != null) {
      return Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: colorScheme.outlineVariant, width: 1)),
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
                  Icon(Icons.picture_as_pdf, size: 16, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text('PDF-Vorschau', style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                  const Spacer(),
                  if (_activeMarkerField != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '🎯 Markiere Text für: $_activeMarkerField',
                        style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
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
                        if (selection != null && selection.hasSelectedText) {
                          final selectedText = await selection.getSelectedText();
                          if (selectedText.isNotEmpty && _activeMarkerField != null) {
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

    setState(() {
      switch (field) {
        case 'Firma':
          _companyController.text = text;
          break;
        case 'Position':
          _positionController.text = text;
          break;
        case 'Adresse':
          _addressController.text = text;
          break;
        case 'Ansprechpartner':
          _contactNameController.text = text;
          break;
        case 'E-Mail':
          _contactEmailController.text = text;
          break;
        case 'Telefon':
          _contactPhoneController.text = text;
          break;
        case 'Firmen-URL':
          _companyUrlController.text = text;
          break;
        case 'Job-URL':
          _jobUrlController.text = text;
          break;
      }
      _activeMarkerField = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ã¢Å“â€¦ "$field" wurde ÃƒÂ¼bernommen.'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Custom fields als JSON
    String? customFieldsJson;
    if (_customFieldControllers.isNotEmpty) {
      final map = <String, String>{};
      for (final entry in _customFieldControllers.entries) {
        if (entry.value.text.isNotEmpty) {
          map[entry.key] = entry.value.text;
        }
      }
      if (map.isNotEmpty) customFieldsJson = json.encode(map);
    }

    final companion = ApplicationsCompanion(
      company: drift.Value(_companyController.text.trim()),
      position: drift.Value(_positionController.text.trim()),
      status: drift.Value(_status),
      notes: drift.Value(_notesController.text.isEmpty ? null : _notesController.text),
      rejectionReason: drift.Value(
          _status == 'absage' && _rejectionReasonController.text.isNotEmpty
              ? _rejectionReasonController.text
              : null),
      appliedDate: drift.Value(_appliedDate),
      followupDate: drift.Value(_followUpDate),
      commuteCar: drift.Value(int.tryParse(_commutCarController.text)),
      salaryWish: drift.Value(int.tryParse(_salaryWishController.text)),
      jobUrl: drift.Value(_jobUrlController.text.isEmpty ? null : _jobUrlController.text),
      companyUrl: drift.Value(_companyUrlController.text.isEmpty ? null : _companyUrlController.text),
      contactName: drift.Value(_contactNameController.text.isEmpty ? null : _contactNameController.text),
      contactEmail: drift.Value(_contactEmailController.text.isEmpty ? null : _contactEmailController.text),
      contactPhone: drift.Value(_contactPhoneController.text.isEmpty ? null : _contactPhoneController.text),
      address: drift.Value(_addressController.text.isEmpty ? null : _addressController.text),
      customFields: drift.Value(customFieldsJson),
    );

    int insertedId;
    if (widget.applicationId != null) {
      insertedId = widget.applicationId!;
      await ref.read(applicationNotifierProvider).updateApplication(
            companion.copyWith(id: drift.Value(insertedId)));
    } else {
      insertedId = await ref.read(applicationNotifierProvider).addApplication(companion);
    }

    // Save pending screenshot if it exists
    if (_pendingScreenshotBase64 != null) {
      try {
        final bytes = base64Decode(_pendingScreenshotBase64!.split(',').last);
        final dir = await getApplicationDocumentsDirectory();
        final path = p.join(dir.path, 'career_center_docs', 'screenshot_$insertedId.png');
        final file = File(path);
        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }
        await file.writeAsBytes(bytes);

        // Add to database
        await ref.read(databaseProvider).documentsDao.insertDocument(
          DocumentsCompanion(
            applicationId: drift.Value(insertedId),
            fileName: drift.Value('Stellenanzeige_Screenshot.png'),
            filePath: drift.Value(path),
            fileType: drift.Value('png'),
            uploadedAt: drift.Value(DateTime.now()),
          )
        );
        _pendingScreenshotBase64 = null; // Clear it so it won't be saved again if edited
      } catch (e) {
        debugPrint('Failed to save screenshot: $e');
      }
    }

    if (mounted) context.pop();
  }
}







