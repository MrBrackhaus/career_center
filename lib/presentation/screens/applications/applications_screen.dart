import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:career_center/l10n/app_localizations.dart';

import '../../providers/applications_provider.dart';
import '../../providers/imap_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/custom_columns_provider.dart';
import '../../../data/database/app_database.dart';
import '../onboarding/tutorial_flow.dart';
import 'widgets/application_card.dart';
import 'email_scanner_dialog.dart';

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  String _searchQuery = '';
  String? _statusFilter;
  bool _isKanbanView = false;
  Application? _selectedApplication;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showTutorialIfNeeded(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final statusOptions = [loc.appFilterAll, 'offen', 'versendet', 'interview', 'absage', 'zusage'];
    final currentStatusFilter = _statusFilter ?? loc.appFilterAll;
    final applicationsAsync = ref.watch(applicationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.applicationsTitle),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final syncState = ref.watch(imapSyncProvider);
              final lastSync = ref.watch(imapLastSyncProvider).value;
              
              String lastSyncText = '';
              if (lastSync != null) {
                final now = DateTime.now();
                if (lastSync.year == now.year && lastSync.month == now.month && lastSync.day == now.day) {
                  lastSyncText = 'Zuletzt: heute ${lastSync.hour.toString().padLeft(2, '0')}:${lastSync.minute.toString().padLeft(2, '0')}';
                } else {
                  lastSyncText = 'Zuletzt: ${lastSync.day}.${lastSync.month}.';
                }
              }

              return Row(
                children: [
                  if (lastSyncText.isNotEmpty && !syncState.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        lastSyncText,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  if (syncState.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => const EmailScannerDialog(),
                      );
                    },
                    icon: const Icon(Icons.manage_search),
                    label: const Text('E-Mail Scanner'),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Auto-Sync (Hintergrund)',
                    child: IconButton(
                      onPressed: syncState.isLoading
                          ? null
                          : () async {
                              try {
                                final count = await ref.read(imapSyncProvider.notifier).syncEmails();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(count > 0
                                          ? 'Sync abgeschlossen! $count neue/aktualisierte Bewerbungen gefunden.'
                                          : 'Sync abgeschlossen! Keine neuen Antworten gefunden.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Fehler beim Sync: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.sync),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(_isKanbanView ? Icons.list : Icons.view_kanban),
            onPressed: () {
              setState(() {
                _isKanbanView = !_isKanbanView;
                _selectedApplication = null; // Close side panel when switching views
              });
            },
            tooltip: _isKanbanView ? 'Listenansicht' : 'Kanban-Ansicht',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter und Suchleiste
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: loc.appSearchHint,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentStatusFilter,
                      icon: const Icon(Icons.filter_list, size: 18),
                      items: statusOptions.map<DropdownMenuItem<String>>((String status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (value) => setState(() => _statusFilter = value == loc.appFilterAll ? null : value),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => context.go('/applications/add'),
                  icon: const Icon(Icons.add),
                  label: Text(loc.btnNewApplication),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: applicationsAsync.when(
              data: (applications) {
                final filteredApps = applications.where((app) {
                  final matchesSearch = app.company.toLowerCase().contains(_searchQuery) ||
                      app.position.toLowerCase().contains(_searchQuery);
                  final matchesStatus = _statusFilter == null || _statusFilter == loc.appFilterAll || app.status.toLowerCase() == _statusFilter?.toLowerCase();
                  return matchesSearch && matchesStatus;
                }).toList();

                if (filteredApps.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        constraints: const BoxConstraints(maxWidth: 450),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.rocket_launch,
                                size: 64,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isEmpty && _statusFilter == null
                                  ? loc.appEmptyTitle
                                  : loc.appNotFoundTitle,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isEmpty && _statusFilter == null
                                  ? loc.appEmptyDesc
                                  : loc.appNotFoundDesc,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            if (_searchQuery.isEmpty && _statusFilter == null)
                              FilledButton.icon(
                                onPressed: () => context.go('/applications/add'),
                                icon: const Icon(Icons.add),
                                label: Text(loc.btnNewApplication),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (_isKanbanView) {
                  return _buildKanbanBoard(filteredApps);
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          return ApplicationCard(
                            application: app,
                            isSelected: _selectedApplication?.id == app.id,
                            onTap: () {
                              setState(() {
                                if (_selectedApplication?.id == app.id) {
                                  _selectedApplication = null;
                                } else {
                                  _selectedApplication = app;
                                }
                              });
                            },
                            onDelete: () => _confirmDelete(context, app),
                          );
                        },
                      ),
                    ),
                    if (_selectedApplication != null)
                      _buildDossierPanel(_selectedApplication!),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Fehler: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierPanel(Application app) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasLogoUrl = app.companyUrl != null && app.companyUrl!.isNotEmpty;
    String? logoUrl;
    if (hasLogoUrl) {
      try {
        final uri = Uri.parse(app.companyUrl!);
        logoUrl = 'https://logo.clearbit.com/${uri.host}';
      } catch (_) {}
    }

    return Container(
      width: 400,
      margin: const EdgeInsets.only(right: 16, bottom: 16, top: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(-4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (logoUrl != null)
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(logoUrl),
                    radius: 28,
                  )
                else
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    radius: 28,
                    child: Text(
                      app.company.isNotEmpty ? app.company[0].toUpperCase() : '?',
                      style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.position,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.company,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedApplication = null),
                )
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.go('/applications/edit/${app.id}'),
                    icon: const Icon(Icons.edit_document),
                    label: const Text('Komplett bearbeiten'),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOTIZEN / JOB-BESCHREIBUNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  if (app.notes != null && app.notes!.isNotEmpty)
                    Text(
                      app.notes!,
                      style: TextStyle(fontSize: 14, color: colorScheme.onSurface, height: 1.6),
                    )
                  else
                    Text(
                      'Keine Stellenbeschreibung oder Notizen hinterlegt.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant),
                    ),
                  const SizedBox(height: 32),
                  const Text('BEWERBUNGS-VERLAUF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  _buildTimelineForApp(app, context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(String title, String? dateStr, bool isCompleted, bool isCurrent, bool isLast, BuildContext context) {
    final color = isCompleted || isCurrent ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isCurrent ? color : (isCompleted ? color : Colors.transparent),
                border: Border.all(color: color, width: 2),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCompleted || isCurrent ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant)),
              if (dateStr != null) Text(dateStr, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineForApp(Application app, BuildContext context) {
    final status = app.status.toLowerCase();

    final isVersendet = status == 'versendet' || status == 'interview' || status == 'zusage' || status == 'absage';
    final isInterview = status == 'interview' || status == 'zusage';

    final appliedDateStr = app.appliedDate != null ? DateFormat('dd.MM.yyyy').format(app.appliedDate!) : null;
    final responseDateStr = app.responseDate != null ? DateFormat('dd.MM.yyyy').format(app.responseDate!) : null;

    return Column(
      children: [
        _buildTimelineEvent('In Vorbereitung', appliedDateStr, isVersendet, status == 'offen', false, context),
        _buildTimelineEvent('Bewerbung versendet', isVersendet ? (appliedDateStr ?? 'Erledigt') : null, isInterview, status == 'versendet', false, context),
        _buildTimelineEvent('Interview / Gespräch', isInterview ? (responseDateStr ?? 'Eingeladen') : null, status == 'zusage', status == 'interview', false, context),
        if (status == 'absage')
          _buildTimelineEvent('Abgesagt', responseDateStr ?? 'Abgeschlossen', true, true, true, context)
        else
          _buildTimelineEvent('Zusage / Angebot', status == 'zusage' ? (responseDateStr ?? 'Angenommen') : null, status == 'zusage', status == 'zusage', true, context),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Application app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bewerbung löschen?'),
        content: Text('Möchtest du "${app.position}" bei "${app.company}" wirklich löschen?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.formBasicDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(applicationNotifierProvider).deleteApplication(app);
      if (mounted) {
        setState(() {
          if (_selectedApplication?.id == app.id) _selectedApplication = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${app.company} gelöscht')),
        );
      }
    }
  }

  Widget _buildKanbanBoard(List<Application> apps) {
    final columns = [
      {'status': 'offen', 'title': 'In Vorbereitung'},
      {'status': 'versendet', 'title': 'Warten auf Antwort'},
      {'status': 'interview', 'title': 'Im Gespräch'},
      {'status': 'zusage', 'title': 'Angebote'},
      {'status': 'absage', 'title': 'Archiv (Absagen)'},
    ];

    Widget buildColumn(Map<String, String> colDef, double width) {
      final status = colDef['status']!;
      final title = colDef['title']!;
      final isArchive = status == 'absage';
      final columnApps = apps.where((a) => a.status.toLowerCase() == status).toList();
      
      return DragTarget<Application>(
        onWillAcceptWithDetails: (details) => details.data.status.toLowerCase() != status,
        onAcceptWithDetails: (details) async {
          final app = details.data;
          final repository = ref.read(applicationsRepositoryProvider);
          await repository.updateApplication(app.copyWith(status: status).toCompanion(false));
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return Opacity(
            opacity: isArchive ? 0.75 : 1.0,
            child: Container(
              width: width,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHovering ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5) : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: isArchive ? 0.3 : 0.5),
                borderRadius: BorderRadius.circular(16),
                border: isHovering ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : (isArchive ? Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1) : null),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
                          child: Text('${columnApps.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: columnApps.length,
                      itemBuilder: (context, index) {
                        final app = columnApps[index];
                        return Draggable<Application>(
                          data: app,
                          feedback: Material(elevation: 8, borderRadius: BorderRadius.circular(12), child: SizedBox(width: width - 16, child: _buildKanbanCard(app, isArchive))),
                          childWhenDragging: Opacity(opacity: 0.3, child: _buildKanbanCard(app, isArchive)),
                          child: _buildKanbanCard(app, isArchive),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemCount: columns.length,
            itemBuilder: (context, index) => buildColumn(columns[index], constraints.maxWidth * 0.85),
          );
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns.map((col) => buildColumn(col, 320)).toList()),
          );
        }
      },
    );
  }

  Widget _buildKanbanCard(Application app, bool isArchive) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5))),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/applications/edit/${app.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(app.company, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (app.appliedDate != null)
                    Text(DateFormat('dd.MM.').format(app.appliedDate!), style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 4),
              Text(app.position, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
