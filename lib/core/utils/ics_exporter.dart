import 'dart:convert';
import 'dart:io';
import 'package:career_center/domain/entities/application_entity.dart';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';


/// Exportiert Wiedervorlage-/Interview-Termine als iCalendar-Datei (RFC 5545).
class IcsExporter {
  static final _dateFormat = DateFormat("yyyyMMdd'T'HHmmss'Z'");
  static final _dayFormat = DateFormat('yyyyMMdd');

  /// Maskiert Text für iCalendar-TEXT-Werte (RFC 5545, 3.3.11):
  /// Backslash, Semikolon, Komma und Zeilenumbrüche.
  static String escapeText(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\r\n', '\\n')
        .replaceAll('\r', '\\n')
        .replaceAll('\n', '\\n');
  }

  /// Faltet eine Inhaltszeile auf max. 75 Oktette (UTF-8) pro physischer
  /// Zeile, ohne Multibyte-Zeichen zu zerteilen (RFC 5545, 3.1).
  static String foldLine(String line) {
    final out = StringBuffer();
    var lineBytes = 0;
    var limit = 75;
    for (final rune in line.runes) {
      final char = String.fromCharCode(rune);
      final charBytes = utf8.encode(char).length;
      if (lineBytes + charBytes > limit) {
        out.write('\r\n ');
        // Das führende Leerzeichen zählt zur Zeilenlänge
        lineBytes = 1;
        limit = 75;
      }
      out.write(char);
      lineBytes += charBytes;
    }
    return out.toString();
  }

  /// Stabile UID pro Bewerbung und Termin-Art (unabhängig vom Datum), damit
  /// ein erneuter Import das Ereignis aktualisiert statt es zu duplizieren.
  static String uidFor(int appId, String kind) =>
      'careercenter-$appId-$kind@bewerbungszentrale';

  static void _writeLine(StringBuffer buffer, String line) {
    buffer.write(foldLine(line));
    buffer.write('\r\n');
  }

  static void _writeEvent(
    StringBuffer buffer,
    ApplicationEntity app, {
    required String summary,
    required DateTime now,
  }) {
    // Ganztägiger Termin am (lokalen) Follow-up-Datum.
    final local = app.followupDate!.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    final nextDay = DateTime(day.year, day.month, day.day + 1);

    _writeLine(buffer, 'BEGIN:VEVENT');
    _writeLine(buffer, 'UID:${uidFor(app.id, 'followup')}');
    _writeLine(buffer, 'DTSTAMP:${_dateFormat.format(now.toUtc())}');
    _writeLine(buffer, 'DTSTART;VALUE=DATE:${_dayFormat.format(day)}');
    _writeLine(buffer, 'DTEND;VALUE=DATE:${_dayFormat.format(nextDay)}');
    _writeLine(buffer, 'SUMMARY:${escapeText(summary)}');

    final description = StringBuffer(
      'Bewerbung als ${app.position}\nStatus: ${app.status}',
    );
    if (app.jobUrl != null && app.jobUrl!.isNotEmpty) {
      description.write('\nURL: ${app.jobUrl}');
    }
    _writeLine(buffer, 'DESCRIPTION:${escapeText(description.toString())}');

    if (app.address != null && app.address!.trim().isNotEmpty) {
      final location = app.address!
          .split(RegExp(r'\r?\n|\r'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .join(', ');
      _writeLine(buffer, 'LOCATION:${escapeText(location)}');
    }

    _writeLine(buffer, 'END:VEVENT');
  }

  static void _writeCalendarStart(StringBuffer buffer) {
    _writeLine(buffer, 'BEGIN:VCALENDAR');
    _writeLine(buffer, 'VERSION:2.0');
    _writeLine(buffer, 'PRODID:-//JobTracker//CareerCenter//DE');
  }

  /// Baut den Kalender für den Wiedervorlage-Termin einer Bewerbung.
  static String buildFollowupCalendar(ApplicationEntity app, {DateTime? now}) {
    final buffer = StringBuffer();
    _writeCalendarStart(buffer);
    _writeEvent(
      buffer,
      app,
      summary: 'Vorstellungsgespräch bei ${app.company}',
      now: now ?? DateTime.now(),
    );
    _writeLine(buffer, 'END:VCALENDAR');
    return buffer.toString();
  }

  /// Baut einen Kalender mit allen Bewerbungen, die ein Wiedervorlage-Datum haben.
  static String buildCalendar(List<ApplicationEntity> apps, {DateTime? now}) {
    final stamp = now ?? DateTime.now();
    final buffer = StringBuffer();
    _writeCalendarStart(buffer);
    for (final app in apps.where((a) => a.followupDate != null)) {
      // Determine if it's an interview based on status
      final status = app.status.toLowerCase();
      final isInterview =
          status.contains('interview') || status.contains('gespräch');
      final summaryPrefix = isInterview ? 'Interview' : 'Follow-up';
      _writeEvent(
        buffer,
        app,
        summary: '$summaryPrefix bei ${app.company}',
        now: stamp,
      );
    }
    _writeLine(buffer, 'END:VCALENDAR');
    return buffer.toString();
  }

  static Future<bool> exportFollowupDate(ApplicationEntity app) async {
    if (app.followupDate == null) return false;

    final ics = buildFollowupCalendar(app);

    // Prompt user to save the file
    String fileName = 'Interview_${app.company.replaceAll(' ', '_')}.ics';

    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'iCalendar', extensions: ['ics']),
      ],
      suggestedName: fileName,
    );

    if (saveLocation == null) return false; // Canceled

    final file = File(saveLocation.path);
    await file.writeAsString(ics);
    return true;
  }

  static Future<bool> exportAll(List<ApplicationEntity> apps) async {
    final events = apps.where((a) => a.followupDate != null).toList();
    if (events.isEmpty) return false;

    final ics = buildCalendar(events);

    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'iCalendar', extensions: ['ics']),
      ],
      suggestedName: 'Bewerbungskalender.ics',
    );

    if (saveLocation == null) return false;

    final file = File(saveLocation.path);
    await file.writeAsString(ics);
    return true;
  }
}
