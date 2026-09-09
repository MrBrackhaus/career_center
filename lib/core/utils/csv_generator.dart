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
import 'dart:io';

import 'package:file_selector/file_selector.dart';

import '../../data/database/app_database.dart';

class CsvGenerator {
  static Future<void> generateAndShareCsv(
    List<Application> applications,
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
          (r) =>
              r.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(','),
        )
        .join('\n');

    final saveLocation = await getSaveLocation(
      suggestedName: 'bewerbungen.csv',
    );

    if (saveLocation != null) {
      final file = File(saveLocation.path);
      await file.writeAsString(csv);
    }
  }
}
