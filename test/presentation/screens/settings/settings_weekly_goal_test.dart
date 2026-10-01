import 'dart:io';

import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/l10n/app_localizations.dart';
import 'package:career_center/presentation/providers/auto_updater_provider.dart';
import 'package:career_center/presentation/providers/database_provider.dart';
import 'package:career_center/presentation/screens/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _FakeAutoUpdaterNotifier extends AutoUpdaterNotifier {
  @override
  Future<void> checkForUpdates({bool isManual = false}) async {}
}

class _FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _FakePathProvider(this.path);
  final String path;
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('settings_goal_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    PackageInfo.setMockInitialValues(
      appName: 'App', packageName: 'com.app', version: '1.0.0', buildNumber: '1', buildSignature: 'test',
    );
  });

  tearDown(() {
    try { tempDir.deleteSync(recursive: true); } catch (_) {}
  });

  Future<AppDatabase> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          autoUpdaterProvider.overrideWith(_FakeAutoUpdaterNotifier.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  Finder goalField() => find.widgetWithText(TextField, 'Wöchentliches Bewerbungsziel');

  test('parseWeeklyGoal accepts only 1..100', () {
    expect(parseWeeklyGoal('1'), 1);
    expect(parseWeeklyGoal('100'), 100);
    expect(parseWeeklyGoal(' 7 '), 7);
    expect(parseWeeklyGoal('0'), isNull);
    expect(parseWeeklyGoal('101'), isNull);
    expect(parseWeeklyGoal(''), isNull);
    expect(parseWeeklyGoal('-3'), isNull);
    expect(parseWeeklyGoal('5a'), isNull);
  });

  testWidgets('weekly goal field filters non-digits and rejects out-of-range values', (tester) async {
    final db = await pumpSettings(tester);
    await tester.tap(find.text('Bewerbungs-Setup'));
    await tester.pumpAndSettle();

    await tester.enterText(goalField(), '1a5x0');
    expect(tester.widget<TextField>(goalField()).controller!.text, '150');

    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect(find.textContaining('zwischen 1 und 100'), findsWidgets);
    expect(await db.settingsDao.getSettingByKey('weeklyApplicationGoal'), isNull);

    ScaffoldMessenger.of(tester.element(find.byType(SettingsScreen))).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.enterText(goalField(), '12');
    await tester.ensureVisible(find.text('Speichern'));
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();
    expect((await db.settingsDao.getSettingByKey('weeklyApplicationGoal'))?.value, '12');

    // Pending secure-storage timeouts and SnackBar timers.
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    await db.close();
  });

  testWidgets('Export & Backup shows the recovery key entry', (tester) async {
    final db = await pumpSettings(tester);
    await tester.tap(find.text('Export & Backup'));
    await tester.pumpAndSettle();
    expect(find.text('Wiederherstellungsschlüssel anzeigen'), findsOneWidget);

    await tester.tap(find.text('Wiederherstellungsschlüssel anzeigen'));
    await tester.pumpAndSettle();
    expect(find.text('Wiederherstellungsschlüssel anzeigen?'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    await db.close();
  });

  testWidgets('shows a banner when a locked database was set aside', (tester) async {
    File(p.join(tempDir.path, 'career_center.sqlite.locked-2026-10-01T12-00-00')).writeAsBytesSync(List.filled(1024, 7));
    final db = await pumpSettings(tester);
    expect(find.textContaining('konnte nicht geöffnet werden'), findsOneWidget);

    await tester.tap(find.text('Verstanden'));
    await tester.pumpAndSettle();
    expect(find.textContaining('konnte nicht geöffnet werden'), findsNothing);
    expect((await db.settingsDao.getSettingByKey('lockedDbNoticeDismissed'))?.value,
        'career_center.sqlite.locked-2026-10-01T12-00-00');

    await db.close();
  });
}
