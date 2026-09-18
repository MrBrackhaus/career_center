import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path/path.dart' as p;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:career_center/presentation/screens/settings/settings_screen.dart';
import 'package:career_center/l10n/app_localizations.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/providers/database_provider.dart';
import 'package:career_center/presentation/providers/auto_updater_provider.dart';

class FakeAutoUpdaterNotifier extends AutoUpdaterNotifier {
  @override
  Future<void> checkForUpdates({bool isManual = false}) async {}
}

class FakePathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  final String path;
  FakePathProviderPlatform(this.path);
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('career_center_test_dir');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);

    PackageInfo.setMockInitialValues(
      appName: 'App', packageName: 'com.app', version: '1.0.0', buildNumber: '1', buildSignature: 'test',
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      try { tempDir.deleteSync(recursive: true); } catch (_) {}
    }
  });

  testWidgets('SettingsScreen UI Renders Correctly and shows Export & Backup tab', (WidgetTester tester) async {
    final liveDbFile = File(p.join(tempDir.path, 'career_center.sqlite'));
    final db = AppDatabase.forTesting(NativeDatabase(liveDbFile));
    await db.customStatement('PRAGMA user_version = 1;');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          autoUpdaterProvider.overrideWith(FakeAutoUpdaterNotifier.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: SettingsScreen(),
        ),
      ),
    );

    // Initial loading state
    await tester.pumpAndSettle();

    // Assert that the Export & Backup tab exists in the NavigationRail
    final backupTab = find.text('Export & Backup');
    expect(backupTab, findsOneWidget);

    // Tap it
    await tester.ensureVisible(backupTab);
    await tester.tap(backupTab);
    await tester.pumpAndSettle();

    // Verify backup buttons exist
    expect(find.text('Backup erstellen'), findsOneWidget);
    expect(find.text('Backup wiederherstellen'), findsOneWidget);
    expect(find.text('Als PDF exportieren'), findsOneWidget);
    expect(find.text('Als CSV exportieren'), findsOneWidget);

    await db.close();
  });
}
