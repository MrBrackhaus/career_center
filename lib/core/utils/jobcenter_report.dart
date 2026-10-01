/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import '../../domain/entities/application_entity.dart';
import '../../domain/enums/application_status.dart';

/// Gemeinsame Logik für den Jobcenter-Nachweis (Bildschirm und PDF), damit
/// beide exakt dieselben Bewerbungen und Texte zeigen.
class JobcenterReport {
  JobcenterReport._();

  static const List<String> headers = [
    'Bewerbungsdatum',
    'Firma / Adresse',
    'Ansprechpartner',
    'Position',
    'Art der Bewerbung',
    'Aktivitäten',
    'Status / Ergebnis',
  ];

  /// Standardzeitraum: der aktuelle Kalendermonat (erster bis letzter Tag).
  static ({DateTime from, DateTime to}) currentMonth([DateTime? now]) {
    final n = now ?? DateTime.now();
    return (
      from: DateTime(n.year, n.month, 1),
      to: DateTime(n.year, n.month + 1, 0),
    );
  }

  /// Filtert auf tatsächlich versendete Bewerbungen (Bewerbungsdatum gesetzt,
  /// Status nicht "offen") im Zeitraum [from]..[to] (beide Tage inklusive)
  /// und sortiert aufsteigend nach Bewerbungsdatum.
  ///
  /// Ohne Zeitraum werden alle versendeten Bewerbungen geliefert.
  static List<ApplicationEntity> filter(
    Iterable<ApplicationEntity> applications, {
    DateTime? from,
    DateTime? to,
  }) {
    final start = from == null ? null : DateTime(from.year, from.month, from.day);
    // Exklusive Obergrenze: Beginn des Folgetags (Kalenderarithmetik, DST-sicher).
    final endExclusive =
        to == null ? null : DateTime(to.year, to.month, to.day + 1);

    final result = applications.where((app) {
      final applied = app.appliedDate;
      if (applied == null) return false;
      if (normalizeApplicationStatus(app.status) == ApplicationStatus.offen) {
        return false;
      }
      if (start != null && applied.isBefore(start)) return false;
      if (endExclusive != null && !applied.isBefore(endExclusive)) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.appliedDate!.compareTo(b.appliedDate!));
    return result;
  }

  static String formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  /// Art der Bewerbung. Es gibt kein explizites Feld dafür; daher wird nur bei
  /// eindeutigem Hinweis (Kontakt-E-Mail vorhanden, keine Stellen-URL)
  /// "E-Mail" angegeben, sonst "-". Eine Stellen-URL bedeutet nicht, dass über
  /// ein Online-Portal beworben wurde.
  static String applicationMethod(ApplicationEntity app) {
    final hasEmail = (app.contactEmail ?? '').trim().isNotEmpty;
    final hasUrl = (app.jobUrl ?? '').trim().isNotEmpty;
    if (hasEmail && !hasUrl) return 'E-Mail';
    return '-';
  }

  /// Aktivitäten. Ein Nachfassdatum in der Zukunft ist nur geplant und wird
  /// nicht als "Nachgefasst" ausgewiesen.
  static String activities(ApplicationEntity app, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final lines = <String>[];
    final followup = app.followupDate;
    if (followup != null) {
      if (!followup.isAfter(n)) {
        lines.add('Nachgefasst am: ${formatDate(followup)}');
      } else {
        lines.add('Erinnerung geplant: ${formatDate(followup)}');
      }
    }
    final status = normalizeApplicationStatus(app.status);
    final nextStep = app.nextStep?.trim();
    if (status == ApplicationStatus.interview ||
        (nextStep != null && nextStep.toLowerCase().contains('gespräch'))) {
      lines.add('Gespräch: ${nextStep == null || nextStep.isEmpty ? 'Ja' : nextStep}');
    }
    return lines.isEmpty ? '-' : lines.join('\n');
  }

  static String statusLabel(String raw) {
    switch (normalizeApplicationStatus(raw)) {
      case ApplicationStatus.versendet:
        return 'Versendet';
      case ApplicationStatus.interview:
        return 'Vorstellungsgespräch';
      case ApplicationStatus.zusage:
        return 'Zusage';
      case ApplicationStatus.absage:
        return 'Absage';
      case ApplicationStatus.offen:
        return 'Offen';
      default:
        return raw;
    }
  }

  static String result(ApplicationEntity app) {
    var text = statusLabel(app.status);
    final reason = app.rejectionReason?.trim();
    if (normalizeApplicationStatus(app.status) == ApplicationStatus.absage &&
        reason != null &&
        reason.isNotEmpty) {
      text += '\nGrund: $reason';
    }
    return text;
  }

  /// Eine Tabellenzeile (in der Reihenfolge von [headers]).
  static List<String> row(ApplicationEntity app, {DateTime? now}) {
    final companyBlock = [
      app.company,
      if ((app.address ?? '').trim().isNotEmpty) app.address!.trim(),
    ].join('\n');
    final contactBlock = [
      for (final v in [app.contactName, app.contactEmail, app.contactPhone])
        if ((v ?? '').trim().isNotEmpty) v!.trim(),
    ].join('\n');
    return [
      app.appliedDate != null ? formatDate(app.appliedDate!) : '-',
      companyBlock,
      contactBlock.isNotEmpty ? contactBlock : '-',
      app.position,
      applicationMethod(app),
      activities(app, now: now),
      result(app),
    ];
  }
}
