import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auto_updater_service.dart';
import 'database_provider.dart';

enum UpdaterStatus {
  idle,
  checking,
  available,
  upToDate,
  downloading,
  readyToInstall,
  error,
}

class AutoUpdaterState {
  final UpdaterStatus status;
  final UpdateInfo? updateInfo;
  final double downloadProgress;
  final String? errorMessage;
  final File? installerFile;

  const AutoUpdaterState({
    this.status = UpdaterStatus.idle,
    this.updateInfo,
    this.downloadProgress = 0.0,
    this.errorMessage,
    this.installerFile,
  });

  AutoUpdaterState copyWith({
    UpdaterStatus? status,
    UpdateInfo? updateInfo,
    double? downloadProgress,
    String? errorMessage,
    bool clearError = false,
    File? installerFile,
  }) {
    return AutoUpdaterState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      installerFile: installerFile ?? this.installerFile,
    );
  }
}

final autoUpdaterServiceProvider = Provider<AutoUpdaterService>((ref) {
  return AutoUpdaterService();
});

class AutoUpdaterNotifier extends Notifier<AutoUpdaterState> {
  @override
  AutoUpdaterState build() => const AutoUpdaterState();

  AutoUpdaterService get _service => ref.read(autoUpdaterServiceProvider);

  /// Wurde in dieser Sitzung bereits automatisch nach Updates gesucht?
  bool _autoCheckedThisSession = false;

  /// Sucht nach Updates.
  ///
  /// Automatische Prüfungen (`isManual == false`, z.B. beim Öffnen des
  /// Dashboards) laufen nur einmal pro Sitzung. Ist bereits ein Update
  /// verfügbar, wird gerade geladen oder ist zur Installation bereit, wird
  /// der Zustand nie überschrieben.
  Future<void> checkForUpdates({bool isManual = false}) async {
    const busyStates = {
      UpdaterStatus.checking,
      UpdaterStatus.downloading,
      UpdaterStatus.available,
      UpdaterStatus.readyToInstall,
    };
    if (busyStates.contains(state.status)) return;

    if (!isManual) {
      if (_autoCheckedThisSession) return;
      _autoCheckedThisSession = true;
    }

    state = state.copyWith(status: UpdaterStatus.checking, clearError: true);

    try {
      final info = await _service.checkForUpdates();
      if (!ref.mounted) return;
      if (info != null) {
        state = state.copyWith(status: UpdaterStatus.available, updateInfo: info);
      } else if (isManual) {
        state = state.copyWith(status: UpdaterStatus.upToDate);
      } else {
        // Der Service liefert `null` sowohl bei "kein Update" als auch bei
        // Netzwerkfehlern (offline). Eine automatische Prüfung zeigt daher
        // keinen Banner an, statt fälschlich "auf dem neuesten Stand" zu
        // behaupten.
        state = state.copyWith(status: UpdaterStatus.idle);
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = isManual
          ? state.copyWith(status: UpdaterStatus.error, errorMessage: e.toString())
          : state.copyWith(status: UpdaterStatus.idle);
    }
  }

  Future<void> downloadUpdate() async {
    final info = state.updateInfo;
    if (info == null) return;

    state = state.copyWith(
      status: UpdaterStatus.downloading,
      downloadProgress: 0.0,
      clearError: true,
    );

    try {
      final file = await _service.downloadUpdate(
        info.downloadUrl,
        (progress) {
          state = state.copyWith(downloadProgress: progress);
        },
        expectedSha256: info.sha256,
      );

      if (file != null) {
        state = state.copyWith(status: UpdaterStatus.readyToInstall, installerFile: file);
      } else {
        state = state.copyWith(status: UpdaterStatus.error, errorMessage: 'Download fehlgeschlagen');
      }
    } on UpdateIntegrityException catch (e) {
      state = state.copyWith(status: UpdaterStatus.error, errorMessage: e.toString());
    } catch (e) {
      state = state.copyWith(status: UpdaterStatus.error, errorMessage: 'Download fehlgeschlagen: $e');
    }
  }

  Future<void> installUpdate() async {
    final file = state.installerFile;
    if (file == null) return;
    try {
      await _service.installAndRestart(
        file,
        // Datenbank sauber schließen, bevor der Prozess mit exit(0) endet.
        beforeExit: () => ref.read(databaseProvider).close(),
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdaterStatus.error,
        errorMessage: 'Installation fehlgeschlagen: $e',
      );
    }
  }

  void dismissUpdate() {
    state = const AutoUpdaterState(status: UpdaterStatus.idle);
  }
}

final autoUpdaterProvider = NotifierProvider<AutoUpdaterNotifier, AutoUpdaterState>(AutoUpdaterNotifier.new);
