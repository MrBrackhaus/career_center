/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
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
    // multiLine: `$` muss auch am Zeilenende greifen (Body ist mehrzeilig);
    // [ \t] statt \s, damit die Position nicht über Zeilen hinweg läuft.
    final posRegex1 = RegExp(
      r'[Bb]ewerbung[ \t]+als[ \t]+(.+?)(?:[ \t]+[-–—]|[ \t]*\(m|[ \t]+bei\b|[ \t]*[.,;!?]?[ \t]*$)',
      multiLine: true,
    );
    final posRegex2 = RegExp(
      r'[Bb]ewerbung[ \t]*[-–—][ \t]*(.+?)(?:[ \t]*\(m|[ \t]*[.,;!?]?[ \t]*$)',
      multiLine: true,
    );

    final subjMatch =
        posRegex1.firstMatch(cleanSubject) ??
        posRegex2.firstMatch(cleanSubject);
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
      final bodyMatch =
          posRegex1.firstMatch(body) ?? posRegex2.firstMatch(body);
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
    final company = findCompanyWithLegalForm(body);
    if (company != null) {
      foundCompany = FieldResult(
        value: company.name,
        confidence: company.isFooterLine ? 0.9 : 0.85,
        source: company.isFooterLine ? 'body_legal_footer' : 'body_legal_form',
      );
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
      r'Sehr\s+geehrte[r]?\s+(Frau|Herr)\s+(?:(Dr\.|Prof\.)\s+)?([A-ZÄÖÜ][a-zäöüß]{1,200}(?:\s+[A-ZÄÖÜ][a-zäöüß]{1,200})*)',
    );
    final contactMatch = contactRegex.firstMatch(body);
    if (contactMatch != null) {
      final title = contactMatch.group(2) != null ? '${contactMatch.group(2)} ' : '';
      final name = contactMatch.group(3);
      foundContact = FieldResult(
        value: '${contactMatch.group(1)} $title$name'.trim(),
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

  // ── Firmenname mit Rechtsform ──────────────────────────────────────────────

  /// Firmenname: 1-6 großgeschriebene Wörter (optional mit "&") direkt vor
  /// einer Rechtsform. Groß-/Kleinschreibung wird beachtet und die Suche ist
  /// auf eine Zeile beschränkt, damit keine Satzfragmente entstehen.
  static final _companyEntity = RegExp(
    r'((?:[A-ZÄÖÜ0-9][A-Za-zÄÖÜäöüß0-9&.\-]*[ \t]+(?:&[ \t]+)?){1,6})'
    r'(GmbH(?:[ \t]*&[ \t]*Co\.[ \t]*KG)?|AG|KGaA|KG|SE|mbH|e\.[ \t]?V\.|GbR|OHG|eG|UG)'
    r'(?![A-Za-zÄÖÜäöüß0-9])',
  );

  /// Satzanfangs-/Füllwörter, die nicht zum Firmennamen gehören.
  static const _leadingNonNameWords = {
    'Die', 'Der', 'Das', 'Den', 'Dem', 'Des', 'Bei', 'Von', 'Vom', 'Für',
    'Mit', 'Und', 'Ihr', 'Ihre', 'Ihrer', 'Ihres', 'Unser', 'Unsere', 'Wir',
    'Sie', 'Im', 'In', 'An', 'Am', 'Auf', 'Zur', 'Zum', 'Liebe', 'Lieber',
  };

  /// Sucht einen Firmennamen mit Rechtsform im Text.
  ///
  /// Bevorzugt Zeilen, die (fast) nur aus dem Firmennamen bestehen (Footer/
  /// Signatur), sonst den letzten Treffer im Fließtext.
  static ({String name, bool isFooterLine})? findCompanyWithLegalForm(
    String text,
  ) {
    ({String name, bool isFooterLine})? lastInText;
    ({String name, bool isFooterLine})? lastFooter;

    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.length > 300) continue;
      for (final match in _companyEntity.allMatches(line)) {
        final words = match.group(1)!.trim().split(RegExp(r'[ \t]+'));
        while (words.isNotEmpty && _leadingNonNameWords.contains(words.first)) {
          words.removeAt(0);
        }
        if (words.isEmpty || words.first == '&') continue;
        final name = '${words.join(' ')} ${match.group(2)!}'
            .replaceAll(RegExp(r'[ \t]+'), ' ')
            .trim();
        if (name.length >= 60) continue;
        final isFooter = name.length >= line.length * 0.8;
        final candidate = (name: name, isFooterLine: isFooter);
        if (isFooter) {
          lastFooter = candidate;
        } else {
          lastInText = candidate;
        }
      }
    }
    return lastFooter ?? lastInText;
  }

  // ── Status-Erkennung ───────────────────────────────────────────────────────

  /// Erkennt den Bewerbungsstatus aus einer E-Mail.
  ///
  /// Returns: 'absage', 'interview', 'versendet', 'bestaetigung' oder null.
  static String? detectStatus(String subject, String body) {
    final lowerSubject = subject.toLowerCase();
    final lowerBody = body.toLowerCase();

    // Spam / irrelevant ignorieren
    final spamRegex = RegExp(r'\b(bewerbungsübersicht|eigenbemühungen|nachweis|antrag|newsletter|werbung|angebote)\b', caseSensitive: false);
    if (spamRegex.hasMatch(subject)) {
      return null;
    }

    // Wenn es eine direkte Antwort (Reply) ist oder bestimmte Keywords im Betreff hat
    final isRep = isReply(subject);
    final cleanSubject = stripReplyPrefix(subject).toLowerCase();
    final subjectIsApplication =
        cleanSubject.contains('bewerbung') ||
        cleanSubject.contains('ihre unterlagen') ||
        cleanSubject.contains('kennenlernen') ||
        cleanSubject.contains('vorstellungsgespräch') ||
        cleanSubject.contains('interview') ||
        cleanSubject.contains('absage') ||
        cleanSubject.contains('zusage') ||
        cleanSubject.contains('einladung') ||
        cleanSubject.contains('gespräch') ||
        cleanSubject.contains('termin');

    if (isRep || subjectIsApplication) {
      if (_isRejection(lowerBody) || lowerSubject.contains('absage')) {
        return 'absage';
      }
      if (_isInterview(lowerBody) || lowerSubject.contains('einladung')) {
        return 'interview';
      }
      if (_isConfirmation(lowerBody) ||
          lowerSubject.contains('eingangsbestätigung')) {
        return 'bestaetigung';
      }
    }

    // Falls gar nichts im Body erkannt wurde, es aber sicher eine gesendete Bewerbung ist (Sent Folder logic):
    final hasCoverLetterSigns =
        lowerBody.contains('sehr geehrte') &&
        (lowerBody.contains('bewerbe') ||
            lowerBody.contains('bewerbung auf') ||
            lowerBody.contains('interesse'));

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
    final domain = recipientEmail.split('@').last.toLowerCase();
    final parts = domain.split('.');
    
    if (parts.length < 2) return '';

    // Robust TLD/SLD handling
    const commonSLDs = {
      'co', 'com', 'org', 'net', 'edu', 'gov', 'mil', 'ac', 'gob', 'gv', 'sch',
      'or', 'k12', 'me', 'ab', 'bc', 'mb', 'nb', 'nl', 'ns', 'nt', 'nu', 'on', 'pe', 'qc', 'sk', 'yk'
    };
    
    String companyPart = parts[parts.length - 2];
    if (parts.length >= 3 && commonSLDs.contains(companyPart)) {
      companyPart = parts[parts.length - 3];
    }

    if (_genericDomains.contains(companyPart) || companyPart.contains('jobcenter')) {
      return '';
    }

    return companyPart
        .split('-')
        .where((w) => w.isNotEmpty)
        .map(
          (w) => (w.length <= 3)
              ? w.toUpperCase()
              : w[0].toUpperCase() + w.substring(1),
        )
        .join(' ');
  }

  // ── Private Hilfsmethoden ──────────────────────────────────────────────────

  static final _replyPrefixes = RegExp(
    r'^(aw|re|wg|fwd|fw|antw)\s*:\s*',
    caseSensitive: false,
  );

  static const _genericDomains = {
    'gmail',
    'gmx',
    'web',
    'outlook',
    'hotmail',
    'yahoo',
    'icloud',
    'live',
    'msn',
    'aol',
    't-online',
    'freenet',
    'posteo',
    'protonmail',
    'proton',
    'mailbox',
    'tutanota',
    'hey',
    'pm',
    'googlemail',
    'jobcenter-ge',
    'jobcenter',
    'arbeitsagentur',
  };

  static bool _isRejection(String lowerBody) {
    return (lowerBody.contains('leider') &&
            (lowerBody.contains('absage') ||
                lowerBody.contains('mitteilen') ||
                lowerBody.contains('entschieden') ||
                lowerBody.contains('vergeben'))) ||
        lowerBody.contains('jedoch mitteilen') ||
        lowerBody.contains('nicht in die engere auswahl') ||
        lowerBody.contains('abzusagen') ||
        lowerBody.contains('anderweitig besetzt') ||
        lowerBody.contains('konnten wir ihre bewerbung nicht berücksichtigen');
  }

  /// Typische Formulierung aus dem eigenen Anschreiben
  /// ("Über eine Einladung zu einem Gespräch freue ich mich").
  static final _outgoingInvitationPhrase = RegExp(
    r'(?<![a-zäöüß])(?:über|auf)[ \t]+(?:eine|ihre)[ \t]+(?:positive[ \t]+)?(?:rückmeldung[ \t]+und[ \t]+(?:eine[ \t]+)?)?einladung\b',
  );

  /// Einladungs-Verben/-Nomen mit Wortgrenzen (nicht "herunterladen",
  /// "hochladen" usw.), inklusive trennbarem "laden … ein".
  static final _invitationPhrase = RegExp(
    r'\b(?:einladung(?:en)?|einladen|einzuladen|eingeladen)\b'
    r'|\blade(?:n)?\b[^.!?\n]{0,80}?\bein\b',
  );

  static final _meetingNoun = RegExp(
    r'gespräch|interview|kennenlernen|kennen[ \t]+zu[ \t]+lernen|kennenzulernen|vorstellungstermin|\btermin',
  );

  static bool _isInterview(String lowerBody) {
    // Verhindere False-Positives aus dem eigenen Anschreiben – aber nur bei
    // eindeutig ausgehender Formulierung, nicht bei jedem "freue ich mich".
    if (_outgoingInvitationPhrase.hasMatch(lowerBody)) {
      return false;
    }

    return (_invitationPhrase.hasMatch(lowerBody) &&
            _meetingNoun.hasMatch(lowerBody)) ||
        lowerBody.contains('möchten sie gerne kennenlernen') ||
        lowerBody.contains('zu einem vorstellungsgespräch') ||
        lowerBody.contains('zu einem interview');
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
