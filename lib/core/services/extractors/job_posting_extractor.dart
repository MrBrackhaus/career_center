/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../../../domain/models/extraction_result.dart';

/// Extrahiert Daten aus Stellenanzeigen / Job-Postings.
///
/// Erkennt:
/// - Stellenbezeichnung (mit (m/w/d) Muster)
/// - Firmenname (Rechtsform-Suffix oder "Über uns" Sektion)
/// - Gehaltsangaben
/// - Kontaktperson / Ansprechpartner
/// - E-Mail, Telefon, Standort, URL
class JobPostingExtractor {
  /// Extrahiert Daten aus dem HTML (insbesondere JSON-LD/Schema.org JobPosting)
  ///
  /// Wird kein verwertbares JSON-LD gefunden, wird der sichtbare Text
  /// (ohne script/style/noscript/template) an [extract] übergeben.
  static ExtractedFields extractFromHtml(String htmlString) {
    final dom.Document document;
    try {
      document = html_parser.parse(htmlString);
    } catch (_) {
      return extract(_stripTagsFallback(htmlString));
    }

    final fromJsonLd = _extractFromJsonLd(document);
    if (fromJsonLd != null) return fromJsonLd;

    // Fallback: sichtbaren Text verwenden (niemals rohes HTML)
    return extract(visibleText(document));
  }

  /// Liefert den sichtbaren Text eines HTML-Dokuments ohne Inhalte von
  /// `script`, `style`, `noscript` und `template`.
  ///
  /// Achtung: entfernt die betroffenen Elemente aus [document].
  static String visibleText(dom.Document document) {
    for (final el in document.querySelectorAll(
      'script, style, noscript, template',
    )) {
      el.remove();
    }
    return document.body?.text ?? document.documentElement?.text ?? '';
  }

  /// Letzter Ausweg, falls der HTML-Parser scheitert: Tags per Regex entfernen.
  static String _stripTagsFallback(String html) {
    return html
        .replaceAll(
          RegExp(
            r'<(script|style|noscript|template)\b[^>]*>[\s\S]*?</\1\s*>',
            caseSensitive: false,
          ),
          ' ',
        )
        .replaceAll(RegExp(r'<[^>]*>'), ' ');
  }

  static ExtractedFields? _extractFromJsonLd(dom.Document document) {
    final scriptTags = document.querySelectorAll(
      'script[type="application/ld+json"]',
    );
    for (final script in scriptTags) {
      final text = script.text;
      if (!text.contains('JobPosting')) continue;
      try {
        final node = _findJobPosting(jsonDecode(text), 0);
        if (node == null) continue;
        final fields = _fieldsFromJobPosting(node);
        if (fields != null) return fields;
      } catch (_) {
        // Ungültiges oder unerwartet strukturiertes JSON-LD – nächstes Script
        continue;
      }
    }
    return null;
  }

  static bool _isJobPostingType(dynamic type) {
    if (type is String) return type == 'JobPosting';
    if (type is List) return type.contains('JobPosting');
    return false;
  }

  /// Sucht rekursiv (Liste, `@graph`) nach einem JobPosting-Knoten.
  static Map<dynamic, dynamic>? _findJobPosting(dynamic node, int depth) {
    if (depth > 5) return null;
    if (node is Map) {
      if (_isJobPostingType(node['@type'])) return node;
      final graph = node['@graph'];
      if (graph != null) return _findJobPosting(graph, depth + 1);
    } else if (node is List) {
      for (final element in node) {
        final found = _findJobPosting(element, depth + 1);
        if (found != null) return found;
      }
    }
    return null;
  }

  /// Wandelt einen skalaren JSON-Wert in einen getrimmten String um.
  static String? _jsonString(dynamic value) {
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    if (value is num) return value.toString();
    return null;
  }

