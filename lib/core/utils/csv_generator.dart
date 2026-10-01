/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../../domain/entities/application_entity.dart';

class CsvGenerator {
  /// Escapes a CSV cell value to prevent CSV injection attacks.
  /// Prefixes cells starting with =, +, -, @ with an apostrophe to prevent
  /// Excel from interpreting them as formulas.
  static String _escapeCsvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    if (escaped.startsWith('=') ||
        escaped.startsWith('+') ||
        escaped.startsWith('-') ||
        escaped.startsWith('@')) {
      return '"\'$escaped"';
    }
    return '"$escaped"';
  }

  static Future<void> generateAndShareCsv(
    List<ApplicationEntity> applications,
  ) async {
    List<List<dynamic>> rows = [
      ['Datum', 'Firma', 'Position', 'Status', 'Absagegrund'],
    ];

    for (var app in applications) {
      rows.add([
        app.appliedDate?.toIso8601String() ?? '',
        app.company,
        app.position,
        app.status,
        app.rejectionReason ?? '',
      ]);
    }

    String csv = rows
        .map(
          (r) => r.map((e) => _escapeCsvCell(e.toString())).join(';'),
        )
        .join('\n');

    final saveLocation = await getSaveLocation(
      suggestedName: 'bewerbungen.csv',
    );

    if (saveLocation != null) {
      final file = File(saveLocation.path);
      // Write with UTF-8 BOM so Excel correctly displays Umlauts (ä, ö, ü)
      await file.writeAsString('\uFEFF$csv');
    }
  }
}
