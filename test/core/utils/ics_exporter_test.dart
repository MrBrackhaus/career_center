import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/utils/ics_exporter.dart';
import 'package:career_center/domain/entities/application_entity.dart';

ApplicationEntity _app({
  int id = 7,
  String company = 'Müller, Schmidt & Partner; Steuerberater',
  String position = 'Steuerfachangestellte (m/w/d)',
  String status = 'interview',
  String? address = 'Hauptstraße 5\n50667 Köln',
  String? jobUrl = 'https://example.de/jobs/42',
  DateTime? followupDate,
}) {
  final now = DateTime(2026, 10, 1);
  return ApplicationEntity(
    id: id,
    company: company,
    position: position,
    status: status,
    priority: 2,
    address: address,
    jobUrl: jobUrl,
    followupDate: followupDate ?? DateTime.utc(2026, 10, 12, 8, 30),
    createdAt: now,
    updatedAt: now,
  );
}

/// Entfaltet gefaltete Zeilen (RFC 5545, 3.1).
String _unfold(String ics) => ics.replaceAll('\r\n ', '');

void main() {
  group('IcsExporter', () {
    test('escapeText maskiert Backslash, Semikolon, Komma und Zeilenumbrüche', () {
      expect(IcsExporter.escapeText(r'a\b;c,d' '\n' 'e\r\nf'),
          r'a\\b\;c\,d\ne\nf');
    });

    test('Kalender nutzt CRLF, keine nackten LF und Zeilen <= 75 Oktette', () {
      final ics = IcsExporter.buildCalendar([
        _app(position: 'Sehr lange Stellenbezeichnung für die Überprüfung des Zeilenumbruchs nach fünfundsiebzig Oktetten äöüß' * 2),
      ], now: DateTime.utc(2026, 10, 1, 12));
      expect(ics, endsWith('\r\n'));
      expect(ics.replaceAll('\r\n', ''), isNot(contains('\n')));
      for (final line in ics.split('\r\n')) {
        expect(utf8.encode(line).length, lessThanOrEqualTo(75), reason: line);
      }
      // Faltung darf keine Multibyte-Zeichen zerreißen
      expect(_unfold(ics), contains('äöüß'));
    });

    test('SUMMARY, DESCRIPTION und LOCATION sind korrekt maskiert', () {
      final ics = _unfold(IcsExporter.buildCalendar([_app()],
          now: DateTime.utc(2026, 10, 1, 12)));
      expect(ics, contains(r'SUMMARY:Interview bei Müller\, Schmidt & Partner\; Steuerberater'));
      expect(ics, contains(r'LOCATION:Hauptstraße 5\, 50667 Köln'));
      expect(ics, contains(r'DESCRIPTION:Bewerbung als Steuerfachangestellte (m/w/d)\nStatus: interview\nURL: https://example.de/jobs/42'));
    });

    test('UID ist stabil und unabhängig vom Termin, DTSTAMP vorhanden', () {
      final a = _unfold(IcsExporter.buildCalendar(
          [_app(followupDate: DateTime.utc(2026, 10, 12, 8))],
          now: DateTime.utc(2026, 10, 1, 12)));
      final b = _unfold(IcsExporter.buildCalendar(
          [_app(followupDate: DateTime.utc(2026, 11, 3, 14))],
          now: DateTime.utc(2026, 10, 2, 12)));
      final uidA = RegExp(r'UID:(.*)\r\n').firstMatch(a)!.group(1);
      final uidB = RegExp(r'UID:(.*)\r\n').firstMatch(b)!.group(1);
      expect(uidA, 'careercenter-7-followup@bewerbungszentrale');
      expect(uidA, uidB);
      expect(a, contains('DTSTAMP:20261001T120000Z'));
      expect(a, contains('DTSTART;VALUE=DATE:20261012'));
      expect(a, contains('DTEND;VALUE=DATE:20261013'));
    });

    test('Einzel-Export hat dieselbe UID wie der Gesamt-Export', () {
      final single = _unfold(IcsExporter.buildFollowupCalendar(_app(),
          now: DateTime.utc(2026, 10, 1, 12)));
      expect(single, contains('UID:careercenter-7-followup@bewerbungszentrale\r\n'));
      expect(single, contains('BEGIN:VCALENDAR\r\n'));
      expect(single, contains('END:VCALENDAR\r\n'));
    });
  });
}
