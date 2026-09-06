import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_selector/file_selector.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/settings_dao.dart';

class PdfGenerator {
  static Future<void> generateAndSharePdf(List<Application> applications, SettingsDao settingsDao) async {
    final pdf = pw.Document();

    final nameSetting = await settingsDao.getSettingByKey('userName');
    final addressSetting = await settingsDao.getSettingByKey('userAddress');
    final zipSetting = await settingsDao.getSettingByKey('userZip');
    final citySetting = await settingsDao.getSettingByKey('userCity');
    final emailSetting = await settingsDao.getSettingByKey('userEmail');
    final phoneSetting = await settingsDao.getSettingByKey('userPhone');
    final birthdateSetting = await settingsDao.getSettingByKey('userBirthdate');

    final userName = nameSetting?.value ?? 'Dein Name';
    final userAddress = addressSetting?.value ?? 'Deine Adresse';
    final userZipCity = '${zipSetting?.value ?? ''} ${citySetting?.value ?? ''}'.trim();
    final userEmail = emailSetting?.value ?? '';
    final userPhone = phoneSetting?.value ?? '';
    final userBirthdate = birthdateSetting?.value ?? '';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape, // Landscape for more columns
        build: (pw.Context context) {
          return [
            pw.Text('Nachweis Eigenbemühungen (Bewerbungen)', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(userName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (userAddress.isNotEmpty) pw.Text(userAddress),
                    if (userZipCity.isNotEmpty) pw.Text(userZipCity),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (userBirthdate.isNotEmpty) pw.Text('Geboren am: $userBirthdate'),
                    if (userEmail.isNotEmpty) pw.Text(userEmail),
                    if (userPhone.isNotEmpty) pw.Text(userPhone),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              context: context,
              headers: ['Datum', 'Firma', 'Position', 'Kontakt', 'Status', 'Absagegrund'],
              data: applications.map((app) {
                final contactInfos = [
                  app.contactName,
                  app.contactEmail,
                  app.contactPhone,
                  app.address,
                ].where((s) => s != null && s.isNotEmpty).join('\n'); // Newline in PDF table

                return [
                  app.appliedDate != null ? '${app.appliedDate!.day}.${app.appliedDate!.month}.${app.appliedDate!.year}' : '-',
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

    final saveLocation = await getSaveLocation(
      acceptedTypeGroups: [const XTypeGroup(label: 'PDF', extensions: ['pdf'])],
      suggestedName: 'bewerbungsnachweis.pdf',
    );

    if (saveLocation == null) return; // User cancelled

    final file = File(saveLocation.path);
    await file.writeAsBytes(await pdf.save());
  }
}

