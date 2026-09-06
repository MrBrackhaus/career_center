import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_selector/file_selector.dart';
import '../../data/database/app_database.dart';

class CsvGenerator {
  static Future<void> generateAndShareCsv(List<Application> applications) async {
    List<List<dynamic>> rows = [
      ['Datum', 'Firma', 'Position', 'Status', 'Absagegrund']
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

    String csv = rows.map((r) => r.map((e) => '"${e.toString().replaceAll('"', '""')}"').join(',')).join('\n');

    final saveLocation = await getSaveLocation(
      suggestedName: 'bewerbungen.csv',
    );

    if (saveLocation != null) {
      final file = File(saveLocation.path);
      await file.writeAsString(csv);
    }
  }
}

