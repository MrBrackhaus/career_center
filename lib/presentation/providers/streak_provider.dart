import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'applications_provider.dart';
import 'database_provider.dart';

class StreakData {
  final int streakCount;
  final int weeklyGoal;
  final int currentWeekCount;
  final bool isGoalMetThisWeek;

  StreakData({
    required this.streakCount,
    required this.weeklyGoal,
    required this.currentWeekCount,
    required this.isGoalMetThisWeek,
  });
}

final weeklyGoalProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final setting = await db.settingsDao.getSettingByKey('weeklyApplicationGoal');
  return int.tryParse(setting?.value ?? '5') ?? 5;
});

final streakProvider = Provider<AsyncValue<StreakData>>((ref) {
  final applicationsAsync = ref.watch(applicationsProvider);
  final goalAsync = ref.watch(weeklyGoalProvider);

  if (applicationsAsync.isLoading || goalAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (applicationsAsync.hasError) {
    return AsyncValue.error(
      applicationsAsync.error!,
      applicationsAsync.stackTrace!,
    );
  }

  final applications = applicationsAsync.value ?? [];
  final goal = goalAsync.value ?? 5;

  // Group applications by ISO week year-week (e.g., "2026-W36")
  final Map<String, int> appsPerWeek = {};

  for (final app in applications) {
    if (app.appliedDate != null) {
      final weekKey = _getIsoWeekKey(app.appliedDate!);
      appsPerWeek[weekKey] = (appsPerWeek[weekKey] ?? 0) + 1;
    }
  }

  final now = DateTime.now();
  int currentWeekCount = appsPerWeek[_getIsoWeekKey(now)] ?? 0;
  bool isGoalMetThisWeek = currentWeekCount >= goal;

  int streak = 0;

  // If the goal is met this week, it counts towards the streak immediately
  if (isGoalMetThisWeek) {
    streak++;
  }

  // Count backwards from LAST week
  DateTime checkDate = now.subtract(const Duration(days: 7));

  while (true) {
    final checkWeekKey = _getIsoWeekKey(checkDate);
    final count = appsPerWeek[checkWeekKey] ?? 0;

    if (count >= goal) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 7));
    } else {
      break;
    }
  }

  return AsyncValue.data(
    StreakData(
      streakCount: streak,
      weeklyGoal: goal,
      currentWeekCount: currentWeekCount,
      isGoalMetThisWeek: isGoalMetThisWeek,
    ),
  );
});

String _getIsoWeekKey(DateTime date) {
  // ISO-8601 week calculation
  // Thursday in current week decides the year.
  final int dayOfYear = int.parse(
    date.difference(DateTime(date.year, 1, 1)).inDays.toString(),
  );
  final int woy = ((dayOfYear - date.weekday + 10) / 7).floor();

  int year = date.year;
  int week = woy;

  if (week < 1) {
    year--;
    week = 52; // Simplification, could be 53 depending on the year
  } else if (week > 52) {
    // Determine if the year has 53 weeks
    DateTime dec31 = DateTime(date.year, 12, 31);
    if (dec31.weekday == DateTime.thursday ||
        (dec31.weekday == DateTime.friday && _isLeapYear(date.year))) {
      week = 53;
    } else {
      year++;
      week = 1;
    }
  }

  return "$year-W${week.toString().padLeft(2, '0')}";
}

bool _isLeapYear(int year) {
  return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
}
