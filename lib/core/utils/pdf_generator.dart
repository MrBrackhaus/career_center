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

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_selector/file_selector.dart';

import '../../domain/entities/application_entity.dart';
import '../../data/repositories/settings_repository.dart';

import 'package:flutter/foundation.dart';

Future<Uint8List> _buildPdf(Map<String, dynamic> data) async {
  final pdf = pw.Document();
  final applications = data['applications'] as List<ApplicationEntity>;
  
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
        boldItalic: pw.Font.helveticaBoldOblique(),
      ),
      build: (pw.Context context) {
        return [
          pw.Text(
            'Nachweis Eigenbemühungen (Bewerbungen)',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    data['userName'],
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  if ((data['userAddress'] as String).isNotEmpty) pw.Text(data['userAddress']),
                  if ((data['userZipCity'] as String).isNotEmpty) pw.Text(data['userZipCity']),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if ((data['userBirthdate'] as String).isNotEmpty)
                    pw.Text('Geboren am: ${data['userBirthdate']}'),
                  if ((data['userEmail'] as String).isNotEmpty) pw.Text(data['userEmail']),
                  if ((data['userPhone'] as String).isNotEmpty) pw.Text(data['userPhone']),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            context: context,
            headers: [
              'Datum',
              'Firma',
              'Position',
              'Kontakt',
              'Status',
              'Absagegrund',
            ],
            data: applications.map((app) {
              final contactInfos =
                  [
                        app.contactName,
                        app.contactEmail,
                        app.contactPhone,
                        app.address,
                      ]
                      .where((s) => s != null && s.isNotEmpty)
                      .join('\n'); // Newline in PDF table

              return [
                app.appliedDate != null
                    ? '${app.appliedDate!.day}.${app.appliedDate!.month}.${app.appliedDate!.year}'
                    : '-',
                app.company,
                app.position,
                contactInfos.isNotEmpty ? contactInfos : '-',
                app.status,
                app.rejectionReason ?? '-',
              ];
            }).toList(),
          ),
        ];
      },
    ),
  );

  return pdf.save();
}

class PdfGenerator {
  static Future<void> generateAndSharePdf(
    List<ApplicationEntity> applications,
    SettingsRepository settingsRepository,
  ) async {
    final nameSetting = await settingsRepository.getSettingByKey('userName');
    final addressSetting = await settingsRepository.getSettingByKey('userAddress');
    final zipSetting = await settingsRepository.getSettingByKey('userZip');
    final citySetting = await settingsRepository.getSettingByKey('userCity');
    final emailSetting = await settingsRepository.getSettingByKey('userEmail');
    final phoneSetting = await settingsRepository.getSettingByKey('userPhone');
    final birthdateSetting = await settingsRepository.getSettingByKey('userBirthdate');

    final userName = nameSetting?.value ?? 'Dein Name';
    final userAddress = addressSetting?.value ?? 'Deine Adresse';
    final userZipCity = '${zipSetting?.value ?? ''} ${citySetting?.value ?? ''}'
        .trim();
    final userEmail = emailSetting?.value ?? '';
    final userPhone = phoneSetting?.value ?? '';
    final userBirthdate = birthdateSetting?.value ?? '';

    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
      suggestedName: 'bewerbungsnachweis.pdf',
    );

    if (saveLocation == null) return; // User cancelled

    final pdfBytes = await compute(_buildPdf, {
      'applications': applications,
      'userName': userName,
      'userAddress': userAddress,
      'userZipCity': userZipCity,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'userBirthdate': userBirthdate,
    });

    final file = File(saveLocation.path);
    await file.writeAsBytes(pdfBytes);
  }
}
