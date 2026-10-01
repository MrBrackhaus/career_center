import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_center/presentation/providers/streak_provider.dart';
import 'package:career_center/presentation/providers/applications_provider.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import 'dart:async';

void main() {
  group('StreakProvider', () {
    test('Returns loading state initially', () {
      final container = ProviderContainer(
        overrides: [
          applicationsProvider.overrideWith((ref) => const Stream.empty()),
          weeklyGoalProvider.overrideWith((ref) => Future.value(5)), // Won't resolve instantly without await
        ],
      );

      final state = container.read(streakProvider);
      expect(state.isLoading, isTrue);
    });

    test('Calculates streak correctly for active streak (Goal=2)', () async {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final twoWeeksAgo = now.subtract(const Duration(days: 14));
      final threeWeeksAgo = now.subtract(const Duration(days: 21));

      final apps = [
        // This week (2 apps -> Goal met)
        ApplicationEntity(id: 1, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: now, createdAt: now, updatedAt: now),
        ApplicationEntity(id: 2, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: now, createdAt: now, updatedAt: now),
        // 1 week ago (2 apps -> Goal met)
        ApplicationEntity(id: 3, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: oneWeekAgo, createdAt: now, updatedAt: now),
        ApplicationEntity(id: 4, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: oneWeekAgo, createdAt: now, updatedAt: now),
        // 2 weeks ago (1 app -> Goal NOT met)
        ApplicationEntity(id: 5, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: twoWeeksAgo, createdAt: now, updatedAt: now),
        // 3 weeks ago (2 apps -> Goal met, but streak was broken)
        ApplicationEntity(id: 6, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: threeWeeksAgo, createdAt: now, updatedAt: now),
        ApplicationEntity(id: 7, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: threeWeeksAgo, createdAt: now, updatedAt: now),
      ];

      final container = ProviderContainer(
        overrides: [
          applicationsProvider.overrideWith((ref) => Stream.value(apps)),
          weeklyGoalProvider.overrideWith((ref) => Future.value(2)),
        ],
      );

      final subApps = container.listen(applicationsProvider, (_, __) {});
      final subGoal = container.listen(weeklyGoalProvider, (_, __) {});

      // Wait for providers to emit
      await container.read(applicationsProvider.future);
      await container.read(weeklyGoalProvider.future);

      final state = container.read(streakProvider);
      
      expect(state.hasValue, isTrue);
      final data = state.value!;
      
      expect(data.weeklyGoal, 2);
      expect(data.currentWeekCount, 2);
      expect(data.isGoalMetThisWeek, isTrue);
      // Streak should be 2 (this week and last week)
      expect(data.streakCount, 2);
      subApps.close();
      subGoal.close();
    });

    test('Calculates streak when goal is NOT met this week, but was met previous weeks', () async {
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      final twoWeeksAgo = now.subtract(const Duration(days: 14));

      final apps = [
        // This week (1 app -> Goal NOT met, goal is 3)
        ApplicationEntity(id: 1, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: now, createdAt: now, updatedAt: now),
        // 1 week ago (3 apps -> Goal met)
        ApplicationEntity(id: 2, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: oneWeekAgo, createdAt: now, updatedAt: now),
        ApplicationEntity(id: 3, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: oneWeekAgo, createdAt: now, updatedAt: now),
        ApplicationEntity(id: 4, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: oneWeekAgo, createdAt: now, updatedAt: now),
        // 2 weeks ago (3 apps -> Goal met)
        ApplicationEntity(id: 5, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: twoWeeksAgo, createdAt: now, updatedAt: now),
        ApplicationEntity(id: 6, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: twoWeeksAgo, createdAt: now, updatedAt: now),
        ApplicationEntity(id: 7, company: 'A', position: 'P', status: 'offen', priority: 1, appliedDate: twoWeeksAgo, createdAt: now, updatedAt: now),
      ];

      final container = ProviderContainer(
        overrides: [
          applicationsProvider.overrideWith((ref) => Stream.value(apps)),
          weeklyGoalProvider.overrideWith((ref) => Future.value(3)),
        ],
      );

      final subApps = container.listen(applicationsProvider, (_, __) {});
      final subGoal = container.listen(weeklyGoalProvider, (_, __) {});

      // Wait for providers to emit
      await container.read(applicationsProvider.future);
      await container.read(weeklyGoalProvider.future);

      final state = container.read(streakProvider);
      
      expect(state.hasValue, isTrue);
      final data = state.value!;
      
      expect(data.weeklyGoal, 3);
      expect(data.currentWeekCount, 1);
      expect(data.isGoalMetThisWeek, isFalse);
      
      // Since the goal is not met THIS week, but the week is not over, 
      // the streak still carries over from previous weeks!
      // In streak_provider.dart:
      // If current week goal not met, streak = previous weeks streak
      expect(data.streakCount, 2);
      subApps.close();
      subGoal.close();
    });
  });

  group('isoWeekKey', () {
    test('Jahreswechsel mit 53 Wochen', () {
      expect(isoWeekKey(DateTime(2020, 12, 31)), '2020-W53');
      expect(isoWeekKey(DateTime(2021, 1, 1)), '2020-W53');
      expect(isoWeekKey(DateTime(2021, 1, 3)), '2020-W53');
      expect(isoWeekKey(DateTime(2021, 1, 4)), '2021-W01');
    });

    test('Jahreswechsel 2026/2027', () {
      expect(isoWeekKey(DateTime(2026, 12, 31)), '2026-W53');
      expect(isoWeekKey(DateTime(2027, 1, 1)), '2026-W53');
      expect(isoWeekKey(DateTime(2027, 1, 4)), '2027-W01');
    });

    test('Jahreswechsel, an dem der 29.12. schon zur Woche 1 gehört', () {
      expect(isoWeekKey(DateTime(2025, 12, 28)), '2025-W52');
      expect(isoWeekKey(DateTime(2025, 12, 29)), '2026-W01');
      expect(isoWeekKey(DateTime(2026, 1, 1)), '2026-W01');
    });

    test('Erster Tag des Jahres und Wochenanfang', () {
      expect(isoWeekKey(DateTime(2024, 1, 1)), '2024-W01');
      expect(isoWeekKey(DateTime(2023, 1, 1)), '2022-W52');
      expect(isoWeekKey(DateTime(2026, 10, 1)), '2026-W40');
    });

    test('Uhrzeit und DST-Wechsel spielen keine Rolle', () {
      // Sommerzeitbeginn (29.03.2026) und -ende (25.10.2026) in Mitteleuropa
      expect(isoWeekKey(DateTime(2026, 3, 29, 23, 59)), '2026-W13');
      expect(isoWeekKey(DateTime(2026, 3, 30, 0, 1)), '2026-W14');
      expect(isoWeekKey(DateTime(2026, 10, 25, 23, 30)), '2026-W43');
      expect(isoWeekKey(DateTime(2026, 10, 26)), '2026-W44');
    });
  });
}
