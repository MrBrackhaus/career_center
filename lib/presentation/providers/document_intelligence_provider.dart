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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/document_intelligence_service.dart';
import '../../domain/enums/document_type.dart';
import '../../domain/models/extraction_result.dart';

/// State für die Dokumentenanalyse.
class DocumentAnalysisState {
  final ExtractionResult? lastResult;
  final bool isAnalyzing;
  final String? errorMessage;

  const DocumentAnalysisState({
    this.lastResult,
    this.isAnalyzing = false,
    this.errorMessage,
  });

  DocumentAnalysisState copyWith({
    ExtractionResult? lastResult,
    bool? isAnalyzing,
    String? errorMessage,
  }) {
    return DocumentAnalysisState(
      lastResult: lastResult ?? this.lastResult,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier für die Dokumentenanalyse mit ML-Integration.
class DocumentIntelligenceNotifier extends Notifier<DocumentAnalysisState> {
  @override
  DocumentAnalysisState build() => const DocumentAnalysisState();

  /// Analysiert ein Dokument (PDF-Text, E-Mail-Body, etc.).
  Future<ExtractionResult?> analyzeDocument(
    String text, {
    DocumentSource source = DocumentSource.text,
    Map<String, String> metadata = const {},
  }) async {
    state = state.copyWith(isAnalyzing: true, errorMessage: null);

    try {
      final result = await ref
          .read(documentIntelligenceServiceProvider)
          .analyzeDocument(text, source: source, metadata: metadata);
      state = state.copyWith(lastResult: result, isAnalyzing: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Fehler bei der Analyse: $e',
      );
      return null;
    }
  }

  /// Sendet eine User-Korrektur an das ML-Modell.
  Future<void> correctDocumentType(DocumentType correctType) async {
    final lastResult = state.lastResult;
    if (lastResult == null || lastResult.rawText.isEmpty) return;

    try {
      await ref
          .read(documentIntelligenceServiceProvider)
          .learnFromCorrection(lastResult.rawText, correctType);
    } catch (e) {
      // Stilles Fehlschlagen – Learning ist optional
    }
  }

  /// Setzt das ML-Modell auf den Ausgangszustand zurück.
  Future<void> resetModel() async {
    await ref.read(documentIntelligenceServiceProvider).resetModel();
  }
}

/// Provider für den DocumentIntelligenceService (Singleton).
final documentIntelligenceServiceProvider =
    Provider<DocumentIntelligenceService>((ref) {
      return DocumentIntelligenceService();
    });

/// Provider für den DocumentIntelligenceNotifier.
final documentIntelligenceProvider =
    NotifierProvider<DocumentIntelligenceNotifier, DocumentAnalysisState>(
      DocumentIntelligenceNotifier.new,
    );
