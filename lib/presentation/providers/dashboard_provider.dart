import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/application_entity.dart';
import 'applications_provider.dart';

class WeeklyStats {
  final List<ApplicationEntity> thisWeekApps;
  final List<ApplicationEntity> lastWeekApps;
  final List<ApplicationEntity> thisWeekRejections;
  final List<ApplicationEntity> overdueFollowUps;
  final List<ApplicationEntity> upcomingFollowUps;

  WeeklyStats({
    this.thisWeekApps = const [],
    this.lastWeekApps = const [],
    this.thisWeekRejections = const [],
    this.overdueFollowUps = const [],
    this.upcomingFollowUps = const [],
  });
}

class OverallStats {
  final int total;
  final int open;
  final int rejected;
  final int interviews;
  final double responseRate;
  final double rejectionRate;
  final double avgCommute;
  final Map<String, int> monthlyCounts;
  final List<MapEntry<String, int>> sortedReasons;

  OverallStats({
    this.total = 0,
    this.open = 0,
    this.rejected = 0,
    this.interviews = 0,
    this.responseRate = 0.0,
    this.rejectionRate = 0.0,
    this.avgCommute = 0.0,
    this.monthlyCounts = const {},
    this.sortedReasons = const [],
  });
}

final dashboardWeeklyStatsProvider = Provider.autoDispose<WeeklyStats>((ref) {
  final appsList = ref.watch(applicationsProvider).value ?? [];
  
  final now = DateTime.now();
  final oneWeekAgo = now.subtract(const Duration(days: 7));
  final twoWeeksAgo = now.subtract(const Duration(days: 14));

  return WeeklyStats(
    thisWeekApps: appsList.where((a) => a.appliedDate != null && a.appliedDate!.isAfter(oneWeekAgo)).toList(),
    lastWeekApps: appsList.where((a) => a.appliedDate != null && a.appliedDate!.isAfter(twoWeeksAgo) && a.appliedDate!.isBefore(oneWeekAgo)).toList(),
    thisWeekRejections: appsList.where((a) => a.status == 'Absage' && a.responseDate != null && a.responseDate!.isAfter(oneWeekAgo)).toList(),
    overdueFollowUps: appsList.where((a) => a.followupDate != null && a.followupDate!.isBefore(now) && a.status != 'Absage' && a.status != 'Zusage' && a.status != 'Archiviert').toList(),
    upcomingFollowUps: appsList.where((a) => a.followupDate != null && a.followupDate!.isAfter(now) && a.followupDate!.isBefore(now.add(const Duration(days: 7))) && a.status != 'Absage' && a.status != 'Zusage' && a.status != 'Archiviert').toList(),
  );
});

final dashboardOverallStatsProvider = Provider.autoDispose<OverallStats>((ref) {
  final appsList = ref.watch(applicationsProvider).value ?? [];
  if (appsList.isEmpty) return OverallStats();

  int open = 0, rejected = 0, interviews = 0;
  double commuteSum = 0;
  int commuteCount = 0;
  Map<String, int> reasons = {};
  Map<String, int> monthly = {};

  for (final a in appsList) {
    if (a.status == 'offen') open++;
    else if (a.status == 'Absage') rejected++;
    else if (a.status == 'Vorstellungsgespräch' || a.status == 'Zusage') interviews++;

    if (a.commuteCar != null && a.commuteCar! > 0) {
      commuteSum += a.commuteCar!;
      commuteCount++;
    }

    if (a.status == 'Absage' && a.rejectionReason != null && a.rejectionReason!.isNotEmpty) {
      reasons[a.rejectionReason!] = (reasons[a.rejectionReason!] ?? 0) + 1;
    }

    if (a.appliedDate != null) {
      final key = "${a.appliedDate!.year}-${a.appliedDate!.month.toString().padLeft(2, '0')}";
      monthly[key] = (monthly[key] ?? 0) + 1;
    }
  }

  final sortedReasons = reasons.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final responded = rejected + interviews;

  return OverallStats(
    total: appsList.length,
    open: open,
    rejected: rejected,
    interviews: interviews,
    responseRate: appsList.isNotEmpty ? (responded / appsList.length) * 100 : 0.0,
    rejectionRate: responded > 0 ? (rejected / responded) * 100 : 0.0,
    avgCommute: commuteCount > 0 ? commuteSum / commuteCount : 0.0,
    monthlyCounts: monthly,
    sortedReasons: sortedReasons,
  );
});
