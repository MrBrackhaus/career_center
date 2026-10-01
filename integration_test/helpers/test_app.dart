// Shared harness for the integration/workflow tests.
//
// Every workflow test MUST start the app through [pumpTestApp] instead of
// calling `app.main()`:
//
// * `app.main()` opens the REAL user database
//   (Documents/career_center.sqlite) – tests used to delete/overwrite the
//   user's applications and profile. The harness overrides [databaseProvider]
//   with a fresh in-memory database per test.
// * `app.main()` configures window_manager (setPreventClose etc.), which is
//   not wanted in tests.
// * The companion HTTP server (singleton, fixed port 47392) is started by
//   `companionProvider`. The harness replaces it with [FakeCompanionNotifier]
//   so no port is bound and tests can inject browser-extension events.
// * The auto-updater would hit api.github.com from the dashboard; it is
//   replaced with an offline fake.
// * Secure storage / shared preferences / package info are replaced with
//   in-memory mocks so the real OS keychain (DB key, AI API key, IMAP
//   password, companion token) is never read or overwritten.
import 'dart:io';

import 'package:career_center/app.dart';
import 'package:career_center/core/router/app_router.dart';
import 'package:career_center/core/services/auto_updater_service.dart';
import 'package:career_center/core/services/companion_server_service.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/providers/auto_updater_provider.dart';
import 'package:career_center/presentation/providers/companion_provider.dart';
import 'package:career_center/presentation/providers/database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
// Transitive dependency of path_provider; used only to sandbox file IO.
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Companion notifier that never starts the HTTP server. Tests can push
/// events (as if the browser extension had called `/api/import`) via [emit].
class FakeCompanionNotifier extends CompanionNotifier {
  @override
  CompanionEvent? build() => null;

  void emit(CompanionEvent event) => state = event;
}

/// Auto-updater that never touches the network.
class OfflineAutoUpdaterService extends AutoUpdaterService {
  @override
  Future<UpdateInfo?> checkForUpdates() async => null;
}

/// Redirects every path_provider directory into a throw-away temp folder so
/// tests never read or write the user's real Documents folder (database,
/// ML model, generated documents, screenshots).
class SandboxPathProvider extends PathProviderPlatform {
  SandboxPathProvider(this.root);

  final Directory root;

  Future<String> _dir(String name) async {
    final d = Directory(p.join(root.path, name));
    await d.create(recursive: true);
    return d.path;
  }

  @override
  Future<String?> getTemporaryPath() => _dir('tmp');
  @override
  Future<String?> getApplicationSupportPath() => _dir('support');
  @override
  Future<String?> getLibraryPath() => _dir('library');
  @override
  Future<String?> getApplicationDocumentsPath() => _dir('documents');
  @override
  Future<String?> getApplicationCachePath() => _dir('cache');
  @override
  Future<String?> getDownloadsPath() => _dir('downloads');
}

/// Installs in-memory/sandboxed replacements for every plugin that would
/// otherwise touch real user data (keychain, prefs, Documents folder).
/// Called by [pumpTestApp]; call it directly in tests that do not pump the
/// app but use services with file IO (e.g. DocumentIntelligenceService).
void installSandbox() {
  FlutterSecureStorage.setMockInitialValues({});
  SharedPreferences.setMockInitialValues({});
  PackageInfo.setMockInitialValues(
    appName: 'career_center',
    packageName: 'career_center',
    version: '0.0.0-test',
    buildNumber: '0',
    buildSignature: '',
  );
  final root = Directory.systemTemp.createTempSync('career_center_test_');
  PathProviderPlatform.instance = SandboxPathProvider(root);
  addTearDown(() {
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });
}

/// Handle returned by [pumpTestApp].
class TestApp {
  TestApp(this.db, this.container);

  /// The in-memory database backing this app instance.
  final AppDatabase db;

  /// The provider container the app runs in.
  final ProviderContainer container;

  FakeCompanionNotifier get companion =>
      container.read(companionProvider.notifier) as FakeCompanionNotifier;

  /// Reads a raw setting value from the test database.
  Future<String?> setting(String key) async =>
      (await db.settingsDao.getSettingByKey(key))?.value;
}

