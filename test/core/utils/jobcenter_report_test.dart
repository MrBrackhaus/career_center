import 'dart:io';
import 'dart:typed_data';

import 'package:career_center/core/utils/jobcenter_report.dart';
import 'package:career_center/core/utils/pdf_fonts.dart';
import 'package:career_center/core/utils/pdf_generator.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import 'package:flutter_test/flutter_test.dart';

ApplicationEntity _app(
  int id, {
  String status = 'versendet',
  DateTime? applied,
  DateTime? followup,
  String? jobUrl,
  String? contactEmail,
  String company = 'Firma',
}) {
  final created = DateTime(2026, 1, 1);
  return ApplicationEntity(
    id: id,
    company: company,
    position: 'Position',
    status: status,
    priority: 1,
    appliedDate: applied,
    followupDate: followup,
    jobUrl: jobUrl,
    contactEmail: contactEmail,
    createdAt: created,
    updatedAt: created,
  );
}

void main() {
  group('JobcenterReport.filter', () {
    test('nur versendete Bewerbungen im inklusiven Zeitraum, sortiert', () {
      final apps = [
        _app(1, applied: DateTime(2026, 9, 30, 23, 59)),
        _app(2, applied: DateTime(2026, 9, 1)),
        _app(3, applied: DateTime(2026, 8, 31, 23, 59)), // vor Zeitraum
        _app(4, applied: DateTime(2026, 10, 1)), // nach Zeitraum
        _app(5, status: 'offen', applied: DateTime(2026, 9, 10)),
        _app(6), // kein Bewerbungsdatum
        _app(7, status: 'absage', applied: DateTime(2026, 9, 15)),
      ];
      final result = JobcenterReport.filter(apps,
          from: DateTime(2026, 9, 1), to: DateTime(2026, 9, 30));
      expect(result.map((a) => a.id), [2, 7, 1]);
    });

    test('Standardzeitraum ist der aktuelle Monat', () {
      final m = JobcenterReport.currentMonth(DateTime(2026, 2, 14));
      expect(m.from, DateTime(2026, 2, 1));
      expect(m.to, DateTime(2026, 2, 28));
    });
  });

  group('JobcenterReport Texte', () {
    test('Ansprechpartner aus Kontakten, wenn an der Bewerbung keiner steht', () {
      final row = JobcenterReport.row(_app(1, applied: DateTime(2026, 9, 1)),
          fallbackContact: 'Frau Beispiel');
      expect(row[2], 'Frau Beispiel');
      expect(JobcenterReport.row(_app(1, applied: DateTime(2026, 9, 1)))[2], '-');
    });

    final now = DateTime(2026, 10, 1, 12);

    test('Nachgefasst nur für vergangene Daten', () {
      expect(
        JobcenterReport.activities(
            _app(1, followup: DateTime(2026, 9, 20)), now: now),
        'Nachgefasst am: 20.09.2026',
      );
      expect(
        JobcenterReport.activities(
            _app(1, followup: DateTime(2026, 10, 20)), now: now),
        'Erinnerung geplant: 20.10.2026',
      );
    });

    test('Bewerbungsart wird nicht aus der Stellen-URL geraten', () {
      expect(JobcenterReport.applicationMethod(_app(1, jobUrl: 'https://x')), '-');
      expect(
          JobcenterReport.applicationMethod(
              _app(1, jobUrl: 'https://x', contactEmail: 'a@b.de')),
          '-');
      expect(
          JobcenterReport.applicationMethod(_app(1, contactEmail: 'a@b.de')),
          'E-Mail');
      expect(JobcenterReport.applicationMethod(_app(1)), '-');
    });
  });

  test('PDF mit Unicode-Schrift rendert Sonderzeichen', () async {
    final regular = File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync();
    final bold = File('assets/fonts/NotoSans-Bold.ttf').readAsBytesSync();
    final fonts = PdfFontData(
      regular: ByteData.sublistView(regular),
      bold: ByteData.sublistView(bold),
    );
    final bytes = await PdfGenerator.buildReportBytes(
      [
        _app(1,
            applied: DateTime(2026, 9, 2),
            company: 'Łódź Sp. z o.o. – „Gehalt“ 50.000 € · İstanbul Şirketi · ООО Ромашка'),
      ],
      fonts: fonts,
      userName: 'Zoë Ğül',
    );
    expect(bytes.length, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
