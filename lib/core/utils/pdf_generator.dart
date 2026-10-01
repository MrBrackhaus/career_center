/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_selector/file_selector.dart';

import '../../domain/entities/application_entity.dart';
import '../../data/repositories/settings_repository.dart';
import 'jobcenter_report.dart';
import 'pdf_fonts.dart';

Future<Uint8List> _buildPdf(Map<String, dynamic> data) async {
  final pdf = pw.Document();
  final applications = data['applications'] as List<ApplicationEntity>;
  final fonts = data['fonts'] as PdfFontData?;
  final now = data['now'] as DateTime;
  final periodLabel = data['periodLabel'] as String;
  final userName = data['userName'] as String;
  final userAddress = data['userAddress'] as String;
  final userZipCity = data['userZipCity'] as String;
  final userBirthdate = data['userBirthdate'] as String;
  final userEmail = data['userEmail'] as String;
  final userPhone = data['userPhone'] as String;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      theme: PdfFonts.themeFrom(fonts),
      build: (pw.Context context) {
        return [
          pw.Text(
            'Nachweis Eigenbemühungen (Bewerbungen)',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          if (periodLabel.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('Zeitraum: $periodLabel'),
          ],
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  if (userName.isNotEmpty)
                    pw.Text(
                      userName,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  if (userAddress.isNotEmpty) pw.Text(userAddress),
                  if (userZipCity.isNotEmpty) pw.Text(userZipCity),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (userBirthdate.isNotEmpty)
                    pw.Text('Geboren am: $userBirthdate'),
                  if (userEmail.isNotEmpty) pw.Text(userEmail),
                  if (userPhone.isNotEmpty) pw.Text(userPhone),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          if (applications.isEmpty)
            pw.Text('Im gewählten Zeitraum wurden keine Bewerbungen versendet.')
          else
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              headers: JobcenterReport.headers,
              data: applications
                  .map((app) => JobcenterReport.row(app, now: now))
                  .toList(),
            ),
        ];
      },
    ),
  );

  return pdf.save();
}

class PdfGenerator {
  /// Erstellt den Jobcenter-Nachweis als PDF und speichert ihn an einem vom
  /// Nutzer gewählten Ort.
  ///
  /// Es werden nur versendete Bewerbungen (Bewerbungsdatum gesetzt, Status
  /// nicht "offen") berücksichtigt, bei Angabe von [from]/[to] nur im
  /// Zeitraum (inklusive), sortiert nach Bewerbungsdatum.
  ///
  /// Gibt `true` zurück, wenn die Datei gespeichert wurde, `false`, wenn der
  /// Nutzer abgebrochen hat. Fehler werden als Exception weitergereicht.
  static Future<bool> generateAndSharePdf(
    List<ApplicationEntity> applications,
    SettingsRepository settingsRepository, {
    DateTime? from,
    DateTime? to,
  }) async {
    Future<String> setting(String key) async =>
        ((await settingsRepository.getSettingByKey(key))?.value ?? '').trim();

    final userName = await setting('userName');
    final userAddress = await setting('userAddress');
    final userZipCity =
        '${await setting('userZip')} ${await setting('userCity')}'.trim();
    final userEmail = await setting('userEmail');
    final userPhone = await setting('userPhone');
    final userBirthdate = await setting('userBirthdate');

    final filtered =
        JobcenterReport.filter(applications, from: from, to: to);

    String periodLabel = '';
    if (from != null && to != null) {
      periodLabel =
          '${JobcenterReport.formatDate(from)} – ${JobcenterReport.formatDate(to)}';
    } else if (from != null) {
      periodLabel = 'ab ${JobcenterReport.formatDate(from)}';
    } else if (to != null) {
      periodLabel = 'bis ${JobcenterReport.formatDate(to)}';
    }

    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
      suggestedName: 'bewerbungsnachweis.pdf',
    );

    if (saveLocation == null) return false; // Abgebrochen

    final fonts = await PdfFonts.load();

    final pdfBytes = await compute(_buildPdf, {
      'applications': filtered,
      'fonts': fonts,
      'now': DateTime.now(),
      'periodLabel': periodLabel,
      'userName': userName,
      'userAddress': userAddress,
      'userZipCity': userZipCity,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userBirthdate': userBirthdate,
    });

    final file = File(saveLocation.path);
    await file.writeAsBytes(pdfBytes);
    return true;
  }

  /// Nur für Tests: erzeugt die PDF-Bytes ohne Speicherdialog.
  @visibleForTesting
  static Future<Uint8List> buildReportBytes(
    List<ApplicationEntity> applications, {
    PdfFontData? fonts,
    DateTime? from,
    DateTime? to,
    String userName = '',
  }) {
    return _buildPdf({
      'applications': JobcenterReport.filter(applications, from: from, to: to),
      'fonts': fonts,
      'now': DateTime.now(),
      'periodLabel': '',
      'userName': userName,
      'userAddress': '',
      'userZipCity': '',
      'userEmail': '',
      'userPhone': '',
      'userBirthdate': '',
    });
  }
}
