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

  Future<void> checkForUpdates({bool isManual = false}) async {
    if (state.status == UpdaterStatus.checking || state.status == UpdaterStatus.downloading) return;
    
    state = state.copyWith(status: UpdaterStatus.checking, clearError: true);
    
    try {
      final info = await _service.checkForUpdates();
      if (info != null) {
        state = state.copyWith(status: UpdaterStatus.available, updateInfo: info);
      } else {
        state = state.copyWith(status: UpdaterStatus.upToDate);
        if (!isManual) {
          // Reset to idle after a while if it was an automatic check
          Future.delayed(const Duration(seconds: 5), () {
            if (ref.mounted && state.status == UpdaterStatus.upToDate) {
              state = state.copyWith(status: UpdaterStatus.idle);
            }
          });
        }
      }
    } catch (e) {
      state = state.copyWith(status: UpdaterStatus.error, errorMessage: e.toString());
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
