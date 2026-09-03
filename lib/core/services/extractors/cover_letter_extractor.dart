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
import '../../../domain/models/extraction_result.dart';

/// Extrahiert Daten aus deutschen Bewerbungsanschreiben.
///
/// Portiert und verbessert die Logik aus `_autoFillFromPdf()` in
/// `application_form_screen.dart`. Erkennt:
/// - Stellenbezeichnung aus "Bewerbung als..." Zeile
/// - Firmenname über der Empfängeradresse
/// - Empfängeradresse (PLZ/Ort + Straße)
/// - Datum (DD.MM.YYYY)
/// - Kontaktperson aus "Sehr geehrte(r)..."
class CoverLetterExtractor {
  /// Extrahiert Daten aus einem Anschreiben-Text.
  /// Returns ExtractedFields with confidence scores per field.
  static ExtractedFields extract(String text) {
    final lines = text.split('\n').map((l) => l.trim()).toList();
    final nonEmptyLines = lines.where((l) => l.isNotEmpty).toList();

    // â”€â”€ 1. Datum suchen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    FieldResult<DateTime>? foundDate;
    final dateRegex = RegExp(r'(\d{1,2})\.(\d{1,2})\.(\d{4})');
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        try {
          final date = DateTime(
            int.parse(match.group(3)!),
            int.parse(match.group(2)!),
            int.parse(match.group(1)!),
          );
          foundDate = FieldResult(value: date, confidence: 0.95, source: 'regex_date');
          break;
        } catch (_) {}
      }
    }

    // â”€â”€ 2. Cover-Letter-Erkennung â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    bool isCoverLetter = false;
    int subjectIndex = -1;

    for (int i = 0; i < nonEmptyLines.length; i++) {
      final lower = nonEmptyLines[i].toLowerCase();
      if (lower.startsWith('bewerbung als') ||
          lower.startsWith('bewerbung auf') ||
          lower.startsWith('bewerbung um') ||
          lower.startsWith('bewerbung für') ||
          lower.startsWith('bewerbung:') ||
          lower.startsWith('bewerbung -') ||
          lower == 'bewerbung') {
        subjectIndex = i;
        isCoverLetter = true;
        break;
      }
      if (lower.contains('sehr geehrte')) {
        isCoverLetter = true;
      }
    }

    if (!isCoverLetter) {
      // Fallback für Nicht-Anschreiben (z.B. Jobcenter-PDFs)
      return _extractFallback(text, nonEmptyLines, foundDate);
    }

    // â”€â”€ 3. Stellenbezeichnung â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    FieldResult<String>? foundPosition;
    if (subjectIndex >= 0) {
      // Finde den echten Index in der lines-Liste (mit Leerzeilen)
      final subjectLine = nonEmptyLines[subjectIndex];
      final realIndex = lines.indexOf(subjectLine);

      // Titel zusammensetzen (falls über mehrere Zeilen umgebrochen)
      List<String> titleParts = [subjectLine];
      for (int j = realIndex + 1; j < realIndex + 4 && j < lines.length; j++) {
        if (lines[j].isEmpty) continue;
        final nextLow = lines[j].toLowerCase();
        if (nextLow.startsWith('sehr geehrte') ||
            RegExp(r'^\d{5}').hasMatch(lines[j]) ||
            nextLow.startsWith('anlagen')) {
          break;
        }
        titleParts.add(lines[j]);
      }

      String title = titleParts.join(' ')
          .replaceAll('- ', '-')
          .replaceAll(' -', '-');

      // "Bewerbung als/auf/um/für" Prefix entfernen
      title = title.replaceAll(
        RegExp(r'bewerbung\s*(als|auf|um|für|:|-)?\s*', caseSensitive: false),
        '',
      );

      if (title.isNotEmpty && title.length < 100) {
        foundPosition = FieldResult(
          value: title.trim(),
          confidence: titleParts.length > 1 ? 0.75 : 0.9,
          source: titleParts.length > 1 ? 'cover_letter_subject_merged' : 'cover_letter_subject',
        );
      }
    }

    // â”€â”€ 4. Empfängeradresse (PLZ/Ort) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    FieldResult<String>? foundAddress;
    FieldResult<String>? foundCompany;

    final plzCityRegex = RegExp(r'^\d{5}\s+[a-zäöüß]', caseSensitive: false);
    int bestRecipientCityIndex = -1;

    for (int i = 0; i < nonEmptyLines.length; i++) {
      if (plzCityRegex.hasMatch(nonEmptyLines[i])) {
        // Prüfe ob Absender (Email/Tel in Zeilen darüber)
        bool isSender = false;
        for (int j = 1; j <= 2; j++) {
          if (i - j >= 0) {
            final lLow = nonEmptyLines[i - j].toLowerCase();
            if (lLow.contains('@') ||
                RegExp(r'(tel|mobil|01[5-7]|\+49)').hasMatch(lLow)) {
              isSender = true;
              break;
            }
          }
        }
        if (!isSender) {
          bestRecipientCityIndex = i;
        }
      }
    }

    if (bestRecipientCityIndex != -1) {
      // â”€â”€ 5. Straße zusammenbauen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      final streetRegex = RegExp(r'[a-zäöüß\.\-\s]+\d{1,4}[a-z]?', caseSensitive: false);
      int companyIdx = bestRecipientCityIndex - 1;
      List<String> streetParts = [];

      while (companyIdx >= 0) {
        final lLow = nonEmptyLines[companyIdx].toLowerCase();
        if (streetRegex.hasMatch(nonEmptyLines[companyIdx]) ||
            lLow.contains('straße') ||
            lLow.contains('str.') ||
            lLow.contains('postfach')) {
          streetParts.insert(0, nonEmptyLines[companyIdx]);
          companyIdx--;
        } else if (nonEmptyLines[companyIdx].endsWith('-') ||
            nonEmptyLines[companyIdx] == '-' ||
            (!nonEmptyLines[companyIdx].contains(' ') && streetParts.isNotEmpty)) {
          streetParts.insert(0, nonEmptyLines[companyIdx]);
          companyIdx--;
        } else {
          break;
        }
      }

      if (streetParts.isNotEmpty) {
        String combinedStreet = streetParts.join(' ')
            .replaceAll('- ', '-')
            .replaceAll(' -', '-');
        foundAddress = FieldResult(
          value: '$combinedStreet, ${nonEmptyLines[bestRecipientCityIndex]}',
          confidence: 0.85,
          source: 'plz_address_block',
        );
      } else {
        foundAddress = FieldResult(
          value: nonEmptyLines[bestRecipientCityIndex],
          confidence: 0.8,
          source: 'plz_only',
        );
      }

      // â”€â”€ 6. Firmenname â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      final skipMarkers = [
        'fachbereich', 'abteilung', 'z.hd', 'herr', 'frau',
        'postfach', 'zentralbereich', 'personal', 'human', 'resources',
      ];

      while (companyIdx >= 0 && companyIdx > bestRecipientCityIndex - 8) {
        final lLow = nonEmptyLines[companyIdx].toLowerCase();
        bool isDeptOrContact = nonEmptyLines[companyIdx].trim().length <= 2;
        for (final marker in skipMarkers) {
          if (lLow.contains(marker)) {
            isDeptOrContact = true;
            break;
          }
        }
        if (isDeptOrContact) {
          companyIdx--;
        } else {
          break;
        }
      }

      if (companyIdx >= 0 && !nonEmptyLines[companyIdx].contains('@')) {
        foundCompany = FieldResult(
          value: nonEmptyLines[companyIdx],
          confidence: 0.85,
          source: 'company_above_address',
        );
      }
    }

    // â”€â”€ 6.5 Fallback für Firma und Adresse (falls keine PLZ gefunden wurde) â”€
    if (foundCompany == null && subjectIndex > 0) {
      int searchStartIndex = subjectIndex - 1;
      
      // Überspringe die Datumszeile, falls sie direkt über dem Betreff steht
      if (searchStartIndex >= 0 && nonEmptyLines[searchStartIndex].contains(DateTime.now().year.toString().substring(0,2))) {
          // Check for year like 2024, 2025, 2026
          searchStartIndex--;
      }

      final legalForms = RegExp(
        r'(GmbH(?:\s*&\s*Co\.\s*KG)?|AG|KG|SE|mbH|e\.V\.|GbR|OHG)$',
        caseSensitive: false,
      );

      final skipMarkers = [
        'fachbereich', 'abteilung', 'z.hd', 'herr', 'frau',
        'postfach', 'zentralbereich', 'personal', 'human', 'resources',
      ];

      for (int i = searchStartIndex; i >= 0 && i >= searchStartIndex - 8; i--) {
        final line = nonEmptyLines[i];
        final lLow = line.toLowerCase();
        
        // Absender-Infos ignorieren
        if (lLow.contains('@') || RegExp(r'(tel|mobil|01[5-7]|\+49)').hasMatch(lLow) || lLow.contains('telefon')) {
          continue;
        }
        
        // Abteilung/Z.Hd. ignorieren
        bool isDeptOrContact = false;
        for (final marker in skipMarkers) {
          if (lLow.contains(marker)) {
            isDeptOrContact = true;
            break;
          }
        }
        
        if (isDeptOrContact) {
           // Wenn wir noch keine Adresse haben, könnte eine der Zeilen nach der Abteilung die Stadt sein (z.B. Neuss)
           if (foundAddress == null && i + 1 <= searchStartIndex) {
               final potentialCity = nonEmptyLines[i + 1];
               if (!potentialCity.contains('202') && potentialCity.length < 30) {
                   foundAddress = FieldResult(
                       value: potentialCity,
                       confidence: 0.6,
                       source: 'fallback_city_after_dept',
                   );
               }
           }
           continue;
        }

        // Firmennamen erkennen
        if (legalForms.hasMatch(line) || lLow.contains('unternehmen') || lLow.contains('klinik') || lLow.contains('firma')) {
           foundCompany = FieldResult(
            value: line,
            confidence: 0.8, // Relativ sicher, da Rechtsform gefunden
            source: 'company_fallback_scan',
          );
          
          // Wenn wir noch keine Adresse (Stadt) haben und die Zeile direkt unter der Firma keine Abteilung ist, ist es oft die Stadt
          if (foundAddress == null && i + 1 <= searchStartIndex) {
             bool nextIsDept = false;
             for (final marker in skipMarkers) {
                if (nonEmptyLines[i + 1].toLowerCase().contains(marker)) {
                   nextIsDept = true; break;
                }
             }
             if (!nextIsDept && !nonEmptyLines[i + 1].contains('202')) {
                foundAddress = FieldResult(
                    value: nonEmptyLines[i + 1],
                    confidence: 0.6,
                    source: 'fallback_city_under_company',
                );
             }
          }
          break;
        }
      }
    }

    // ── 7. Kontaktperson ───────────────────────────────────────────────────────────────────────
    FieldResult<String>? foundContact;
    
    // 7.1 Versuche den vollen Namen aus der "z. Hd." oder "Herr/Frau" Zeile im Adressblock zu lesen
    final contactBlockRegex = RegExp(
      r'^(?:z\.?\s*hd\.?\s*)?(?:frauen|herrn|frau|herr)\s+(?:dr\.\s+|prof\.\s+)?([a-zäöüß]+\s+[a-zäöüß]+(?:\s+[a-zäöüß]+)?)$',
      caseSensitive: false,
    );
    for (int i = 0; i < nonEmptyLines.length && i < 20; i++) { // Meist im oberen Drittel
      final match = contactBlockRegex.firstMatch(nonEmptyLines[i].trim());
      if (match != null) {
        String extractedName = match.group(1)!.trim();
        extractedName = extractedName.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '').join(' ');
        foundContact = FieldResult(
          value: extractedName,
          confidence: 0.95,
          source: 'z_hd_address_block',
        );
        break;
      }
    }
    
    // 7.2 Fallback: Anrede "Sehr geehrte(r)..."
    if (foundContact == null) {
      final contactRegex = RegExp(
        r'sehr\s+geehrte[r]?\s+(frau|herr)\s*(?:dr\.\s+|prof\.\s+)?([a-zäöüß]+\s+[a-zäöüß]+(?:\s+[a-zäöüß]+)*)',
        caseSensitive: false,
      );
      final contactMatch = contactRegex.firstMatch(text);
      if (contactMatch != null) {
        String extractedName = ' '.trim();
        extractedName = extractedName.split(' ').map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '').join(' ');
        foundContact = FieldResult(
          value: extractedName,
          confidence: 0.9,
          source: 'salutation',
        );
      }
    }
    return ExtractedFields(
      position: foundPosition,
      company: foundCompany,
      address: foundAddress,
      applicationDate: foundDate,
      contactName: foundContact,
      applicationStatus: const FieldResult(
        value: 'versendet',
        confidence: 0.85,
        source: 'cover_letter_detected',
      ),
      notes: const FieldResult(
        value: 'Automatisch aus Anschreiben-PDF importiert.',
        confidence: 1.0,
        source: 'system',
      ),
    );
  }

  /// Fallback für Nicht-Anschreiben (z.B. Jobcenter-PDF, Stellenanzeige).
  static ExtractedFields _extractFallback(
    String text,
    List<String> nonEmptyLines,
    FieldResult<DateTime>? foundDate,
  ) {
    FieldResult<String>? foundPosition;
    FieldResult<String>? foundCompany;
    FieldResult<String>? foundEmail;
    FieldResult<String>? foundPhone;
    FieldResult<String>? foundContact;
    FieldResult<String>? foundAddress;
    FieldResult<String>? foundUrl;

    if (nonEmptyLines.isNotEmpty) {
      foundPosition = FieldResult(
        value: nonEmptyLines.first,
        confidence: 0.4,
        source: 'fallback_first_line',
      );
    }
    if (nonEmptyLines.length > 1) {
      foundCompany = FieldResult(
        value: nonEmptyLines[1],
        confidence: 0.4,
        source: 'fallback_second_line',
      );
    }

    // E-Mail
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      foundEmail = FieldResult(
        value: emailMatch.group(0)!,
        confidence: 0.8,
        source: 'regex_email',
      );
    }

    // Telefon
    final phoneRegex = RegExp(r'(\+49|0)[0-9\s/.-]{7,20}');
    final phoneMatch = phoneRegex.firstMatch(text);
    if (phoneMatch != null) {
      foundPhone = FieldResult(
        value: phoneMatch.group(0)!.trim(),
        confidence: 0.7,
        source: 'regex_phone',
      );
    }

    // Kontaktperson
    final contactRegex = RegExp(
      r'(Frau|Herr)\s+([A-ZÄÖÜ][a-zA-ZäöüÄÖÜß-]+(\s+[A-ZÄÖÜ][a-zA-ZäöüÄÖÜß-]+)?)',
    );
    final contactMatch = contactRegex.firstMatch(text);
    if (contactMatch != null) {
      foundContact = FieldResult(
        value: contactMatch.group(0)!,
        confidence: 0.7,
        source: 'regex_contact',
      );
    }

    // Adresse
    final addressRegex = RegExp(
      r'([A-ZÄÖÜ][a-zA-ZäöüÄÖÜß\.\-\s]+\d{1,4}[a-zA-Z]?)[,\s\n\r]+(\d{5})\s+([A-ZÄÖÜ][a-zA-ZäöüÄÖÜß\-]+)',
    );
    final addressMatch = addressRegex.firstMatch(text);
    if (addressMatch != null) {
      String street = addressMatch.group(1)?.trim() ?? '';
      String plz = addressMatch.group(2)?.trim() ?? '';
      String city = addressMatch.group(3)?.trim() ?? '';
      final streetLines = street.split('\n');
      street = streetLines.last.trim();
      if (street.length < 50 && city.length < 50) {
        foundAddress = FieldResult(
          value: '$street, $plz $city',
          confidence: 0.7,
          source: 'regex_address',
        );
      }
    }

    // URL
    final urlRegex = RegExp(
      r'(https?://)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z]{2,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    for (final match in urlRegex.allMatches(text)) {
      String? url = match.group(0);
      if (url != null && !url.contains('@')) {
        foundUrl = FieldResult(
          value: url.replaceAll(RegExp(r'[)\.]+$'), ''),
          confidence: 0.6,
          source: 'regex_url',
        );
        break;
      }
    }

    return ExtractedFields(
      position: foundPosition,
      company: foundCompany,
      contactEmail: foundEmail,
      contactPhone: foundPhone,
      contactName: foundContact,
      address: foundAddress,
      applicationDate: foundDate,
      companyUrl: foundUrl,
      notes: const FieldResult(
        value: 'PDF importiert. Bitte manuell prüfen, ob alle Felder korrekt ausgelesen wurden.',
        confidence: 1.0,
        source: 'system',
      ),
    );
  }
}

