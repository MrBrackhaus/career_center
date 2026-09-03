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
import 'package:intl/intl.dart';
import '../../providers/email_scanner_provider.dart';
import '../../../core/services/imap_service.dart';

class EmailScannerDialog extends ConsumerStatefulWidget {
  const EmailScannerDialog({super.key});

  @override
  ConsumerState<EmailScannerDialog> createState() => _EmailScannerDialogState();
}

class _EmailScannerDialogState extends ConsumerState<EmailScannerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Auto-load on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emailScannerProvider.notifier).loadEmails();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'versendet': return const Color(0xFF7C6AF7);
      case 'absage': return Colors.red;
      case 'interview': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'versendet': return 'BEWERBUNG';
      case 'absage': return 'ABSAGE';
      case 'interview': return 'INTERVIEW';
      default: return '';
    }
  }

  Widget _buildEmailList(List<ScannableEmail> emails, String folder, EmailScannerState scanState) {
    final filtered = emails.where((e) => e.folder == folder).toList();
    if (filtered.isEmpty) {
      return const Center(child: Text('Keine E-Mails gefunden.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final mail = filtered[index];
        final isSelected = scanState.selectedUids.contains(mail.uid);
        final isDetected = mail.detectedStatus != null;
        final isImported = mail.isAlreadyImported;

        return Opacity(
          opacity: isImported ? 0.45 : (isDetected ? 1.0 : 0.65),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: const Color(0xFF7C6AF7), width: 1.5)
                  : Border.all(color: Colors.transparent),
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: isImported
                  ? null
                  : (_) => ref.read(emailScannerProvider.notifier).toggleSelection(mail.uid),
              activeColor: const Color(0xFF7C6AF7),
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      mail.subject.isNotEmpty ? mail.subject : '(Kein Betreff)',
                      style: TextStyle(
                        fontWeight: isDetected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isImported)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: const Text('✓ IMPORTIERT', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  else if (mail.detectedStatus != null)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor(mail.detectedStatus).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _statusColor(mail.detectedStatus).withOpacity(0.5)),
                      ),
                      child: Text(
                        _statusLabel(mail.detectedStatus),
                        style: TextStyle(color: _statusColor(mail.detectedStatus), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  if (mail.company.isNotEmpty)
                    Text(
                      mail.company,
                      style: const TextStyle(color: Color(0xFF7C6AF7), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  Text(
                    '${mail.fromTo}  •  ${DateFormat('dd.MM.yyyy', 'de').format(mail.date)}',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  if (mail.bodySnippet.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        mail.bodySnippet.replaceAll('\n', ' ').replaceAll('\r', ''),
                        style: const TextStyle(color: Color(0xFF999999), fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(emailScannerProvider);
    final notifier = ref.read(emailScannerProvider.notifier);

    final selectedCount = scanState.selectedUids.length;
    final sentCount = scanState.emails.where((e) => e.folder == 'sent').length;
    final inboxCount = scanState.emails.where((e) => e.folder == 'inbox').length;

    return Dialog(
      backgroundColor: const Color(0xFF262626),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.manage_search, color: Color(0xFF7C6AF7), size: 22),
                  const SizedBox(width: 10),
                  const Text('E-Mail-Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Spacer(),
                  if (!scanState.isLoading)
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.grey),
                      tooltip: 'Neu laden',
                      onPressed: notifier.loadEmails,
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF7C6AF7).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: const Color(0xFF7C6AF7),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: 'Gesendet ($sentCount)'),
                  Tab(text: 'Posteingang ($inboxCount)'),
                ],
              ),
            ),

            // Content
            Expanded(
              child: scanState.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF7C6AF7)),
                          SizedBox(height: 16),
                          Text('E-Mails werden geladen...', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 6),
                          Text('(kann 20–40 Sekunden dauern)', style: TextStyle(color: Color(0xFF666666), fontSize: 12)),
                        ],
                      ),
                    )
                  : scanState.error != null
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('Fehler: ${scanState.error}', style: const TextStyle(color: Colors.red)),
                        ))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildEmailList(scanState.emails, 'sent', scanState),
                            _buildEmailList(scanState.emails, 'inbox', scanState),
                          ],
                        ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF333333))),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '$selectedCount ausgewählt',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: notifier.selectAllDetected,
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF7C6AF7), padding: EdgeInsets.zero),
                        child: const Text('Alle Bewerbungen', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: notifier.deselectAll,
                        style: TextButton.styleFrom(foregroundColor: Colors.grey, padding: EdgeInsets.zero),
                        child: const Text('Keine', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (selectedCount == 0 || scanState.isImporting)
                          ? null
                          : () async {
                              final count = await notifier.importSelected();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('$count Bewerbung(en) erfolgreich importiert!'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ));
                              }
                            },
                      icon: scanState.isImporting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.download_done_rounded),
                      label: Text(scanState.isImporting ? 'Wird importiert...' : 'Ausgewählte importieren ($selectedCount)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6AF7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

