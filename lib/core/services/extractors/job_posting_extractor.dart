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
  static ExtractedFields extractFromHtml(String htmlString) {
    try {
      final document = html_parser.parse(htmlString);
      final scriptTags = document.querySelectorAll('script[type="application/ld+json"]');
      
      for (final script in scriptTags) {
        final text = script.text;
        if (text.contains('"JobPosting"') || text.contains("'JobPosting'")) {
          // Parse JSON
          dynamic jsonLd;
          try {
            jsonLd = jsonDecode(text);
          } catch (_) {
            continue;
          }
          
          if (jsonLd is List) {
            jsonLd = jsonLd.firstWhere((e) => e['@type'] == 'JobPosting', orElse: () => null);
          }
          
          if (jsonLd != null && jsonLd['@type'] == 'JobPosting') {
            final position = jsonLd['title']?.toString();
            final companyNode = jsonLd['hiringOrganization'];
            String? company;
            if (companyNode is Map) {
              company = companyNode['name']?.toString();
            } else {
              company = companyNode?.toString();
            }
            
            final locationNode = jsonLd['jobLocation'];
            String? address;
            if (locationNode is Map && locationNode['address'] != null) {
              final addr = locationNode['address'];
              if (addr is Map) {
                final locality = addr['addressLocality']?.toString() ?? '';
                final region = addr['addressRegion']?.toString() ?? '';
                final country = addr['addressCountry']?.toString() ?? '';
                address = [locality, region, country].where((e) => e.isNotEmpty).join(', ');
              }
            } else if (locationNode is List && locationNode.isNotEmpty) {
              final addr = locationNode[0]['address'];
              if (addr is Map) {
                address = addr['addressLocality']?.toString() ?? '';
              }
            }
            
            final salaryNode = jsonLd['baseSalary'];
            String? salary;
            if (salaryNode is Map && salaryNode['value'] != null) {
              final val = salaryNode['value'];
              if (val is Map) {
                salary = " -  ";
              } else {
                salary = val.toString();
              }
            }
            
            return ExtractedFields(
              position: position != null ? FieldResult(value: position, confidence: 1.0, source: 'schema.org') : null,
              company: company != null ? FieldResult(value: company, confidence: 1.0, source: 'schema.org') : null,
              address: address != null && address.isNotEmpty ? FieldResult(value: address, confidence: 1.0, source: 'schema.org') : null,
              salaryInfo: salary != null ? FieldResult(value: salary, confidence: 1.0, source: 'schema.org') : null,
            );
          }
        }
      }
      
      // Fallback: Strip HTML and use plain text extractor
      final plainText = document.body?.text ?? htmlString;
      return extract(plainText);
    } catch (e) {
      return extract(htmlString);
    }
  }

  /// Extrahiert Daten aus einer Stellenanzeige.
  static ExtractedFields extract(String text) {
    final lines = text.split('\n').map((l) => l.trim()).toList();
    final nonEmptyLines = lines.where((l) => l.isNotEmpty).toList();

    FieldResult<String>? foundPosition;
    final titleRegex = RegExp(r'(.*?)\s*\([mwfd]\/[mwfd]\/[mwfd]\)', caseSensitive: false);
    for (final line in nonEmptyLines) {
      final match = titleRegex.firstMatch(line);
      if (match != null) {
        foundPosition = FieldResult(
          value: line,
          confidence: 0.95,
          source: 'title_with_gender',
        );
        break;
      }
    }
    if (foundPosition == null && nonEmptyLines.isNotEmpty) {
      foundPosition = FieldResult(
        value: nonEmptyLines[0],
        confidence: 0.5,
        source: 'first_line_fallback',
      );
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ Firma Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    FieldResult<String>? foundCompany;
    final legalForms = RegExp(
      r'(GmbH(?:\s*&\s*Co\.\s*KG)?|AG|KG|SE|mbH|e\.V\.|GbR|OHG)$',
      caseSensitive: false,
    );
    for (final line in nonEmptyLines) {
      if (legalForms.hasMatch(line)) {
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
        if (lower == 'Ã¼ber uns' || lower == 'wir sind' || lower == 'unternehmen') {
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

    // Ã¢â€â‚¬Ã¢â€â‚¬ Gehalt Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    FieldResult<String>? foundSalary;
    final salaryPatterns = RegExp(
      r'(Gehalt|VergÃ¼tung)[\s:]*([0-9.,]+.*?(EUR|Ã¢â€šÂ¬))',
      caseSensitive: false,
    );
    for (final line in nonEmptyLines) {
      final match = salaryPatterns.firstMatch(line);
      if (match != null) {
        foundSalary = FieldResult(
          value: match.group(0)!,
          confidence: 0.85,
          source: 'explicit_salary',
        );
        break;
      }
      if (line.toLowerCase().contains('gehalt') ||
          line.toLowerCase().contains('vergÃ¼tung') ||
          line.contains('Ã¢â€šÂ¬') ||
          line.toLowerCase().contains('eur')) {
        foundSalary = FieldResult(
          value: line,
          confidence: 0.7,
          source: 'salary_keyword',
        );
        break;
      }
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ Kontaktperson Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    FieldResult<String>? foundContact;
    
    // Suche nach HR-Begriffen oder Ansprechpartner in der NÃ¤he von Namen
    final hrRoles = ['hr manager', 'recruiter', 'personalreferent', 'talent acquisition', 'ansprechpartner', 'kontakt', 'z.hd.', 'zu hÃ¤nden'];
    for (int i = 0; i < nonEmptyLines.length; i++) {
      final line = nonEmptyLines[i];
      final lower = line.toLowerCase();
      
      bool hasHrRole = hrRoles.any((r) => lower.contains(r));
      
      if (hasHrRole) {
        // Regex fÃ¼r Namen: optional Titel, optional Herr/Frau, dann 2+ groÃŸgeschriebene WÃ¶rter
        final nameRegex = RegExp(r'(?:(?:Frau|Herr|Mr\.|Mrs\.|Ms\.)\s+)?(?:(?:Dr\.|Prof\.)\s+)?([A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ]+\s+[A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ]+(?:\s+[A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ]+)?)');
        
        // PrÃ¼fe aktuelle Zeile
        final match = nameRegex.firstMatch(line);
        if (match != null && !lower.startsWith('kontakt')) { // Vermeide, dass das Wort "Kontakt" selbst matcht, wenn es kein Name ist.
          foundContact = FieldResult(value: match.group(0)!, confidence: 0.9, source: 'contact_hr_role_line');
          break;
        }
        
        // PrÃ¼fe nÃ¤chste 1-2 Zeilen
        if (i + 1 < nonEmptyLines.length) {
          final nextMatch = nameRegex.firstMatch(nonEmptyLines[i+1]);
          if (nextMatch != null) {
            foundContact = FieldResult(value: nextMatch.group(0)!, confidence: 0.8, source: 'contact_hr_role_next_line');
            break;
          }
        }
      }
    }
    
    // Fallback: Suche einfach nach Frau/Herr Dr. Max Mustermann im gesamten Text
    if (foundContact == null) {
      final contactRegexFallback = RegExp(
        r'(Frau|Herr)\s+(?:Dr\.\s+|Prof\.\s+)?([A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ]+\s+[A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ]+)',
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

    // Ã¢â€â‚¬Ã¢â€â‚¬ E-Mail Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    FieldResult<String>? foundEmail;
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
    final emailMatch = emailRegex.firstMatch(text);
    if (emailMatch != null) {
      foundEmail = FieldResult(
        value: emailMatch.group(0)!,
        confidence: 0.9,
        source: 'email_regex',
      );
    }

    // Ã¢â€â‚¬Ã¢â€â‚¬ Telefon Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    FieldResult<String>? foundPhone;
    final phoneRegex = RegExp(r'(\+49|0)[1-9][0-9\-\s/]{6,}');
    final phoneMatch = phoneRegex.firstMatch(text);
    if (phoneMatch != null) {
      foundPhone = FieldResult(
        value: phoneMatch.group(0)!.trim(),
        confidence: 0.9,
        source: 'phone_regex',
      );
    }

    // â”€â”€ Standort / Adresse â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    FieldResult<String>? foundAddress;
    
    // Volle Adresse mit StraÃŸe und PLZ/Ort finden
    final fullAddressRegex = RegExp(
      r'([A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ\s.-]+(?:str\.|straÃŸe|weg|platz|allee|ring)\s+\d+[a-zA-Z]?)[,\s]+(\d{5})\s+([A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ-]+)',
    );
    final fullMatch = fullAddressRegex.firstMatch(text);
    
    if (fullMatch != null) {
      String street = fullMatch.group(1)?.trim() ?? '';
      String plz = fullMatch.group(2)?.trim() ?? '';
      String city = fullMatch.group(3)?.trim() ?? '';
      street = street.split('\n').last.trim();
      
      foundAddress = FieldResult(
        value: "$street, $plz $city",
        confidence: 0.95,
        source: 'full_address_regex',
      );
    } else {
      // Fallback: Nur PLZ und Stadt
      final plzCityRegex = RegExp(r'\b(\d{5})\s+([A-ZÃ„Ã–Ãœ][a-zA-ZÃ¤Ã¶Ã¼ÃŸ-]+)\b');
      final plzMatch = plzCityRegex.firstMatch(text);
      if (plzMatch != null) {
        foundAddress = FieldResult(
          value: '${plzMatch.group(1)} ',
          confidence: 0.8,
          source: 'plz_city_regex',
        );
      }
    }
    // Ã¢â€â‚¬Ã¢â€â‚¬ URL Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
    FieldResult<String>? foundUrl;
    final urlRegex = RegExp(r'https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}[/a-zA-Z0-9._~:/?#\[\]@!$&()*+,;=-]*');
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



