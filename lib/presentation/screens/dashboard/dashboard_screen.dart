import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/streak_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/applications_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/database/app_database.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationsProvider);
    final stats = ref.watch(statsProvider);

    return applicationsAsync.when(
      data: (applications) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: TabBar(
              tabs: [
                Tab(text: AppLocalizations.of(context)!.dashboardTabWeek),
                Tab(text: AppLocalizations.of(context)!.dashboardTabTotal),
              ],
            ),
            body: TabBarView(
              children: [
                _buildWeeklyTab(context, applications, stats, ref.watch(streakProvider)),
                _buildOverallTab(context, applications, stats),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Fehler: $e'))),
    );
  }

  Widget _buildWeeklyTab(BuildContext context, List<Application> applications, ApplicationStats stats, AsyncValue<StreakData> streakAsync) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfLastWeek = startOfWeek.subtract(const Duration(days: 7));

    final thisWeekApps = applications.where((app) {
      if (app.appliedDate == null) return false;
      return !app.appliedDate!.isBefore(startOfWeek) &&
          app.appliedDate!.isBefore(startOfWeek.add(const Duration(days: 7)));
    }).toList();

    final lastWeekApps = applications.where((app) {
      if (app.appliedDate == null) return false;
      return !app.appliedDate!.isBefore(startOfLastWeek) &&
          app.appliedDate!.isBefore(startOfWeek);
    }).toList();

    final thisWeekRejections =
        thisWeekApps.where((app) => app.status.toLowerCase() == 'absage').length;
    
    final overdueFollowUps = applications.where((app) =>
        app.followupDate != null &&
        app.followupDate!.isBefore(today) &&
        app.status != 'absage' &&
        app.status != 'zusage').toList();
        
    final upcomingFollowUps = applications.where((app) =>
        app.followupDate != null &&
        !app.followupDate!.isBefore(today) &&
        app.followupDate!.isBefore(today.add(const Duration(days: 7))) &&
        app.status != 'absage' &&
        app.status != 'zusage').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (overdueFollowUps.isNotEmpty) ...[
            Card(
              color: Colors.red.shade900.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.warning_amber, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('${overdueFollowUps.length} überfällige Erinnerung${overdueFollowUps.length == 1 ? '' : 'en'} – jetzt nachhaken!',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    ]),
                    const SizedBox(height: 8),
                    ...overdueFollowUps.map((app) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• ${app.company} – ${app.position} (seit ${app.followupDate!.day.toString().padLeft(2,'0')}.${app.followupDate!.month.toString().padLeft(2,'0')}.${app.followupDate!.year})',
                          style: const TextStyle(color: Colors.red)),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (upcomingFollowUps.isNotEmpty) ...[
            Card(
              color: Colors.orange.shade900.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.notifications_active, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('${upcomingFollowUps.length} Erinnerung${upcomingFollowUps.length == 1 ? '' : 'en'} diese Woche',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ]),
                    const SizedBox(height: 8),
                    ...upcomingFollowUps.map((app) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• ${app.company} – ${app.position} (am ${app.followupDate!.day.toString().padLeft(2,'0')}.${app.followupDate!.month.toString().padLeft(2,'0')}.${app.followupDate!.year})'),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildMotivationalHeader(context, thisWeekApps.length),
          const SizedBox(height: 24),
          
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  children: [
                    Row(
                      children: [
                        _buildStatCard(context, thisWeekApps.length.toString(), AppLocalizations.of(context)!.dashboardNewApps),
                        const SizedBox(width: 8),
                        _buildStatCard(context, stats.open.toString(), AppLocalizations.of(context)!.dashboardActiveApps),
                      ]
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard(context, thisWeekRejections.toString(), AppLocalizations.of(context)!.dashboardRejections),
                        const SizedBox(width: 8),
                        const Spacer(),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  _buildStatCard(context, thisWeekApps.length.toString(), AppLocalizations.of(context)!.dashboardNewApps),
                  const SizedBox(width: 8),
                  _buildStatCard(context, stats.open.toString(), AppLocalizations.of(context)!.dashboardActiveApps),
                  const SizedBox(width: 8),
                  _buildStatCard(context, thisWeekRejections.toString(), AppLocalizations.of(context)!.dashboardRejections),
                ],
              );
            }
          ),
          
          const SizedBox(height: 24),
          _buildGoalProgress(context, thisWeekApps.length),
          const SizedBox(height: 24),
          _buildComparison(context, thisWeekApps.length, lastWeekApps.length),
          const SizedBox(height: 32),
          Center(
            child: Text(
              AppLocalizations.of(context)!.weeklyMotivationalFooterNoIcon,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallTab(BuildContext context, List<Application> applications, ApplicationStats stats) {
    final total = stats.total;
    final open = stats.open;
    final rejected = stats.rejected;
    final interviews = stats.interview;

    double responseRate = total > 0 ? ((total - open) / total * 100) : 0.0;
    double rejectionRate = total > 0 ? (rejected / total * 100) : 0.0;

    int validCommuteCount = 0;
    int totalCommute = 0;
    for (var app in applications) {
      if (app.commuteCar != null) {
        totalCommute += app.commuteCar!;
        validCommuteCount++;
      }
    }
    double avgCommute = validCommuteCount > 0 ? totalCommute / validCommuteCount : 0.0;

    final now = DateTime.now();
    Map<String, int> monthlyCounts = {};
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final key = "${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}";
      monthlyCounts[key] = 0;
    }

    for (var app in applications) {
      if (app.appliedDate != null) {
        final d = app.appliedDate!;
        final key = "${d.year}-${d.month.toString().padLeft(2, '0')}";
        if (monthlyCounts.containsKey(key)) {
          monthlyCounts[key] = monthlyCounts[key]! + 1;
        }
      }
    }

    Map<String, int> rejectionReasons = {};
    for (var app in applications) {
      if (app.status == 'absage' && app.rejectionReason != null) {
        final reason = app.rejectionReason!;
        if (reason.isNotEmpty) {
          rejectionReasons[reason] = (rejectionReasons[reason] ?? 0) + 1;
        }
      }
    }
    final sortedReasons = rejectionReasons.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.dashboardOverview, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatCard(title: AppLocalizations.of(context)!.dashboardApplications, value: '$total'),
                _StatCard(title: AppLocalizations.of(context)!.dashboardOpen, value: '$open'),
                _StatCard(title: AppLocalizations.of(context)!.dashboardRejections, value: '$rejected'),
                _StatCard(title: AppLocalizations.of(context)!.dashboardResponseRate, value: '${responseRate.toStringAsFixed(1)}%'),
                _StatCard(title: AppLocalizations.of(context)!.dashboardRejectionRate, value: '${rejectionRate.toStringAsFixed(1)}%'),
                _StatCard(title: AppLocalizations.of(context)!.dashboardInterviews, value: '$interviews'),
                _StatCard(title: AppLocalizations.of(context)!.dashboardCommute, value: validCommuteCount > 0 ? '${avgCommute.toStringAsFixed(0)} Min' : 'Keine Daten'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(AppLocalizations.of(context)!.dashboardAppsPerMonth, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (monthlyCounts.values.isEmpty ? 10 : monthlyCounts.values.reduce((a, b) => a > b ? a : b).toDouble() + 2),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() >= 0 && value.toInt() < monthlyCounts.keys.length) {
                              final rawKey = monthlyCounts.keys.elementAt(value.toInt()); // e.g., '2026-08'
                              final date = DateTime.tryParse('$rawKey-01');
                              final label = date != null ? DateFormat('MMM yyyy').format(date) : rawKey;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(label, style: const TextStyle(fontSize: 10)),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: monthlyCounts.entries.toList().asMap().entries.map((entry) {
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.value.toDouble(),
                            color: Theme.of(context).colorScheme.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(AppLocalizations.of(context)!.dashboardTopRejectionReasons, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: sortedReasons.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(AppLocalizations.of(context)!.dashboardNoRejectionReasons),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedReasons.length,
                    itemBuilder: (context, index) {
                      final reason = sortedReasons[index];
                      return ListTile(
                        title: Text(reason.key),
                        trailing: CircleAvatar(
                          radius: 12,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text('${reason.value}', style: const TextStyle(fontSize: 12)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalHeader(BuildContext context, int count) {
    String message;
    if (count == 0) {
      message = AppLocalizations.of(context)!.dashboardMsgStart;
    } else if (count <= 2) {
      message = AppLocalizations.of(context)!.dashboardMsgGood;
    } else if (count <= 4) {
      message = AppLocalizations.of(context)!.dashboardMsgStrong;
    } else {
      message = AppLocalizations.of(context)!.dashboardMsgFantastic;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String title, [AppLocalizations? loc]) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      )),
              const SizedBox(height: 8),
              Text(title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalProgress(BuildContext context, int current) {
    const int goal = 5;
    final double progress = (current / goal).clamp(0.0, 1.0);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.weeklyGoal + ' $current ' + AppLocalizations.of(context)!.weeklyGoalSuffix,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparison(BuildContext context, int current, int last) {
    final diff = current - last;
    final isPositive = diff >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.weeklyThisWeek + '$current' + AppLocalizations.of(context)!.weeklyVs + '$last' + AppLocalizations.of(context)!.weeklyApplications,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