  static ExtractedFields? _fieldsFromJobPosting(Map<dynamic, dynamic> json) {
    final position = _jsonString(json['title']);

    final companyNode = json['hiringOrganization'];
    final String? company = companyNode is Map
        ? _jsonString(companyNode['name'])
        : _jsonString(companyNode);

    var locationNode = json['jobLocation'];
    if (locationNode is List) {
      locationNode = locationNode.whereType<Map>().firstOrNull;
    }
    String? address;
    if (locationNode is Map) {
      final addr = locationNode['address'];
      if (addr is Map) {
        final country = addr['addressCountry'];
        address = [
          _jsonString(addr['addressLocality']),
          _jsonString(addr['addressRegion']),
          country is Map ? _jsonString(country['name']) : _jsonString(country),
        ].whereType<String>().join(', ');
      } else {
        address = _jsonString(addr);
      }
    }

    final salary = _formatSalary(json['baseSalary']);

    if (position == null &&
        company == null &&
        (address == null || address.isEmpty) &&
        salary == null) {
      return null;
    }

    FieldResult<String>? schemaField(String? value) =>
        value != null && value.isNotEmpty
            ? FieldResult(value: value, confidence: 1.0, source: 'schema.org')
            : null;

    return ExtractedFields(
      position: schemaField(position),
      company: schemaField(company),
      address: schemaField(address),
      salaryInfo: schemaField(salary),
    );
  }

  static const _salaryUnits = {
    'HOUR': 'pro Stunde',
    'DAY': 'pro Tag',
    'WEEK': 'pro Woche',
    'MONTH': 'pro Monat',
    'YEAR': 'pro Jahr',
  };

  /// Baut eine lesbare Gehaltsangabe aus einem schema.org `baseSalary`
  /// (MonetaryAmount mit QuantitativeValue), z.B. "42.000 - 51.000 EUR pro Jahr".
  static String? _formatSalary(dynamic node) {
    if (node is! Map) return _formatAmount(node);

    final currency = _jsonString(node['currency']);
    String? unit = _jsonString(node['unitText']);
    final value = node['value'];

    String? amount;
    if (value is Map) {
      unit = _jsonString(value['unitText']) ?? unit;
      final min = _formatAmount(value['minValue']);
      final max = _formatAmount(value['maxValue']);
      final single = _formatAmount(value['value']);
      if (min != null && max != null) {
        amount = min == max ? min : '$min - $max';
      } else if (single != null) {
        amount = single;
      } else if (min != null) {
        amount = 'ab $min';
      } else if (max != null) {
        amount = 'bis $max';
      }
    } else {
      amount = _formatAmount(value);
    }
    if (amount == null) return null;

    final unitLabel = unit == null ? null : _salaryUnits[unit.toUpperCase()];
    return [amount, currency, unitLabel].whereType<String>().join(' ').trim();
  }

  /// Formatiert eine Zahl im deutschen Format (Tausenderpunkt, Dezimalkomma).
  static String? _formatAmount(dynamic value) {
    num? number;
    if (value is num) {
      number = value;
    } else if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      number = num.tryParse(trimmed);
      if (number == null) return trimmed;
    } else {
      return null;
    }

