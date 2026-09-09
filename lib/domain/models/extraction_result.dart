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
import '../enums/document_type.dart';

/// Quelle des analysierten Dokuments.
enum DocumentSource { pdf, email, url, text }

/// Ergebnis eines einzelnen extrahierten Feldes mit Konfidenz-Score.
class FieldResult<T> {
  /// Der extrahierte Wert.
  final T value;

  /// Konfidenz des extrahierten Wertes (0.0 = unsicher, 1.0 = sicher).
  final double confidence;

  /// Herkunft der Erkennung, z.B. "regex_subject", "domain_extraction", "schema_org".
  final String source;

  const FieldResult({
    required this.value,
    required this.confidence,
    this.source = 'unknown',
  });

  @override
  String toString() =>
      'FieldResult(value: $value, confidence: ${(confidence * 100).toStringAsFixed(0)}%, source: $source)';
}

/// Warnung bei der Dokumentenanalyse.
class ExtractionWarning {
  final String field;
  final String message;
  final double severity; // 0.0 = info, 1.0 = critical

  const ExtractionWarning({
    required this.field,
    required this.message,
    this.severity = 0.5,
  });
}

/// Alle extrahierten Felder eines Dokuments.
class ExtractedFields {
  final FieldResult<String>? company;
  final FieldResult<String>? position;
  final FieldResult<String>? contactName;
  final FieldResult<String>? contactEmail;
  final FieldResult<String>? contactPhone;
  final FieldResult<String>? address;
  final FieldResult<DateTime>? applicationDate;
  final FieldResult<String>? applicationStatus;
  final FieldResult<String>? companyUrl;
  final FieldResult<String>? jobUrl;
  final FieldResult<String>? salaryInfo;
  final FieldResult<String>? notes;

  const ExtractedFields({
    this.company,
    this.position,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.applicationDate,
    this.applicationStatus,
    this.companyUrl,
    this.jobUrl,
    this.salaryInfo,
    this.notes,
  });

  /// Durchschnittliche Konfidenz über alle gefüllten Felder.
  double get averageConfidence {
    final scores = <double>[];
    if (company != null) scores.add(company!.confidence);
    if (position != null) scores.add(position!.confidence);
    if (contactName != null) scores.add(contactName!.confidence);
    if (contactEmail != null) scores.add(contactEmail!.confidence);
    if (contactPhone != null) scores.add(contactPhone!.confidence);
    if (address != null) scores.add(address!.confidence);
    if (applicationDate != null) scores.add(applicationDate!.confidence);
    if (applicationStatus != null) scores.add(applicationStatus!.confidence);
    if (companyUrl != null) scores.add(companyUrl!.confidence);
    if (jobUrl != null) scores.add(jobUrl!.confidence);
    if (salaryInfo != null) scores.add(salaryInfo!.confidence);
    if (scores.isEmpty) return 0.0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Anzahl der erfolgreich extrahierten Felder.
  int get filledFieldCount {
    int count = 0;
    if (company != null) count++;
    if (position != null) count++;
    if (contactName != null) count++;
    if (contactEmail != null) count++;
    if (contactPhone != null) count++;
    if (address != null) count++;
    if (applicationDate != null) count++;
    if (applicationStatus != null) count++;
    if (companyUrl != null) count++;
    if (jobUrl != null) count++;
    if (salaryInfo != null) count++;
    return count;
  }
}

/// Gesamtergebnis der Dokumentenanalyse.
class ExtractionResult {
  /// Erkannter Dokumenttyp.
  final DocumentType documentType;

  /// Konfidenz der Dokumenttyp-Erkennung (0.0 – 1.0).
  final double typeConfidence;

  /// Alle extrahierten Felder.
  final ExtractedFields fields;

  /// Warnungen (z.B. niedriger Confidence, unklarer Firmenname).
  final List<ExtractionWarning> warnings;

  /// Quelle des Dokuments.
  final DocumentSource source;

  /// Rohtext des analysierten Dokuments (für späteres Online-Learning).
  final String rawText;

  const ExtractionResult({
    required this.documentType,
    required this.typeConfidence,
    required this.fields,
    this.warnings = const [],
    this.source = DocumentSource.text,
    this.rawText = '',
  });

  /// Ob die Erkennung als zuverlässig eingestuft wird (> 60%).
  bool get isReliable => typeConfidence > 0.6;

  /// Ob die Erkennung unsicher ist und Prüfung empfohlen wird (< 30%).
  bool get needsReview => typeConfidence < 0.3;

  @override
  String toString() =>
      'ExtractionResult(type: ${documentType.name}, confidence: ${(typeConfidence * 100).toStringAsFixed(0)}%, fields: ${fields.filledFieldCount})';
}
