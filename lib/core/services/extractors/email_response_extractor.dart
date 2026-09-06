import '../../../domain/models/extraction_result.dart';

/// Extrahiert Daten aus E-Mail-Antworten (Absagen, Einladungen, Bestätigungen).
///
/// Portiert und verbessert die Logik aus `ImapService`:
/// - Status-Erkennung (Absage, Interview, Bestätigung)
/// - Positions-Extraktion aus Betreff/Body
/// - Firmenname aus Body oder E-Mail-Domain
/// - Kontaktperson aus Anrede
class EmailResponseExtractor {
  // ── Öffentliche API ────────────────────────────────────────────────────────

  /// Extrahiert Daten aus einer E-Mail-Antwort.
  ///
  /// [body] ist der E-Mail-Body-Text.
  /// [subject] ist der E-Mail-Betreff.
  /// [senderEmail] ist die Absender-E-Mail (für Domain-basierte Firmenextraktion).
  static ExtractedFields extract(
    String body, {
    String subject = '',
    String senderEmail = '',
  }) {
    final cleanSubject = stripReplyPrefix(subject);

    // ── Position ─────────────────────────────────────────────────────────────
    FieldResult<String>? foundPosition;
    final posRegex1 = RegExp(r'[Bb]ewerbung\s+als\s+(.+?)(?:\s*[-–—]|\s*\(m|$)');
    final posRegex2 = RegExp(r'[Bb]ewerbung\s*[-–—]\s*(.+?)(?:\s*\(m|$)');

    final subjMatch = posRegex1.firstMatch(cleanSubject) ?? posRegex2.firstMatch(cleanSubject);
    if (subjMatch != null) {
      final pos = subjMatch.group(1)?.trim() ?? '';
      if (pos.isNotEmpty) {
        foundPosition = FieldResult(
          value: pos,
          confidence: 0.8,
          source: 'subject_regex',
        );
      }
    } else {
      final bodyMatch = posRegex1.firstMatch(body) ?? posRegex2.firstMatch(body);
      if (bodyMatch != null) {
        final pos = bodyMatch.group(1)?.trim() ?? '';
        if (pos.isNotEmpty) {
          foundPosition = FieldResult(
            value: pos,
            confidence: 0.7,
            source: 'body_regex',
          );
        }
      }
    }

    // ── Firma ────────────────────────────────────────────────────────────────
    FieldResult<String>? foundCompany;
    final companyRegex = RegExp(
      r'bei\s+(?:der\s+|dem\s+|Ihrem\s+Unternehmen\s+|Ihnen\s+als\s+)?([\w\s\-&.,ÄÖÜäöüß]+?(?:GmbH(?:\s*&\s*Co\.\s*KG)?|AG|KG|SE|mbH|e\.V\.|GbR|OHG))',
    );
    final companyMatch = companyRegex.firstMatch(body);
    if (companyMatch != null) {
      final name = companyMatch.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
      if (name.isNotEmpty && name.length < 60) {
        foundCompany = FieldResult(
          value: name,
          confidence: 0.85,
          source: 'body_legal_form',
        );
      }
    }
    if (foundCompany == null && senderEmail.isNotEmpty) {
      final domainCompany = extractCompanyFromDomain(senderEmail);
      if (domainCompany.isNotEmpty) {
        foundCompany = FieldResult(
          value: domainCompany,
          confidence: 0.6,
          source: 'email_domain',
        );
      }
    }

    // ── Kontaktperson ────────────────────────────────────────────────────────
    FieldResult<String>? foundContact;
    final contactRegex = RegExp(
      r'Sehr\s+geehrte[r]?\s+(Frau|Herr)\s+([A-ZÄÖÜ][a-zäöüß]+(?:\s+[A-ZÄÖÜ][a-zäöüß]+)*)',
    );
    final contactMatch = contactRegex.firstMatch(body);
    if (contactMatch != null) {
      foundContact = FieldResult(
        value: '${contactMatch.group(1)} ${contactMatch.group(2)}'.trim(),
        confidence: 0.9,
        source: 'salutation',
      );
    }

    // ── Status ───────────────────────────────────────────────────────────────
    FieldResult<String>? foundStatus;
    final detectedStatus = detectStatus(subject, body);
    if (detectedStatus != null) {
      foundStatus = FieldResult(
        value: detectedStatus,
        confidence: _statusConfidence(body, detectedStatus),
        source: 'status_detection',
      );
    }

    return ExtractedFields(
      position: foundPosition,
      company: foundCompany,
      contactName: foundContact,
      applicationStatus: foundStatus,
    );
  }

  // ── Status-Erkennung ───────────────────────────────────────────────────────

