import 'dart:io';
import 'package:career_center/domain/entities/application_entity.dart';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';


class IcsExporter {
  static Future<bool> exportFollowupDate(ApplicationEntity app) async {
    if (app.followupDate == null) return false;

    // Format timestamps for ICS: YYYYMMDDTHHMMSSZ (UTC)
    final dateFormat = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    
    // We assume followupDate is local, convert to UTC for ICS
    final start = app.followupDate!.toUtc();
    final end = start.add(const Duration(hours: 1)); // Default 1 hour
    final now = DateTime.now().toUtc();

    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//JobTracker//CareerCenter//DE');
    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:careercenter-${app.id}-${start.millisecondsSinceEpoch}@localhost');
    buffer.writeln('DTSTAMP:${dateFormat.format(now)}');
    buffer.writeln('DTSTART:${dateFormat.format(start)}');
    buffer.writeln('DTEND:${dateFormat.format(end)}');
    buffer.writeln('SUMMARY:Vorstellungsgespräch bei ${app.company}');
    
    // Prepare description and location
    String description = 'Bewerbung als ${app.position}\\nStatus: ${app.status}';
    if (app.jobUrl != null && app.jobUrl!.isNotEmpty) {
      description += '\\nURL: ${app.jobUrl}';
    }
    buffer.writeln('DESCRIPTION:$description');
    
    if (app.address != null && app.address!.isNotEmpty) {
      buffer.writeln('LOCATION:${app.address!.replaceAll('\\n', ', ')}');
    }
    
    buffer.writeln('END:VEVENT');
    buffer.writeln('END:VCALENDAR');

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
    await file.writeAsString(buffer.toString());
    return true;
  }

  static Future<bool> exportAll(List<ApplicationEntity> apps) async {
    final events = apps.where((a) => a.followupDate != null).toList();
    if (events.isEmpty) return false;

    final dateFormat = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    final now = DateTime.now().toUtc();
    final buffer = StringBuffer();
    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//JobTracker//CareerCenter//DE');

    for (final app in events) {
      final start = app.followupDate!.toUtc();
      final end = start.add(const Duration(hours: 1));
      
      buffer.writeln('BEGIN:VEVENT');
      buffer.writeln('UID:careercenter-${app.id}-${start.millisecondsSinceEpoch}@localhost');
      buffer.writeln('DTSTAMP:${dateFormat.format(now)}');
      buffer.writeln('DTSTART:${dateFormat.format(start)}');
      buffer.writeln('DTEND:${dateFormat.format(end)}');
      
      // Determine if it's an interview based on status
      final isInterview = app.status.toLowerCase().contains('interview') || 
                          app.status.toLowerCase().contains('gespräch');
      final summaryPrefix = isInterview ? 'Interview' : 'Follow-up';
      buffer.writeln('SUMMARY:$summaryPrefix bei ${app.company}');
      
      String description = 'Bewerbung als ${app.position}\\nStatus: ${app.status}';
      if (app.jobUrl != null && app.jobUrl!.isNotEmpty) {
        description += '\\nURL: ${app.jobUrl}';
      }
      buffer.writeln('DESCRIPTION:$description');
      
      if (app.address != null && app.address!.isNotEmpty) {
        buffer.writeln('LOCATION:${app.address!.replaceAll('\\n', ', ')}');
      }
      
      buffer.writeln('END:VEVENT');
    }
    buffer.writeln('END:VCALENDAR');

    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'iCalendar', extensions: ['ics']),
      ],
      suggestedName: 'Bewerbungskalender.ics',
    );

    if (saveLocation == null) return false;

    final file = File(saveLocation.path);
    await file.writeAsString(buffer.toString());
    return true;
  }
}
