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
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../domain/enums/document_type.dart';
import '../../domain/models/extraction_result.dart';
import 'ml/naive_bayes_classifier.dart';
import 'ml/pretrained_model.dart';
import 'extractors/cover_letter_extractor.dart';
import 'extractors/job_posting_extractor.dart';
import 'extractors/email_response_extractor.dart';

/// Zentraler Service für die intelligente Dokumentenanalyse.
///
/// Orchestriert:
/// 1. Text-Preprocessing
/// 2. Naive-Bayes-Klassifikation (lokales ML)
/// 3. Typ-spezifische Datenextraktion
/// 4. Validierung und Scoring
///
/// Das ML-Modell wird lokal gespeichert und lernt durch User-Korrekturen dazu.
class DocumentIntelligenceService {
  NaiveBayesClassifier? _classifier;
  bool _initialized = false;

  /// Singleton-Instanz
  static final DocumentIntelligenceService _instance =
      DocumentIntelligenceService._internal();

  factory DocumentIntelligenceService() => _instance;

  DocumentIntelligenceService._internal();

  /// Initialisiert den Service und lädt das ML-Modell.
  ///
  /// Versucht zuerst ein lokal gespeichertes (aktualisiertes) Modell zu laden.
  /// Falls keins vorhanden ist, wird das vortrainierte Standardmodell verwendet.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final userModel = await _loadUserModel();
      if (userModel != null) {
        _classifier = userModel;
      } else {
        _classifier = PretrainedModel.create();
      }
    } catch (e) {
      // Fallback auf vortrainiertes Modell bei Fehler
      _classifier = PretrainedModel.create();
    }

    _initialized = true;
  }

  /// Stellt sicher, dass der Service initialisiert ist.
  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  // ── Hauptmethode: Dokument analysieren ──────────────────────────────────────

  /// Analysiert ein Dokument und gibt ein strukturiertes Ergebnis zurück.
  ///
  /// [text] – Der Rohtext des Dokuments (aus PDF, E-Mail, URL, etc.)
  /// [source] – Woher das Dokument stammt
  /// [metadata] – Zusätzliche Kontextinformationen:
  ///   - 'subject': E-Mail-Betreff
  ///   - 'senderEmail': Absender-E-Mail
  ///   - 'url': Quell-URL
  Future<ExtractionResult> analyzeDocument(
    String text, {
    DocumentSource source = DocumentSource.text,
    Map<String, String> metadata = const {},
  }) async {
    await _ensureInitialized();

    // Phase 1: Klassifikation
    final classification = _classifier!.classify(text);
    DocumentType detectedType = classification.type;
    double typeConfidence = classification.confidence;

    // Phase 2: Kontext-basierte Korrektur
    // E-Mails mit RE:/AW: Prefix sind wahrscheinlich Antworten, keine Anschreiben
    if (source == DocumentSource.email) {
      final subject = metadata['subject'] ?? '';
      if (EmailResponseExtractor.isReply(subject)) {
        // Wenn der Classifier "Anschreiben" erkennt, aber es ein Reply ist,
        // könnte es eine Absage/Einladung/Bestätigung sein
        if (detectedType == DocumentType.anschreiben) {
          final status = EmailResponseExtractor.detectStatus(subject, text);
          if (status == 'absage') {
            detectedType = DocumentType.absage;
            typeConfidence = 0.85;
          } else if (status == 'interview') {
            detectedType = DocumentType.einladung;
            typeConfidence = 0.85;
          } else if (status == 'bestaetigung') {
            detectedType = DocumentType.bestaetigung;
            typeConfidence = 0.75;
          }
        }
      }
    }

    // Phase 3: Typ-spezifische Extraktion
    final ExtractedFields fields;
    switch (detectedType) {
      case DocumentType.anschreiben:
        fields = CoverLetterExtractor.extract(text);
        break;
      case DocumentType.stellenanzeige:
        fields = JobPostingExtractor.extractFromHtml(text);
        break;
      case DocumentType.absage:
      case DocumentType.einladung:
      case DocumentType.bestaetigung:
        fields = EmailResponseExtractor.extract(
          text,
          subject: metadata['subject'] ?? '',
          senderEmail: metadata['senderEmail'] ?? '',
        );
        break;
      case DocumentType.lebenslauf:
      case DocumentType.zertifikat:
      case DocumentType.unknown:
        // Generische Extraktion für unbekannte/andere Typen
        fields = _extractGeneric(text);
        break;
    }

    // Phase 4: Warnungen generieren
    final warnings = <ExtractionWarning>[];

    if (typeConfidence < 0.3) {
      warnings.add(
        const ExtractionWarning(
          field: 'documentType',
          message: 'Dokumenttyp konnte nicht sicher erkannt werden. Bitte manuell prüfen.',
          severity: 0.8,
        ),
      );
    } else if (typeConfidence < 0.6) {
      warnings.add(
        const ExtractionWarning(
          field: 'documentType',
          message: 'Dokumenttyp wurde mit mittlerer Sicherheit erkannt.',
          severity: 0.4,
        ),
      );
    }

    // Feld-spezifische Warnungen
    if (fields.company == null) {
      warnings.add(
        const ExtractionWarning(
          field: 'company',
          message: 'Firmenname konnte nicht erkannt werden.',
          severity: 0.6,
        ),
      );
    } else if (fields.company!.confidence < 0.5) {
      warnings.add(
        ExtractionWarning(
          field: 'company',
          message:
              'Firmenname "${fields.company!.value}" wurde mit niedriger Sicherheit erkannt.',
          severity: 0.5,
        ),
      );
    }

    if (fields.position == null &&
        detectedType != DocumentType.absage &&
        detectedType != DocumentType.bestaetigung) {
      warnings.add(
        const ExtractionWarning(
          field: 'position',
          message: 'Stellenbezeichnung konnte nicht erkannt werden.',
          severity: 0.5,
        ),
      );
    }

    return ExtractionResult(
      documentType: detectedType,
      typeConfidence: typeConfidence,
      fields: fields,
      warnings: warnings,
      source: source,
      rawText: text,
    );
  }

  // ── Online-Learning: User korrigiert den Dokumenttyp ───────────────────────

  /// Aktualisiert das ML-Modell mit einer User-Korrektur.
  ///
  /// Wird aufgerufen, wenn der User den automatisch erkannten Dokumenttyp
  /// manuell korrigiert. Das Modell lernt aus dieser Korrektur.
  Future<void> learnFromCorrection(
    String text,
    DocumentType correctType,
  ) async {
    await _ensureInitialized();

    _classifier!.update(text, correctType);
    await _saveUserModel();
  }

  // ── Modell-Persistenz ─────────────────────────────────────────────────────

  /// Pfad zur lokalen Modell-Datei.
  Future<String> get _modelPath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'jobtracker_ml_model.json');
  }

  /// Lädt ein lokal gespeichertes User-Modell.
  Future<NaiveBayesClassifier?> _loadUserModel() async {
    try {
      final path = await _modelPath;
      final file = File(path);

      // Load user customized model if it exists
      if (await file.exists()) {
        final length = await file.length();
        if (length < 1000000) {
          // If it's less than 1MB, it's the old tiny one. Delete it!
          await file.delete();
        } else {
          final jsonStr = await file.readAsString();
          final jsonData = json.decode(jsonStr) as Map<String, dynamic>;
          _initialized = true;
          return NaiveBayesClassifier.fromJson(jsonData);
        }
      }

      // Load massive pretrained dataset from assets
      try {
        final assetStr = await rootBundle.loadString(
          'assets/jobtracker_ml_model.json',
        );
        final jsonData = json.decode(assetStr) as Map<String, dynamic>;
        _initialized = true;
        return NaiveBayesClassifier.fromJson(jsonData);
      } catch (assetErr) {
        return null; // fallback to basic PretrainedModel if asset is missing
      }
    } catch (e) {
      return null;
    }
  }

  /// Speichert das aktuelle Modell lokal.
  Future<void> _saveUserModel() async {
    try {
      final path = await _modelPath;
      final file = File(path);
      final jsonStr = json.encode(_classifier!.toJson());
      await file.writeAsString(jsonStr);
    } catch (e) {
      // Stilles Fehlschlagen – Modell ist nur ein Nice-to-Have
      print('Fehler beim Speichern des ML-Modells: $e');
    }
  }

  /// Setzt das Modell auf den vortrainierten Zustand zurück.
  Future<void> resetModel() async {
    _classifier = PretrainedModel.create();
    _initialized = true;

    try {
      final path = await _modelPath;
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  // ── Generische Extraktion für unbekannte Dokumenttypen ─────────────────────

  ExtractedFields _extractGeneric(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Versuche grundlegende Felder zu extrahieren
    String? foundEmail;
    String? foundPhone;
    String? foundContact;
    String? foundUrl;

    // E-Mail suchen
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) foundEmail = emailMatch.group(0);

    // Telefon suchen
    final phoneRegex = RegExp(r'(\+49|0)[0-9\s/.-]{7,20}');
    final phoneMatch = phoneRegex.firstMatch(text);
    if (phoneMatch != null) foundPhone = phoneMatch.group(0)?.trim();

    // Kontaktperson suchen
    final contactRegex = RegExp(
      r'(Frau|Herr)\s+([A-ZÄÖÜ][a-zA-ZäöüÄÖÜß-]+(\s+[A-ZÄÖÜ][a-zA-ZäöüÄÖÜß-]+)?)',
    );
    final contactMatch = contactRegex.firstMatch(text);
    if (contactMatch != null) foundContact = contactMatch.group(0);

    // URL suchen
    final urlRegex = RegExp(
      r'(https?://)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z]{2,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    for (final match in urlRegex.allMatches(text)) {
      String? url = match.group(0);
      if (url != null && !url.contains('@')) {
        foundUrl = url.replaceAll(RegExp(r'[)\.]+$'), '');
        break;
      }
    }

    return ExtractedFields(
      company: lines.length > 1
          ? FieldResult(
              value: lines[1],
              confidence: 0.3,
              source: 'generic_second_line',
            )
          : null,
      position: lines.isNotEmpty
          ? FieldResult(
              value: lines.first,
              confidence: 0.3,
              source: 'generic_first_line',
            )
          : null,
      contactEmail: foundEmail != null
          ? FieldResult(
              value: foundEmail,
              confidence: 0.7,
              source: 'generic_regex',
            )
          : null,
      contactPhone: foundPhone != null
          ? FieldResult(
              value: foundPhone,
              confidence: 0.65,
              source: 'generic_regex',
            )
          : null,
      contactName: foundContact != null
          ? FieldResult(
              value: foundContact,
              confidence: 0.6,
              source: 'generic_regex',
            )
          : null,
      companyUrl: foundUrl != null
          ? FieldResult(
              value: foundUrl,
              confidence: 0.5,
              source: 'generic_regex',
            )
          : null,
    );
  }
}