/// Default logical window size – wide enough for the desktop layout
/// (extended NavigationRail, > 1000 px).
const Size kDesktopSize = Size(1920, 1080);

/// Starts [JobTrackerApp] against a fresh in-memory database.
///
/// [settings] are written before the app is built (the tutorial is always
/// marked as seen and the language is forced to German so text finders are
/// stable). [seed] runs before the first frame and can insert fixtures.
Future<TestApp> pumpTestApp(
  WidgetTester tester, {
  Map<String, String> settings = const {},
  Future<void> Function(AppDatabase db)? seed,
  Size size = kDesktopSize,
  String initialLocation = '/applications',
  List<Override> overrides = const [],
}) async {
  // Never touch the real keychain / prefs / Documents folder.
  installSandbox();

  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  final allSettings = <String, String>{
    'has_seen_tutorial': 'true',
    'app_language': 'de',
    ...settings,
  };
  await tester.runAsync(() async {
    for (final e in allSettings.entries) {
      await db.settingsDao
          .insertOrUpdateSetting(Setting(key: e.key, value: e.value));
    }
    if (seed != null) await seed(db);
  });

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      companionProvider.overrideWith(FakeCompanionNotifier.new),
      autoUpdaterServiceProvider.overrideWithValue(OfflineAutoUpdaterService()),
      ...overrides,
    ],
  );
  addTearDown(() async {
    // Unmount first so stream subscriptions are cancelled before the
    // database is closed.
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    // Bounded: a close stuck behind a pending query must not hang the suite.
    await tester.runAsync(
      () => db.close().timeout(const Duration(seconds: 5), onTimeout: () {}),
    );
  });

  // appRouter is a global singleton – reset its location for every test.
  appRouter.go(initialLocation);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const JobTrackerApp(),
    ),
  );
  await settle(tester);
  return TestApp(db, container);
}

/// Pumps until the UI is idle (no frame scheduled) or [maxRounds] is hit.
///
/// Database work runs on real async (drift), so every round also yields to
/// the real event loop. Unlike `pumpAndSettle` this never throws/hangs on
/// screens with endless animations (progress indicators, blinking cursor).
Future<void> settle(WidgetTester tester, {int minRounds = 3, int maxRounds = 50}) async {
  for (var i = 0; i < maxRounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (i + 1 >= minRounds && !tester.binding.hasScheduledFrame) break;
  }
}

/// Navigates the app's global router to [location] (like a deep link).
Future<void> goTo(WidgetTester tester, String location) async {
  appRouter.go(location);
  await settle(tester);
}

/// Pumps until [finder] matches at least one widget or [timeout] elapses.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('Timed out waiting for $finder');
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Taps a widget found by [finder] after scrolling it into view.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  // Let pending focus/scroll animations finish first, otherwise they can
  // scroll the target out of view again after ensureVisible.
  await settle(tester, minRounds: 1);
  await tester.ensureVisible(finder);
  await settle(tester, minRounds: 1);
  await tester.tap(finder);
  await settle(tester);
}

/// Finds a [TextFormField]/[TextField] by its label text (exact match).
Finder fieldByLabel(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (w) => w is TextField,
        description: 'TextField labelled "$label"',
      ),
    );

/// Absolute path of a fixture in integration_test/mock_server, resolved
/// relative to the package root (works on every machine, unlike the old
/// hard-coded `s:/Projekte/...` paths).
String fixturePath(String name) {
  final candidates = [
    p.join(Directory.current.path, 'integration_test', 'mock_server', name),
    p.join(Directory.current.path, '..', 'integration_test', 'mock_server',
        name),
  ];
  for (final c in candidates) {
    if (File(c).existsSync()) return p.normalize(c);
  }
  return p.normalize(candidates.first);
}

/// `true` when tests that need the public internet were explicitly enabled
/// with `--dart-define=RUN_NETWORK_TESTS=true`.
const bool kRunNetworkTests = bool.fromEnvironment('RUN_NETWORK_TESTS');

/// Network-dependent tests are skipped unless explicitly enabled.
const bool kSkipNetworkTests = !kRunNetworkTests;
