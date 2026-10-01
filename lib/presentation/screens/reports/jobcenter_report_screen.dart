/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/jobcenter_report.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../domain/entities/application_entity.dart';

class JobcenterReportScreen extends ConsumerStatefulWidget {
  const JobcenterReportScreen({super.key});

  @override
  ConsumerState<JobcenterReportScreen> createState() =>
      _JobcenterReportScreenState();
}

class _JobcenterReportScreenState extends ConsumerState<JobcenterReportScreen> {
  String _userName = '';
  late DateTimeRange _range;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final month = JobcenterReport.currentMonth();
    _range = DateTimeRange(start: month.from, end: month.to);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final setting =
          await ref.read(settingsRepositoryProvider).getSettingByKey('userName');
      if (setting != null && mounted) {
        setState(() {
          _userName = setting.value;
        });
      }
    } catch (_) {
      // Name ist optional – Bericht funktioniert auch ohne.
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _range,
      helpText: 'Zeitraum für den Nachweis',
      saveText: 'Übernehmen',
      cancelText: 'Abbrechen',
    );
    if (picked != null && mounted) {
      setState(() => _range = picked);
    }
  }

  Future<void> _exportPdf(List<ApplicationEntity> applications) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final saved = await PdfGenerator.generateAndSharePdf(
        applications,
        ref.read(settingsRepositoryProvider),
        from: _range.start,
        to: _range.end,
      );
      if (saved) {
        messenger.showSnackBar(
          const SnackBar(content: Text('PDF-Nachweis wurde gespeichert.')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('PDF konnte nicht erstellt werden: $e')),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationsProvider);
    final nowString = _formatDate(DateTime.now());
    final rangeLabel =
        '${JobcenterReport.formatDate(_range.start)} – ${JobcenterReport.formatDate(_range.end)}';

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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isExporting || !applicationsAsync.hasValue
                    ? null
                    : () => _exportPdf(applicationsAsync.value!),
                icon: _isExporting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.picture_as_pdf),
                label: Text(AppLocalizations.of(context)!.reportSavePdf),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range),
                label: Text('Zeitraum: $rangeLabel'),
              ),
              TextButton(
                onPressed: () {
                  final month = JobcenterReport.currentMonth();
                  setState(() => _range =
                      DateTimeRange(start: month.from, end: month.to));
                },
                child: const Text('Aktueller Monat'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${AppLocalizations.of(context)!.reportGeneratedAt} $nowString${AppLocalizations.of(context)!.reportTimeSuffix}${_userName.isNotEmpty ? ' | Name: $_userName' : ''}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: applicationsAsync.when(
              data: (allApplications) {
                final applications = JobcenterReport.filter(
                  allApplications,
                  from: _range.start,
                  to: _range.end,
                );
                if (applications.isEmpty) {
                  return Center(
                    child: Text(
                      allApplications.isEmpty
                          ? AppLocalizations.of(context)!.reportNoApps
                          : 'Im gewählten Zeitraum wurden keine Bewerbungen versendet.',
                    ),
                  );
                }
                final now = DateTime.now();
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        for (final h in JobcenterReport.headers)
                          DataColumn(label: Text(h.toUpperCase())),
                      ],
                      rows: applications.map((app) {
                        final cells = JobcenterReport.row(app, now: now);
                        return DataRow(
                          cells: [for (final c in cells) DataCell(Text(c))],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  const Center(child: Text('Fehler beim Laden der Daten')),
            ),
          ),
        ],
      ),
    );
  }
}
