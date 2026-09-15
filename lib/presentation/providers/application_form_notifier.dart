import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' show log;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../core/services/document_intelligence_service.dart';
import '../../../core/services/headless_webview_service.dart';
import '../../../core/services/extractors/job_posting_extractor.dart';
import '../../../domain/enums/document_type.dart';
import '../../../domain/models/extraction_result.dart';

class CaptchaDetectedException implements Exception {
  final String message;
  CaptchaDetectedException(this.message);
}

class NoDataFoundException implements Exception {
  final String message;
  NoDataFoundException(this.message);
}

class ExtractionState {
  final bool isLoading;
  final String? error;
  final String? loadedWebContent;
  final ExtractionResult? result;

  ExtractionState({
    this.isLoading = false,
    this.error,
    this.loadedWebContent,
    this.result,
  });

  ExtractionState copyWith({
    bool? isLoading,
    String? error,
    String? loadedWebContent,
    ExtractionResult? result,
  }) {
    return ExtractionState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null
      loadedWebContent: loadedWebContent ?? this.loadedWebContent,
      result: result ?? this.result,
    );
  }
}

class ApplicationFormNotifier extends Notifier<ExtractionState> {
  @override
  ExtractionState build() => ExtractionState();



  DocumentIntelligenceService get _intelligenceService => DocumentIntelligenceService();

  Future<void> extractFromUrl(String url) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.tryParse(url);
      if (uri == null) throw Exception('Ungültige URL.');

      // ── Stufe 1: Normaler HTTP-Abruf ──────────────────────────────────────
      String body;
      try {
        body = await _fetchUrl(url);
      } on CaptchaDetectedException {
        // ── Stufe 2: Headless WebView Fallback ──────────────────────────────
        log('Captcha erkannt, versuche Headless WebView...', name: 'AutoFill');
        final rendered = await HeadlessWebViewService().renderPage(url);
        if (rendered == null || rendered.isEmpty) {
          throw CaptchaDetectedException('Captcha/Blocking detected – auch Headless WebView gescheitert');
        }
        body = rendered;
      }

      final result = await _intelligenceService.analyzeDocument(body, source: DocumentSource.url);

      // ── Stufe 2b: Falls keine Daten → Headless WebView Fallback ───────────
      if (result.fields.position == null && result.fields.company == null) {
        log('Keine Daten per HTTP, versuche Headless WebView...', name: 'AutoFill');
        final rendered = await HeadlessWebViewService().renderPage(url);
        if (rendered != null && rendered.isNotEmpty) {
          final retryResult = await _intelligenceService.analyzeDocument(rendered, source: DocumentSource.url);
          if (retryResult.fields.position != null || retryResult.fields.company != null) {
            // Headless hat bessere Daten → verwende diese
            state = state.copyWith(isLoading: false, loadedWebContent: rendered, result: retryResult);
            return;
          }
        }
        throw NoDataFoundException('Keine Daten gefunden.');
      }

      // ── Feature 1: Externe Links folgen bei fehlenden Kontaktdaten ────────
      ExtractionResult finalResult = result;
      if (result.fields.contactEmail == null &&
          result.fields.contactPhone == null &&
          result.fields.contactName == null) {
        final externalLinks = JobPostingExtractor.findExternalApplicationLinks(body);
        if (externalLinks.isNotEmpty) {
          log('Kontaktdaten fehlen – folge externem Link: ${externalLinks.first}', name: 'AutoFill');
          try {
            final extBody = await _fetchUrl(externalLinks.first);
            final extResult = await _intelligenceService.analyzeDocument(extBody, source: DocumentSource.url);
            finalResult = _mergeResults(result, extResult);
          } catch (e) {
            log('Externer Link fehlgeschlagen: $e', name: 'AutoFill');
            // Ignorieren – Originalergebnis bleibt bestehen
          }
        }
      }

      state = state.copyWith(isLoading: false, loadedWebContent: body, result: finalResult);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  /// Lädt eine URL per HttpClient und gibt den Body als String zurück.
  /// Wirft [CaptchaDetectedException] bei erkannter Blockierung.
  Future<String> _fetchUrl(String url) async {
    final uri = Uri.parse(url);
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 10));
      request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
      request.headers.set('Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
      request.headers.set('Accept-Language', 'de-DE,de;q=0.9,en-US;q=0.8');

      final response = await request.close().timeout(const Duration(seconds: 10));
      final bytes = await response.expand((chunk) => chunk).toList().timeout(const Duration(seconds: 10));
      final body = utf8.decode(bytes, allowMalformed: true);

      if ((body.contains('Cloudflare') && body.contains('captcha-bypass')) ||
          body.toLowerCase().contains('you have been blocked') ||
          (url.contains('arbeitsagentur.de') && body.contains('Sicherheitsprüfung'))) {
        throw CaptchaDetectedException('Captcha/Blocking detected');
      }

      return body;
    } finally {
      client.close();
    }
  }

  /// Merged zwei ExtractionResults: Originalfelder haben Vorrang,
  /// leere Felder werden aus dem externen Ergebnis aufgefüllt.
  ExtractionResult _mergeResults(ExtractionResult original, ExtractionResult external) {
    final o = original.fields;
    final e = external.fields;

    return ExtractionResult(
      documentType: original.documentType,
      typeConfidence: original.typeConfidence,
      fields: ExtractedFields(
        company: o.company ?? e.company,
        position: o.position ?? e.position,
        contactName: o.contactName ?? e.contactName,
        contactEmail: o.contactEmail ?? e.contactEmail,
        contactPhone: o.contactPhone ?? e.contactPhone,
        address: o.address ?? e.address,
        applicationDate: o.applicationDate ?? e.applicationDate,
        applicationStatus: o.applicationStatus ?? e.applicationStatus,
        companyUrl: o.companyUrl ?? e.companyUrl,
        jobUrl: o.jobUrl ?? e.jobUrl,
        salaryInfo: o.salaryInfo ?? e.salaryInfo,
        notes: o.notes ?? e.notes,
      ),
      warnings: [...original.warnings, ...external.warnings],
      source: original.source,
      rawText: original.rawText,
    );
  }

  Future<void> extractFromPdfBytes(List<int> bytes) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      String text = '';
      final doc = await PdfDocument.openData(Uint8List.fromList(bytes));
      final StringBuffer textBuf = StringBuffer();
      for (var page in doc.pages) {
        final pageText = await page.loadText();
        if (pageText != null) {
          textBuf.writeln(pageText.fullText);
        }
      }
      text = textBuf.toString().replaceAll('\u00A0', ' ');
      doc.dispose();

      final result = await _intelligenceService.analyzeDocument(text, source: DocumentSource.pdf);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final applicationFormNotifierProvider = NotifierProvider<ApplicationFormNotifier, ExtractionState>(ApplicationFormNotifier.new);/*
*/
