import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/application_entity.dart';
import '../../../domain/enums/application_status.dart';
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
    
    // Auf kanonische Board-Status abbilden (z.B. 'bestaetigung' -> 'versendet').
    if (status != null) status = normalizeApplicationStatus(status);

    // 2. Firma/Position suchen
    // Wir gleichen den Text mit den bestehenden Bewerbungen ab. Ein Treffer
    // erfordert, dass entweder der vollständige Firmenname (ohne
    // Rechtsform-Zusätze wie "GmbH") oder die E-Mail-Domain des Kontakts im
    // Text vorkommt. Die Position dient nur als Zusatzpunkt. Bei Gleichstand
    // wird keine Bewerbung ausgewählt.
    final bestMatch = findBestMatchingApplication(text, existingApps);

    if (bestMatch == null && status == null) {
      return null;
    }

    return MagicClipboardResult(
      matchedApplication: bestMatch,
      detectedStatus: status,
      extractedCompany: null, 
      extractedPosition: null,
      originalText: text,
    );
  }
}

/// Rechtsform- und Füll-Tokens, die beim Firmennamen-Abgleich ignoriert werden.
const Set<String> _legalFormTokens = {
  'gmbh', 'mbh', 'ag', 'kg', 'kgaa', 'se', 'co', 'ug', 'ohg', 'gbr', 'ev',
  'eg', 'inc', 'ltd', 'llc', 'plc', 'corp', 'sa', 'sarl', 'bv', 'nv', 'srl',
  'spa', 'ab', 'as', 'oy', 'haftungsbeschränkt', 'haftungsbeschraenkt',
  'mwd', 'wmd', 'mdw', 'm', 'w', 'd', 'und',
};

/// Generische Mail-Anbieter, deren Domain keinen Firmenbezug hat.
const Set<String> _genericMailDomains = {
  'gmail.com', 'googlemail.com', 'gmx.de', 'gmx.net', 'gmx.at', 'gmx.ch',
  'web.de', 'outlook.com', 'outlook.de', 'hotmail.com', 'hotmail.de',
  'live.com', 'live.de', 'yahoo.com', 'yahoo.de', 'icloud.com', 'me.com',
  't-online.de', 'freenet.de', 'posteo.de', 'mailbox.org', 'aol.com',
  'protonmail.com', 'proton.me',
};

/// Normalisiert Text für den Abgleich: Kleinbuchstaben, alle Zeichen außer
/// Buchstaben/Ziffern werden zu Leerzeichen, Mehrfach-Leerzeichen entfernt.
String _normalizeForMatch(String input) {
  final lower = input.toLowerCase().replaceAll(RegExp(r'\(m/w/d\)|\(w/m/d\)|\(m/w/x\)'), ' ');
  final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9äöüß]+'), ' ');
  return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Liefert den "Kern" eines Firmennamens ohne Rechtsform-Zusätze,
/// z.B. "NCSolution GmbH & Co. KG" -> "ncsolution".
String companyCoreName(String company) {
  final tokens = _normalizeForMatch(company)
      .split(' ')
      .where((t) => t.isNotEmpty && !_legalFormTokens.contains(t))
      .toList();
  return tokens.join(' ');
}

/// Extrahiert die (nicht-generische) Domain einer E-Mail-Adresse.
String? companyMailDomain(String? email) {
  if (email == null) return null;
  final at = email.lastIndexOf('@');
  if (at < 0 || at == email.length - 1) return null;
  final domain = email.substring(at + 1).trim().toLowerCase();
  if (!domain.contains('.') || _genericMailDomains.contains(domain)) {
    return null;
  }
  return domain;
}

/// Sucht die am besten passende Bewerbung für [text].
///
/// Voraussetzung für einen Treffer ist ein vollständiger Firmennamen-Treffer
/// (ohne Rechtsform) oder ein Treffer der Kontakt-Mail-Domain. Die Position
/// erhöht nur die Punktzahl. Bei Gleichstand wird `null` zurückgegeben.
ApplicationEntity? findBestMatchingApplication(
  String text,
  List<ApplicationEntity> apps,
) {
  final normalizedText = ' ${_normalizeForMatch(text)} ';
  final lowerText = text.toLowerCase();

  ApplicationEntity? best;
  var bestScore = 0;
  var tie = false;

  for (final app in apps) {
    var score = 0;
    var anchored = false;

    final core = companyCoreName(app.company);
    if (core.length >= 3 && normalizedText.contains(' $core ')) {
      score += 10;
      anchored = true;
    }

    final domain = companyMailDomain(app.contactEmail);
    if (domain != null &&
        RegExp('(^|[^a-z0-9.-])(?:[a-z0-9-]+\\.)*${RegExp.escape(domain)}(\$|[^a-z0-9-])')
            .hasMatch(lowerText)) {
      score += 10;
      anchored = true;
    }

    if (!anchored) continue;

    final position = _normalizeForMatch(app.position);
    if (position.length >= 3 && normalizedText.contains(' $position ')) {
      score += 3;
    } else {
      for (final part in position.split(' ')) {
        if (part.length > 4 && normalizedText.contains(' $part ')) {
          score += 1;
        }
      }
    }

    if (score > bestScore) {
      bestScore = score;
      best = app;
      tie = false;
    } else if (score == bestScore) {
      tie = true;
    }
  }

  return tie ? null : best;
}

final magicClipboardProvider = Provider((ref) => MagicClipboardService());
