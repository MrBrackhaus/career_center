import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/applications_provider.dart';
import '../../providers/stats_provider.dart';

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationsProvider);
    final stats = ref.watch(statsProvider);

    return Scaffold(
      body: applicationsAsync.when(
        data: (applications) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
          final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));

          final thisWeekApps = applications.where((app) {
            final appliedDate = app.appliedDate;
            if (appliedDate == null) return false;
            return appliedDate.isAfter(
                  startOfWeek.subtract(const Duration(microseconds: 1)),
                ) &&
                appliedDate.isBefore(startOfWeek.add(const Duration(days: 7)));
          }).toList();

          final lastWeekApps = applications.where((app) {
            final appliedDate = app.appliedDate;
            if (appliedDate == null) return false;
            return appliedDate.isAfter(
                  startOfLastWeek.subtract(const Duration(microseconds: 1)),
                ) &&
                appliedDate.isBefore(startOfWeek);
          }).toList();

          final thisWeekRejections = thisWeekApps
              .where((app) => app.status.toLowerCase() == 'absage')
              .length;
          final upcomingResponses = applications
              .where((app) => app.status.toLowerCase() == 'versendet')
              .toList();

          final activeApps = stats.open;

          String motivationTitle =
              'Jede Reise beginnt mit dem ersten Schritt! 🚀';
          if (thisWeekApps.length >= 5) {
            motivationTitle = 'FANTASTISCHE ARBEIT DIESE WOCHE! 🎉';
          } else if (thisWeekApps.length >= 3)
            motivationTitle = 'Starke Leistung diese Woche! 🌟';
          else if (thisWeekApps.isNotEmpty)
            motivationTitle = 'Guter Start! Weiter so! 💪';

          final goalProgress = (thisWeekApps.length / 5).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dein Wochenbericht',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      motivationTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'NEUE BEWERBUNGEN',
                        thisWeekApps.length.toString(),
                        Icons.note_add,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'AKTIVE BEWERBUNGEN',
                        activeApps.toString(),
                        Icons.pending_actions,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'ABSAGEN',
                        thisWeekRejections.toString(),
                        Icons.cancel_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wochenziel: ${thisWeekApps.length} von 5 Bewerbungen',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: goalProgress,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              thisWeekApps.length >= lastWeekApps.length
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: thisWeekApps.length >= lastWeekApps.length
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Diese Woche ${thisWeekApps.length} Bewerbungen vs. letzte Woche ${lastWeekApps.length} Bewerbungen',
                              style: TextStyle(
                                color:
                                    thisWeekApps.length >= lastWeekApps.length
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Anstehende Rückmeldungen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (upcomingResponses.isEmpty)
                  const Text(
                    'Aktuell keine ausstehenden Antworten.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                else
                  ...upcomingResponses.map(
                    (app) => Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            app.company.isNotEmpty
                                ? app.company[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(app.position),
                        subtitle: Text(app.company),
                        trailing: const Text(
                          'Wartend',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 48),
                const Text(
                  'Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fehler: $err')),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
