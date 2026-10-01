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
  final setting = await ref.read(settingsRepositoryProvider).getSettingByKey('weeklyApplicationGoal');
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
      final weekKey = isoWeekKey(app.appliedDate!);
      appsPerWeek[weekKey] = (appsPerWeek[weekKey] ?? 0) + 1;
    }
  }

  final now = DateTime.now();
  int currentWeekCount = appsPerWeek[isoWeekKey(now)] ?? 0;
  bool isGoalMetThisWeek = currentWeekCount >= goal;

  int streak = 0;

  // If the goal is met this week, it counts towards the streak immediately
  if (isGoalMetThisWeek) {
    streak++;
  }

  // Count backwards from LAST week
  // Kalenderarithmetik statt Duration, damit DST-Wechsel keinen Tag verschieben.
  DateTime checkDate = DateTime(now.year, now.month, now.day - 7);

  while (true) {
    final checkWeekKey = isoWeekKey(checkDate);
    final count = appsPerWeek[checkWeekKey] ?? 0;

    if (count >= goal) {
      streak++;
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 7);
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

/// Liefert den ISO-8601-Wochenschlüssel (z.B. "2026-W36") für [date].
///
/// Es zählt nur das Kalenderdatum (Jahr/Monat/Tag); gerechnet wird in UTC,
/// damit Sommerzeitwechsel keine Off-by-one-Fehler verursachen.
String isoWeekKey(DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  // Donnerstag derselben ISO-Woche bestimmt das Wochenjahr.
  final thursday = day.add(Duration(days: DateTime.thursday - day.weekday));
  final year = thursday.year;
  final ordinalDay =
      thursday.difference(DateTime.utc(year, 1, 1)).inDays + 1; // 1-basiert
  final week = ((ordinalDay - 1) ~/ 7) + 1;
  return "$year-W${week.toString().padLeft(2, '0')}";
}
