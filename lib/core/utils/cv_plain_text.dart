/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:convert';

import '../../data/database/app_database.dart';
import '../../presentation/providers/cv_provider.dart';

/// Baut aus den gespeicherten Lebenslauf-Daten einen lesbaren Text, z. B. als
/// Kontext für das KI-Interviewtraining.
///
/// [cvContent] ist der JSON-Inhalt von `applications.cvContent`
/// (`cvProfile`, `letterHeader`, ggf. `legacyText`), [data] die Einträge aus
/// den Lebenslauf-Tabellen.
String buildCvPlainText(String? cvContent, CvDataState? data) {
  final lines = <String>[];

  final profile = _decodeProfile(cvContent);
  void addField(String label, Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) lines.add('$label: $text');
  }

  if (profile != null) {
    addField('Name', profile['name']);
    addField('Berufsbezeichnung', profile['title']);
    addField('Profil', profile['intro']);
  } else if (cvContent != null &&
      cvContent.trim().isNotEmpty &&
      !cvContent.trim().startsWith('{')) {
    lines.add(cvContent.trim());
  }

  final legacy = _decodeMap(cvContent)?['legacyText'];
  if (legacy is String && legacy.trim().isNotEmpty) lines.add(legacy.trim());

  if (data != null) {
    if (data.experiences.isNotEmpty) {
      lines.add('\nBerufserfahrung:');
      for (final e in data.experiences) {
        final period = _period(e.startDate, e.endDate, e.isCurrent);
        lines.add('- ${e.position} bei ${e.company}${period.isEmpty ? '' : ' ($period)'}');
        final d = e.description?.trim() ?? '';
        if (d.isNotEmpty) lines.add('  $d');
      }
    }
    if (data.educations.isNotEmpty) {
      lines.add('\nAusbildung:');
      for (final e in data.educations) {
        final period = _period(e.startDate, e.endDate, false);
        lines.add('- ${e.degree}, ${e.institution}${period.isEmpty ? '' : ' ($period)'}');
        final d = e.description?.trim() ?? '';
        if (d.isNotEmpty) lines.add('  $d');
      }
    }
    if (data.skills.isNotEmpty) {
      lines.add('\nKenntnisse: ${data.skills.map((s) => '${s.name} (${s.level}/5)').join(', ')}');
    }
    if (data.languages.isNotEmpty) {
      lines.add('Sprachen: ${data.languages.map((l) => '${l.name} (${l.level})').join(', ')}');
    }
    final bySection = <String, List<CvCustomItem>>{};
    for (final item in data.customItems) {
      bySection.putIfAbsent(item.sectionName, () => []).add(item);
    }
    bySection.forEach((section, items) {
      lines.add('\n$section:');
      for (final i in items) {
        final extra = [i.subtitle, i.dateRange]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .join(', ');
        lines.add('- ${i.title}${extra.isEmpty ? '' : ' ($extra)'}');
      }
    });
  }

  return lines.join('\n').trim();
}

Map<String, dynamic>? _decodeMap(String? content) {
  if (content == null || !content.trim().startsWith('{')) return null;
  try {
    final decoded = jsonDecode(content);
    return decoded is Map<String, dynamic> ? decoded : null;
  } catch (_) {
    return null;
  }
}

Map<String, dynamic>? _decodeProfile(String? content) {
  final profile = _decodeMap(content)?['cvProfile'];
  return profile is Map<String, dynamic> ? profile : null;
}

String _period(DateTime? start, DateTime? end, bool isCurrent) {
  String fmt(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';
  if (start == null && end == null && !isCurrent) return '';
  final from = start != null ? fmt(start) : '?';
  final to = isCurrent ? 'heute' : (end != null ? fmt(end) : '?');
  return '$from – $to';
}