  /// Erkennt den Bewerbungsstatus aus einer E-Mail.
  ///
  /// Returns: 'absage', 'interview', 'versendet', 'bestaetigung' oder null.
  static String? detectStatus(String subject, String body) {
    final lowerSubject = subject.toLowerCase();
    final lowerBody = body.toLowerCase();

    // Spam / irrelevant ignorieren
    if (lowerSubject.contains('bewerbungsübersicht') ||
        lowerSubject.contains('eigenbemühungen') ||
        lowerSubject.contains('nachweis') ||
        lowerSubject.contains('antrag') ||
        lowerSubject.contains('newsletter') ||
        lowerSubject.contains('werbung')) {
      return null;
    }

    // Wenn es eine direkte Antwort (Reply) ist oder bestimmte Keywords im Betreff hat
    final isRep = isReply(subject);
    final cleanSubject = stripReplyPrefix(subject).toLowerCase();
    final subjectIsApplication = cleanSubject.contains('bewerbung') ||
        cleanSubject.contains('ihre unterlagen') ||
        cleanSubject.contains('kennenlernen') ||
        cleanSubject.contains('vorstellungsgespräch') ||
        cleanSubject.contains('interview') ||
        cleanSubject.contains('absage') ||
        cleanSubject.contains('zusage');

    if (isRep || subjectIsApplication) {
      if (_isRejection(lowerBody) || lowerSubject.contains('absage')) return 'absage';
      if (_isInterview(lowerBody) || lowerSubject.contains('einladung')) return 'interview';
      if (_isConfirmation(lowerBody) || lowerSubject.contains('eingangsbestätigung')) return 'bestaetigung';
    }

    // Falls gar nichts im Body erkannt wurde, es aber sicher eine gesendete Bewerbung ist (Sent Folder logic):
    final hasCoverLetterSigns = lowerBody.contains('sehr geehrte') &&
        (lowerBody.contains('bewerbe') || lowerBody.contains('bewerbung auf') || lowerBody.contains('interesse'));
    
    if (hasCoverLetterSigns && subjectIsApplication) return 'versendet';

    return null;
  }

  // ── Hilfsmethoden (öffentlich für DocumentIntelligenceService) ──────────────

  /// Prüft ob der Betreff ein Reply ist (RE:/AW:/WG:/FWD:/FW:).
  static bool isReply(String subject) {
    return _replyPrefixes.hasMatch(subject.trim());
  }

  /// Entfernt Reply-Prefixe aus dem Betreff.
  static String stripReplyPrefix(String subject) {
    String s = subject.trim();
    while (_replyPrefixes.hasMatch(s)) {
      s = s.replaceFirst(_replyPrefixes, '').trim();
    }
    return s;
  }

  /// Extrahiert einen Firmennamen aus der E-Mail-Domain.
  ///
  /// Ignoriert generische Provider (gmail, gmx, web, outlook, etc.).
  static String extractCompanyFromDomain(String recipientEmail) {
    if (!recipientEmail.contains('@')) return '';
    final domain = recipientEmail.split('@').last;
    final hostPart = domain.split('.').first.toLowerCase();

    if (_genericDomains.contains(hostPart) || hostPart.contains('jobcenter')) {
      return '';
    }

    return hostPart
        .split('-')
        .where((w) => w.isNotEmpty)
        .map((w) => (w.length <= 3) ? w.toUpperCase() : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  // ── Private Hilfsmethoden ──────────────────────────────────────────────────

  static final _replyPrefixes = RegExp(
    r'^(aw|re|wg|fwd|fw|antw)\s*:\s*',
    caseSensitive: false,
  );

  static const _genericDomains = {
    'gmail', 'gmx', 'web', 'outlook', 'hotmail', 'yahoo', 'icloud',
    'live', 'msn', 'aol', 't-online', 'freenet', 'posteo', 'protonmail',
    'proton', 'mailbox', 'tutanota', 'hey', 'pm', 'googlemail',
    'jobcenter-ge', 'jobcenter', 'arbeitsagentur',
  };

  static bool _isRejection(String lowerBody) {
    return (lowerBody.contains('leider') &&
            (lowerBody.contains('absage') ||
                lowerBody.contains('mitteilen') ||
                lowerBody.contains('entschieden') ||
                lowerBody.contains('vergeben'))) ||
        lowerBody.contains('abzusagen') ||
        lowerBody.contains('anderweitig besetzt') ||
        lowerBody.contains('konnten wir ihre bewerbung nicht berücksichtigen');
  }

  static bool _isInterview(String lowerBody) {
    return (lowerBody.contains('einladung') &&
            (lowerBody.contains('gespräch') ||
                lowerBody.contains('interview') ||
                lowerBody.contains('kennenlernen'))) ||
        lowerBody.contains('möchten sie gerne kennenlernen') ||
        lowerBody.contains('zu einem vorstellungsgespräch');
  }

  static bool _isConfirmation(String lowerBody) {
    return lowerBody.contains('eingangsbestätigung') ||
        lowerBody.contains('bewerbung erhalten') ||
        lowerBody.contains('unterlagen erhalten') ||
        lowerBody.contains('bestätigen den eingang');
  }

  /// Berechnet einen Confidence-Score basierend auf der Anzahl der Indikatoren.
  static double _statusConfidence(String body, String status) {
    final lower = body.toLowerCase();
    int indicators = 0;

    switch (status) {
      case 'absage':
        if (lower.contains('leider')) indicators++;
        if (lower.contains('absage')) indicators++;
        if (lower.contains('anderweitig')) indicators++;
        if (lower.contains('entschieden')) indicators++;
        if (lower.contains('nicht berücksichtigen')) indicators++;
        break;
      case 'interview':
        if (lower.contains('einladung')) indicators++;
        if (lower.contains('gespräch')) indicators++;
        if (lower.contains('kennenlernen')) indicators++;
        if (lower.contains('vorstellungsgespräch')) indicators++;
        break;
      case 'bestaetigung':
        if (lower.contains('eingangsbestätigung')) indicators++;
        if (lower.contains('erhalten')) indicators++;
        if (lower.contains('bestätigen')) indicators++;
        break;
      case 'versendet':
        if (lower.contains('sehr geehrte')) indicators++;
        if (lower.contains('bewerbe')) indicators++;
        if (lower.contains('bewerbung')) indicators++;
        break;
    }

    if (indicators >= 3) return 0.95;
    if (indicators >= 2) return 0.85;
    return 0.65;
  }
}

