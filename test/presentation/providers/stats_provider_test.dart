import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_center/presentation/providers/stats_provider.dart';
import 'package:career_center/presentation/providers/applications_provider.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import 'dart:async';

void main() {
  group('StatsProvider', () {
    test('Calculates statistics correctly for empty list', () async {
      final container = ProviderContainer(
        overrides: [
          applicationsProvider.overrideWith((ref) => Stream.value([])),
        ],
      );

      final sub = container.listen(applicationsProvider, (_, __) {});
      // Wait for stream to emit
      await container.read(applicationsProvider.future);
      final stats = container.read(statsProvider);

      expect(stats.total, 0);
      expect(stats.open, 0);
      expect(stats.rejected, 0);
      expect(stats.accepted, 0);
      expect(stats.interview, 0);
      sub.close();
    });

    test('Calculates statistics correctly for mixed application statuses', () async {
      final apps = [
        ApplicationEntity(
          id: 1,
          company: 'A',
          position: 'Dev',
          status: 'offen', // -> open
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ApplicationEntity(
          id: 2,
          company: 'B',
          position: 'Dev',
          status: 'versendet', // -> open
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ApplicationEntity(
          id: 3,
          company: 'C',
          position: 'Dev',
          status: 'absage', // -> rejected
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ApplicationEntity(
          id: 4,
          company: 'D',
          position: 'Dev',
          status: 'ABSAGE', // -> rejected (case insensitive)
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ApplicationEntity(
          id: 5,
          company: 'E',
          position: 'Dev',
          status: 'zusage', // -> accepted
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ApplicationEntity(
          id: 6,
          company: 'F',
          position: 'Dev',
          status: 'interview', // -> interview
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ApplicationEntity(
          id: 7,
          company: 'G',
          position: 'Dev',
          status: 'unknown_status', // -> open (default fallback)
          priority: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          applicationsProvider.overrideWith((ref) => Stream.value(apps)),
        ],
      );
      
      final sub = container.listen(applicationsProvider, (_, __) {});

      // Force stream resolution
      await container.read(applicationsProvider.future);
      final stats = container.read(statsProvider);

      expect(stats.total, 7);
      expect(stats.open, 3); // offen, versendet, unknown_status
      expect(stats.rejected, 2); // absage, ABSAGE
      expect(stats.accepted, 1); // zusage
      expect(stats.interview, 1); // interview
      sub.close();
    });

    test('Handles error state from applicationsProvider gracefully', () async {
      final container = ProviderContainer(
        overrides: [
          applicationsProvider.overrideWith((ref) => Stream.error('Database Error')),
        ],
      );

      final sub = container.listen(applicationsProvider, (_, __) {});

      await Future.delayed(const Duration(milliseconds: 10));
      
      final stats = container.read(statsProvider);

      // Should fallback to empty list logic
      expect(stats.total, 0);
      expect(stats.open, 0);
      sub.close();
    });
  });
}
