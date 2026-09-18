import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_center/presentation/screens/applications/applications_screen.dart';
import 'package:career_center/presentation/providers/applications_provider.dart';
import 'package:career_center/core/services/extractors/magic_clipboard_service.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import 'package:career_center/l10n/app_localizations.dart';

// --- Mocks ---

class FakeMagicClipboardService extends MagicClipboardService {
  final MagicClipboardResult? fakeResult;

  FakeMagicClipboardService(this.fakeResult);

  @override
  Future<MagicClipboardResult?> analyzeClipboard(List<ApplicationEntity> existingApps) async {
    return fakeResult;
  }
}

class FakeApplicationNotifier extends ApplicationNotifier {
  bool updateCalled = false;
  int? updatedId;
  String? updatedStatus;
  String? updatedRejectionReason;

  FakeApplicationNotifier(super.ref);

  @override
  Future<void> updateApplicationStatus(int id, String status, {String? rejectionReason}) async {
    updateCalled = true;
    updatedId = id;
    updatedStatus = status;
    updatedRejectionReason = rejectionReason;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockApp = ApplicationEntity(
    id: 99,
    company: 'TestCompany',
    position: 'Tester',
    status: 'versendet',
    priority: 2,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  testWidgets('Magic Clipboard Button triggers status update flow', (WidgetTester tester) async {
    final fakeResult = MagicClipboardResult(
      matchedApplication: mockApp,
      detectedStatus: 'absage',
      originalText: 'Leider müssen wir Ihnen eine Absage erteilen.',
    );

    final fakeMagicService = FakeMagicClipboardService(fakeResult);

    late FakeApplicationNotifier fakeNotifier;

    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          applicationsProvider.overrideWith((ref) => Stream.value([mockApp])),
          magicClipboardProvider.overrideWithValue(fakeMagicService),
          applicationNotifierProvider.overrideWith((ref) {
            fakeNotifier = FakeApplicationNotifier(ref);
            return fakeNotifier;
          }),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('de'),
          home: ApplicationsScreen(),
        ),
      ),
    );

    // Warten, bis der StreamProvider die Daten geladen hat
    await tester.pumpAndSettle();

    // 1. Button finden und klicken
    final buttonFinder = find.widgetWithText(FilledButton, 'Zwischenablage auswerten').first;
    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // 2. Prüfen, ob der Dialog erschienen ist
    expect(find.text('Status-Update gefunden!'), findsOneWidget);
    expect(find.text('Soll der Status für "Tester" bei "TestCompany" auf "absage" gesetzt werden?'), findsOneWidget);

    // 3. Auf "Aktualisieren" klicken
    final updateButtonFinder = find.widgetWithText(FilledButton, 'Aktualisieren');
    expect(updateButtonFinder, findsOneWidget);
    await tester.tap(updateButtonFinder);
    await tester.pump(const Duration(seconds: 1)); // Wait for dialog to dismiss and snackbar to appear

    // 4. Prüfen, ob der Notifier korrekt mit dem Text als Absagegrund aufgerufen wurde
    expect(fakeNotifier.updateCalled, isTrue);
    expect(fakeNotifier.updatedId, 99);
    expect(fakeNotifier.updatedStatus, 'absage');
    expect(fakeNotifier.updatedRejectionReason, 'Leider müssen wir Ihnen eine Absage erteilen.');
    
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });
}