    final isWhole = number == number.roundToDouble();
    final fixed = isWhole
        ? number.round().abs().toString()
        : number.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final grouped = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) grouped.write('.');
      grouped.write(intPart[i]);
    }
    final sign = number < 0 ? '-' : '';
    return parts.length > 1
        ? '$sign$grouped,${parts[1]}'
        : '$sign$grouped';
  }

  /// Findet externe Bewerbungs-Links im HTML (z.B. Personio, Workday, Greenhouse).
  ///
  /// Wird verwendet, wenn die initiale Extraktion unvollständig ist (z.B. keine
  /// Kontaktdaten gefunden), um Daten von der verlinkten externen Seite nachzuladen.
  static List<String> findExternalApplicationLinks(String htmlString) {
    final links = <String>[];
    try {
      final document = html_parser.parse(htmlString);
      final anchors = document.querySelectorAll('a[href]');

      // Bekannte Bewerbungsportale
      final knownPortals = [
        'personio.de', 'personio.com',
        'workday.com',
        'smartrecruiters.com',
        'greenhouse.io',
        'jobs.lever.co', 'lever.co',
        'recruitee.com',
        'softgarden.io', 'softgarden.de',
        'joinvision.com',
        'coveto.de',
        'stellenanzeigen.de',
        'indeed.com',
        'stepstone.de',
        'xing.com/jobs',
        'linkedin.com/jobs',
      ];

      // Bewerbungs-Keywords in Link-Text oder Title
      final applyKeywords = RegExp(
        r'(jetzt\s+bewerben|online\s+bewerben|zur\s+bewerbung|bewerbung\s+einreichen|apply\s+now|apply\s+here|bewerben\s+sie\s+sich|direkt\s+bewerben|hier\s+bewerben)',
        caseSensitive: false,
      );

      for (final anchor in anchors) {
        final href = anchor.attributes['href']?.trim() ?? '';
        if (href.isEmpty || href.startsWith('#') || href.startsWith('javascript:')) continue;

        final linkText = anchor.text.trim().toLowerCase();
        final title = (anchor.attributes['title'] ?? '').toLowerCase();

        // Prüfe ob der Link-Text oder Title ein Bewerbungs-Keyword enthält
        final hasApplyKeyword = applyKeywords.hasMatch(linkText) || applyKeywords.hasMatch(title);

        // Prüfe ob die URL zu einem bekannten Portal gehört
        final isKnownPortal = knownPortals.any((portal) => href.contains(portal));

        if (hasApplyKeyword || isKnownPortal) {
          // Normalisiere die URL
          String normalizedUrl = href;
          if (!normalizedUrl.startsWith('http')) {
            // Relative URLs überspringen – wir brauchen absolute externe Links
            continue;
          }
          if (!links.contains(normalizedUrl)) {
            links.add(normalizedUrl);
          }
        }
      }
    } catch (_) {
      // Bei Parse-Fehlern einfach leere Liste zurückgeben
    }
    return links;
  }

  // ── Gemeinsame Muster (auch von anderen Extraktoren genutzt) ─────────────

  /// Ein großgeschriebenes Namenswort (optional mit Bindestrich-Teil).
  static const _nameWord =
      r'[A-ZÄÖÜ][a-zA-Zäöüß]{1,40}(?:-[A-ZÄÖÜ][a-zA-Zäöüß]{1,40})?';

  /// Name (2-3 großgeschriebene Wörter) direkt am Anfang eines Strings,
  /// optional mit Anrede und Titel. Groß-/Kleinschreibung wird beachtet,
  /// damit kleingeschriebene Satzwörter nicht als Name erkannt werden.
  static final _nameAtStart = RegExp(
    r'^(?:(?:Frau|Herr|Mr\.|Mrs\.|Ms\.)[ \t]+)?(?:(?:Dr\.|Prof\.)[ \t]+)?('
    '$_nameWord[ \\t]+$_nameWord(?:[ \\t]+$_nameWord)?'
    r')(?![a-zA-Zäöüß])',
  );

  static final _informalContactKeyword = RegExp(
    r'\b(?:dein|deine|ihr|ihre|your|unser|unsere)[ \t]+(?:ansprechpartner(?:in)?|kontakt|contact|ansprechperson)(?:[ \t]*:[ \t]*|[ \t]+)',
    caseSensitive: false,
  );

  static final _englishContactKeyword = RegExp(
    r'\b(?:contact|hiring[ \t]+manager|point[ \t]+of[ \t]+contact|recruiter|hr[ \t]+contact)(?:[ \t]*:[ \t]*|[ \t]+)',
    caseSensitive: false,
  );

  static final _tabularContactKeyword = RegExp(
    r'\b(?:ansprechpartner(?:in)?|ansprechperson|kontaktperson)(?:[ \t]*:[ \t]*(?:\r?\n[ \t]*)?|[ \t]{2,}|\t+)',
    caseSensitive: false,
  );

  static String? _nameAfterKeyword(String text, RegExp keyword) {
    for (final match in keyword.allMatches(text)) {
      final nameMatch = _nameAtStart.firstMatch(text.substring(match.end));
      if (nameMatch != null) return nameMatch.group(1)!.trim();
    }
    return null;
  }

  /// Sucht eine Kontaktperson nach Schlüsselwörtern wie "Ihr Ansprechpartner:",
  /// "Hiring Manager:" oder "Ansprechperson:   ". Schlüsselwörter werden ohne
  /// Beachtung der Groß-/Kleinschreibung erkannt, der Name selbst muss aus
  /// großgeschriebenen Wörtern bestehen.
  static ({String name, String source})? findLabeledContact(String text) {
    final informal = _nameAfterKeyword(text, _informalContactKeyword);
    if (informal != null) {
      return (name: informal, source: 'contact_informal_pattern');
    }
    final english = _nameAfterKeyword(text, _englishContactKeyword);
    if (english != null) {
      return (name: english, source: 'contact_english_pattern');
    }
    final tabular = _nameAfterKeyword(text, _tabularContactKeyword);
    if (tabular != null) {
      return (name: tabular, source: 'contact_tabular_pattern');
    }
    return null;
  }

  /// Telefonnummer mit Kontext ("Tel.", "Telefon:", "Mobil" …).
  static final _phoneWithContext = RegExp(
    r'\b(?:tel(?:efon)?(?:nummer)?|phone|fon|mobil(?:funk)?(?:nummer)?|handy|rufnummer|durchwahl)\b\.?[ \t]*(?:\([A-Za-zäöüÄÖÜ .]{1,20}\)[ \t]*)?:?[ \t]*([+0-9(][0-9 \t/()\-]{4,25}[0-9])',
    caseSensitive: false,
  );

  /// Telefonnummer ohne Kontext: muss mit +49/0049/0 beginnen, darf nicht
  /// Teil eines Datums oder einer längeren Zahlenkette sein.
  static final _phoneShape = RegExp(
    r'(?<![\w.,/+\-])(?<!\d[ \t])(?:\+[1-9][0-9]{0,2}|00[1-9][0-9]{0,2}|0)[ \t]?(?:\(0\)[ \t]?)?[1-9][0-9 \t/\-]{4,22}[0-9](?![0-9]|[.,][0-9])',
  );

  static int _digitCount(String s) => s.replaceAll(RegExp(r'[^0-9]'), '').length;

  /// Findet eine plausible Telefonnummer im Text (zeilengebunden).
  static String? findPhoneNumber(String text) {
    for (final match in _phoneWithContext.allMatches(text)) {
      final number = match.group(1)!.trim();
      final digits = _digitCount(number);
      if (digits >= 6 && digits <= 15) return number;
    }
    for (final match in _phoneShape.allMatches(text)) {
      final number = match.group(0)!.trim();
      final prefix =
          RegExp(r'^(?:\+[1-9][0-9]{0,2}|00[1-9][0-9]{0,2}|0)').firstMatch(number)!.group(0)!;
      final digitsAfterPrefix = _digitCount(number) - _digitCount(prefix);
      if (digitsAfterPrefix >= 6 && _digitCount(number) <= 15) return number;
    }
    return null;
  }

  /// Rechtsform am Zeilenende (Groß-/Kleinschreibung beachtet, mit Wortgrenze).
  static final legalFormAtLineEnd = RegExp(
    r'\b(?:GmbH(?:[ \t]*&[ \t]*Co\.[ \t]*KG(?:aA)?)?|AG|KG|KGaA|SE|mbH|e\.[ \t]?V\.|GbR|OHG|eG|UG(?:[ \t]*\(haftungsbeschränkt\))?)$',
  );

  /// E-Mail-Adresse. Die Lookbehind-Bedingung verhindert quadratische
  /// Laufzeit bei sehr langen Zeichenketten ohne '@'.
  static final emailRegex = RegExp(
    r'(?<![a-zA-Z0-9._%+-])[a-zA-Z0-9._%+-]{1,64}@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );

  /// Maximale Zeilenlänge für Titel-/Firmen-Heuristiken.
  static const _maxHeuristicLineLength = 500;

  /// Extrahiert Daten aus einer Stellenanzeige.
  static ExtractedFields extract(String text) {
    final lines = text.split('\n').map((l) => l.trim()).toList();
    final nonEmptyLines = lines.where((l) => l.isNotEmpty).toList();
    final shortLines = nonEmptyLines
        .where((l) => l.length <= _maxHeuristicLineLength)
        .toList();

    FieldResult<String>? foundPosition;
    final genderMarker = RegExp(
      r'\([ \t]*[mwfdx][ \t]*/[ \t]*[mwfdx][ \t]*/[ \t]*[mwfdx][ \t]*\)',
      caseSensitive: false,
    );
    for (final line in shortLines) {
      if (genderMarker.hasMatch(line)) {
        foundPosition = FieldResult(
          value: line,
          confidence: 0.95,
          source: 'title_with_gender',
        );
        break;
      }
    }
    if (foundPosition == null && shortLines.isNotEmpty) {
      foundPosition = FieldResult(
        value: shortLines[0],
        confidence: 0.5,
        source: 'first_line_fallback',
      );
    }

    // ── Firma ────────────────────────────────────────────────────────────────
    FieldResult<String>? foundCompany;
    for (final line in shortLines) {
      if (line.length <= 100 && legalFormAtLineEnd.hasMatch(line)) {
        foundCompany = FieldResult(
          value: line,
          confidence: 0.9,
          source: 'legal_form_suffix',
        );
        break;
      }
    }
    if (foundCompany == null) {
      for (int i = 0; i < nonEmptyLines.length; i++) {
        final lower = nonEmptyLines[i].toLowerCase();
        if (lower == 'über uns' ||
            lower == 'wir sind' ||
            lower == 'unternehmen') {
          if (i + 1 < nonEmptyLines.length) {
            foundCompany = FieldResult(
              value: nonEmptyLines[i + 1],
              confidence: 0.75,
              source: 'about_us_section',
            );
            break;
          }
        }
      }
    }

    // ── Gehalt ───────────────────────────────────────────────────────────────
    FieldResult<String>? foundSalary;
    final salaryPatterns = RegExp(
      r'(Gehalt|Vergütung)[ \t:]*([0-9][0-9.,]*[^\n]*?(?:\bEUR\b|€))',
      caseSensitive: false,
    );
    // Betrag + Währung, z.B. "65.000 EUR", "16,50 €", "€ 3.000"
    final amountWithCurrency = RegExp(
      r'\d[\d.,]*[ \t]*(?:€|\bEUR\b)|(?:€|\bEUR\b)[ \t]*\d',
    );
    for (final line in shortLines) {
      final match = salaryPatterns.firstMatch(line);
      if (match != null) {
        foundSalary = FieldResult(
          value: match.group(0)!,
          confidence: 0.85,
          source: 'explicit_salary',
        );
        break;
      }
      final lower = line.toLowerCase();
      if (lower.contains('gehalt') ||
          lower.contains('vergütung') ||
          amountWithCurrency.hasMatch(line)) {
        foundSalary = FieldResult(
          value: line,
          confidence: 0.7,
          source: 'salary_keyword',
        );
        break;
      }
    }

    // ── Kontaktperson ───────────────────────────────────────────────────────────────────────
    FieldResult<String>? foundContact;

    // Suche nach HR-Begriffen oder Ansprechpartner in der Nähe von Namen
    final hrRoles = [
      'hr manager',
      'recruiter',
      'personalreferent',
      'talent acquisition',
      'ansprechpartner',
      'kontakt',
      'z.hd.',
      'zu händen',
    ];
    for (int i = 0; i < nonEmptyLines.length; i++) {
      final line = nonEmptyLines[i];
      final lower = line.toLowerCase();

      bool hasHrRole = hrRoles.any((r) => lower.contains(r));

      if (hasHrRole) {
        // Regex für Namen: optional Titel, optional Herr/Frau, dann 2+ großgeschriebene Wörter (keine Zeilenumbrüche)
        // Muss jetzt die ganze Zeile sein (oder fast die ganze), um False Positives in Sätzen zu vermeiden
        final nameRegex = RegExp(
          r'^[ \t]*(?:(?:Frau|Herr|Mr\.|Mrs\.|Ms\.)[ \t]+)?(?:(?:Dr\.|Prof\.)[ \t]+)?([A-ZÄÖÜ][a-zA-Zäöüß]{1,200}[ \t]+[A-ZÄÖÜ][a-zA-Zäöüß]{1,200}(?:[ \t]+[A-ZÄÖÜ][a-zA-Zäöüß]{1,200})?)[ \t]*$',
        );

        final match = nameRegex.firstMatch(line);
        final matchStr = match?.group(0)?.toLowerCase() ?? '';
        
        // Vermeide dass die Rolle selbst als Name erkannt wird (z.B. "HR Manager")
        bool isJustRole = hrRoles.any((r) => matchStr.contains(r));

        if (match != null && !lower.startsWith('kontakt') && !isJustRole) {
          foundContact = FieldResult(
            value: match.group(0)!,
            confidence: 0.9,
            source: 'contact_hr_role_line',
          );
          break;
        }

        // Prüfe nächste 1-2 Zeilen
        if (i + 1 < nonEmptyLines.length) {
          final nextMatch = nameRegex.firstMatch(nonEmptyLines[i + 1]);
          if (nextMatch != null) {
            foundContact = FieldResult(
              value: nextMatch.group(0)!,
              confidence: 0.8,
              source: 'contact_hr_role_next_line',
            );
            break;
          }
        }
      }
    }

    // Erweitert: "Dein/Ihr/Your Ansprechpartner/Kontakt/Contact: Name",
    // englische Muster ("Hiring Manager:") und Tabellen-Format
    // ("Ansprechpartner\t\tMax Mustermann").
    if (foundContact == null) {
      final labeled = findLabeledContact(text);
      if (labeled != null) {
        foundContact = FieldResult(
          value: labeled.name,
          confidence: switch (labeled.source) {
            'contact_informal_pattern' => 0.85,
            _ => 0.8,
          },
          source: labeled.source,
        );
      }
    }

    // Fallback: Suche einfach nach Frau/Herr Dr. Max Mustermann im gesamten Text
    if (foundContact == null) {
      final contactRegexFallback = RegExp(
        r'(Frau|Herr)[ \t]+(?:Dr\.[ \t]+|Prof\.[ \t]+)?([A-ZÄÖÜ][a-zA-Zäöüß]{1,200}[ \t]+[A-ZÄÖÜ][a-zA-Zäöüß]{1,200})',
      );
      final match = contactRegexFallback.firstMatch(text);
      if (match != null) {
        foundContact = FieldResult(
          value: match.group(0)!,
          confidence: 0.7,
          source: 'contact_regex_fallback',
        );
      }
    }

    // ── E-Mail ──────────────────────────────────────────────────────────────────────────
    FieldResult<String>? foundEmail;
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      foundEmail = FieldResult(
        value: emailMatch.group(0)!,
        confidence: 0.9,
        source: 'email_regex',
      );
    }

    // ── Telefon ─────────────────────────────────────────────────────────────────────────
    FieldResult<String>? foundPhone;
    final phone = findPhoneNumber(text);
    if (phone != null) {
      foundPhone = FieldResult(
        value: phone,
        confidence: 0.9,
        source: 'phone_regex',
      );
    }

    // ── Standort / Adresse ───────────────────────────────────────────────────────────────
    FieldResult<String>? foundAddress;

    // Volle Adresse mit Straße und PLZ/Ort finden (Straße und PLZ/Ort durch
    // Komma oder Zeilenumbruch getrennt)
    final fullAddressRegex = RegExp(
      r'([A-ZÄÖÜ][a-zA-Zäöüß .\-]{0,100}?(?:[Ss]tr\.|[Ss]traße|[Ww]eg|[Pp]latz|[Aa]llee|[Rr]ing|[Gg]asse|[Dd]amm|[Uu]fer)[ \t]*\d{1,4}[ \t]?[a-zA-Z]?)[ \t]*(?:,[ \t]*|\r?\n[ \t]*)(\d{5})[ \t]+([A-ZÄÖÜ][a-zA-Zäöüß\-]{1,100})',
    );
    final fullMatch = fullAddressRegex.firstMatch(text);

    if (fullMatch != null) {
      final street = fullMatch.group(1)!.trim();
      final plz = fullMatch.group(2)!.trim();
      final city = fullMatch.group(3)!.trim();

      foundAddress = FieldResult(
        value: "$street, $plz $city",
        confidence: 0.95,
        source: 'full_address_regex',
      );
    } else {
      // Fallback: Nur PLZ und Stadt
      final plzCityRegex = RegExp(
        r'\b(\d{5})[ \t]+([A-ZÄÖÜ][a-zA-Zäöüß\-]{1,100})',
      );
      final plzMatch = plzCityRegex.firstMatch(text);
      if (plzMatch != null) {
        foundAddress = FieldResult(
          value: '${plzMatch.group(1)} ${plzMatch.group(2)}',
          confidence: 0.8,
          source: 'plz_city_regex',
        );
      }
    }
    // ── URL ──────────────────────────────────────────────────────────────────
    FieldResult<String>? foundUrl;
    final urlRegex = RegExp(
      r'https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[/a-zA-Z0-9._~:/?#\[\]@!$&()*+,;=-]*',
    );
    final urlMatch = urlRegex.firstMatch(text);
    if (urlMatch != null) {
      foundUrl = FieldResult(
        value: urlMatch.group(0)!.replaceAll(RegExp(r'[)\.]+$'), ''),
        confidence: 0.9,
        source: 'url_regex',
      );
    } else {
      final wwwRegex = RegExp(r'www\.[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
      final wwwMatch = wwwRegex.firstMatch(text);
      if (wwwMatch != null) {
        foundUrl = FieldResult(
          value: wwwMatch.group(0)!,
          confidence: 0.85,
          source: 'www_regex',
        );
      }
    }

    return ExtractedFields(
      position: foundPosition,
      company: foundCompany,
      salaryInfo: foundSalary,
      contactName: foundContact,
      contactEmail: foundEmail,
      contactPhone: foundPhone,
      address: foundAddress,
      companyUrl: foundUrl,
    );
  }
}
