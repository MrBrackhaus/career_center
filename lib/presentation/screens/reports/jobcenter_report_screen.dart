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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../data/database/daos/settings_dao.dart';

class JobcenterReportScreen extends ConsumerStatefulWidget {
  const JobcenterReportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<JobcenterReportScreen> createState() => _JobcenterReportScreenState();
}

class _JobcenterReportScreenState extends ConsumerState<JobcenterReportScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final db = ref.read(databaseProvider);
    final setting = await db.settingsDao.getSettingByKey('userName');
    if (setting != null && mounted) {
      setState(() {
        _userName = setting.value;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateYMD(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final applicationsAsync = ref.watch(applicationsProvider);
    final nowString = _formatDate(DateTime.now());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.reportTitle,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  applicationsAsync.whenData((applications) {
                    final settingsDao = ref.read(databaseProvider).settingsDao;
                    PdfGenerator.generateAndSharePdf(applications, settingsDao);
                  });
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: Text(AppLocalizations.of(context)!.reportSavePdf),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.reportGeneratedAt + ' $nowString' + AppLocalizations.of(context)!.reportTimeSuffix + (_userName.isNotEmpty ? ' | Name: $_userName' : ''),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: applicationsAsync.when(
              data: (applications) {
                if (applications.isEmpty) {
                  return Center(child: Text(AppLocalizations.of(context)!.reportNoApps));
                }
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text(AppLocalizations.of(context)!.reportDate)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.reportCompany)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.reportPosition)),
                        DataColumn(label: Text('KONTAKT')),
                        DataColumn(label: Text(AppLocalizations.of(context)!.reportStatus)),
                        DataColumn(label: Text(AppLocalizations.of(context)!.reportRejectionReason)),
                      ],
                      rows: applications.map((app) {
                        final contactInfos = [
                          app.contactName,
                          app.contactEmail,
                          app.contactPhone,
                          app.address,
                        ].where((s) => s != null && s.isNotEmpty).join(', ');

                        return DataRow(
                          cells: [
                            DataCell(Text(app.appliedDate != null ? _formatDateYMD(app.appliedDate!) : '-')),
                            DataCell(Text(app.company)),
                            DataCell(Text(app.position)),
                            DataCell(Text(contactInfos.isNotEmpty ? contactInfos : '-')),
                            DataCell(Text(app.status)),
                            DataCell(Text(app.rejectionReason?.isNotEmpty == true ? app.rejectionReason! : '-')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Fehler beim Laden der Daten')),
            ),
          ),
        ],
      ),
    );
  }
}

