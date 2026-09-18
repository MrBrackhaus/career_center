import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/application_entity.dart';
import 'email_response_extractor.dart';

class MagicClipboardResult {
  final ApplicationEntity? matchedApplication;
  final String? detectedStatus;
  final String? extractedCompany;
  final String? extractedPosition;
  final String? originalText;

  MagicClipboardResult({
    this.matchedApplication,
    this.detectedStatus,
    this.extractedCompany,
    this.extractedPosition,
    this.originalText,
  });
}

class MagicClipboardService {
  Future<MagicClipboardResult?> analyzeClipboard(List<ApplicationEntity> existingApps) async {
    final clipboardData = await Clipboard.getData('text/plain');
    final text = clipboardData?.text;
    if (text == null || text.trim().isEmpty) return null;
    return analyzeText(text, existingApps);
  }

  MagicClipboardResult? analyzeText(String text, List<ApplicationEntity> existingApps) {
    if (text.trim().isEmpty) return null;
    final lowerText = text.toLowerCase();

    // 1. Status erkennen (Non-AI Fallback)
    String? status = EmailResponseExtractor.detectStatus('Bewerbung', text);
    
    // Fallback if status is still null
    if (status == null) {
      if (lowerText.contains('leider') && (lowerText.contains('absage') || lowerText.contains('entschieden') || lowerText.contains('anderweitig'))) {
        status = 'absage';
      } else if ((lowerText.contains('einladung') || lowerText.contains('laden')) && (lowerText.contains('interview') || lowerText.contains('kennenlernen') || lowerText.contains('gespräch'))) {
        status = 'interview';
      }
    }
    
    // 2. Firma/Position suchen
    // Wir gleichen den Text mit den bestehenden Bewerbungen ab.
    ApplicationEntity? bestMatch;
    int highestScore = 0;

    for (final app in existingApps) {
      int score = 0;
      final companyParts = app.company.toLowerCase().split(' ');
      for (final part in companyParts) {
        if (part.length > 3 && lowerText.contains(part)) {
          score += 2;
        }
      }
      
      final positionParts = app.position.toLowerCase().split(' ');
      for (final part in positionParts) {
        if (part.length > 4 && lowerText.contains(part)) {
          score += 1;
        }
      }

      if (score > highestScore) {
        highestScore = score;
        bestMatch = app;
      }
    }

    if (bestMatch == null && status == null) {
      return null;
    }

    return MagicClipboardResult(
      matchedApplication: highestScore >= 2 ? bestMatch : null,
      detectedStatus: status,
      extractedCompany: null, 
      extractedPosition: null,
      originalText: text,
    );
  }
}

final magicClipboardProvider = Provider((ref) => MagicClipboardService());
