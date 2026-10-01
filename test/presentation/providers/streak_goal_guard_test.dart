import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import 'package:career_center/presentation/providers/applications_provider.dart';
import 'package:career_center/presentation/providers/database_provider.dart';
import 'package:career_center/presentation/providers/streak_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ApplicationEntity _app(int id, DateTime applied) => ApplicationEntity(
      id: id,
      company: 'A',
      position: 'P',
      status: 'offen',
      priority: 1,
      appliedDate: applied,
      createdAt: applied,
      updatedAt: applied,
    );

Future<StreakData> _computeStreak(List<ApplicationEntity> apps, int goal) async {
  final container = ProviderContainer(
    overrides: [
      applicationsProvider.overrideWith((ref) => Stream.value(apps)),
      weeklyGoalProvider.overrideWith((ref) => Future.value(goal)),
    ],
  );
  addTearDown(container.dispose);
  final subApps = container.listen(applicationsProvider, (_, _) {});
  final subGoal = container.listen(weeklyGoalProvider, (_, _) {});
  addTearDown(subApps.close);
  addTearDown(subGoal.close);
  await container.read(applicationsProvider.future);
  await container.read(weeklyGoalProvider.future);
  final state = container.read(streakProvider);
  expect(state.hasValue, isTrue);
  return state.value!;
}

void main() {
  group('Wochenziel <= 0 darf keine Endlosschleife erzeugen', () {
    test('sanitizeWeeklyGoal klemmt auf mindestens 1', () {
      expect(sanitizeWeeklyGoal(0), 1);
      expect(sanitizeWeeklyGoal(-3), 1);
      expect(sanitizeWeeklyGoal(null), defaultWeeklyGoal);
      expect(sanitizeWeeklyGoal(7), 7);
    });

    for (final goal in [0, -3]) {
      test('Ziel $goal ohne Bewerbungen terminiert', () async {
        final data = await _computeStreak(const [], goal)
            .timeout(const Duration(seconds: 5));
        expect(data.weeklyGoal, 1);
        expect(data.streakCount, 0);
        expect(data.isGoalMetThisWeek, isFalse);
      });

      test('Ziel $goal mit Bewerbungen terminiert und zählt korrekt', () async {
        final now = DateTime.now();
        final apps = [
          _app(1, now),
          _app(2, DateTime(now.year, now.month, now.day - 7)),
        ];
        final data = await _computeStreak(apps, goal)
            .timeout(const Duration(seconds: 5));
        expect(data.weeklyGoal, 1);
        expect(data.streakCount, 2);
      });
    }

    test('Streak ist auf maxStreakWeeks begrenzt', () async {
      final now = DateTime.now();
      final apps = [
        for (var i = 0; i <= maxStreakWeeks + 5; i++)
          _app(i, DateTime(now.year, now.month, now.day - 7 * i)),
      ];
      final data = await _computeStreak(apps, 1);
      expect(data.streakCount, lessThanOrEqualTo(maxStreakWeeks + 1));
    });

    for (final stored in ['0', '-3', 'abc']) {
      test('weeklyGoalProvider liefert >= 1 für gespeicherten Wert "$stored"',
          () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        await db.settingsDao.insertOrUpdateSetting(
            Setting(key: 'weeklyApplicationGoal', value: stored));
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db)],
        );
        addTearDown(container.dispose);
        final goal = await container.read(weeklyGoalProvider.future);
        expect(goal, greaterThanOrEqualTo(1));
      });
    }
  });
}
