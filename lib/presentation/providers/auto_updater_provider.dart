import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auto_updater_service.dart';

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
    File? installerFile,
  }) {
    return AutoUpdaterState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
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
    
    state = state.copyWith(status: UpdaterStatus.checking, errorMessage: null);
    
    try {
      final info = await _service.checkForUpdates();
      if (info != null) {
        state = state.copyWith(status: UpdaterStatus.available, updateInfo: info);
      } else {
        state = state.copyWith(status: UpdaterStatus.upToDate);
        if (!isManual) {
          // Reset to idle after a while if it was an automatic check
          Future.delayed(const Duration(seconds: 5), () {
            if (true && state.status == UpdaterStatus.upToDate) {
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
    if (state.updateInfo == null) return;

    state = state.copyWith(status: UpdaterStatus.downloading, downloadProgress: 0.0);
    
    final file = await _service.downloadUpdate(
      state.updateInfo!.downloadUrl,
      (progress) {
        state = state.copyWith(downloadProgress: progress);
      },
    );

    if (file != null) {
      state = state.copyWith(status: UpdaterStatus.readyToInstall, installerFile: file);
    } else {
      state = state.copyWith(status: UpdaterStatus.error, errorMessage: 'Download fehlgeschlagen');
    }
  }

  Future<void> installUpdate() async {
    if (state.installerFile != null) {
      await _service.installAndRestart(state.installerFile!);
    }
  }
  
  void dismissUpdate() {
    state = const AutoUpdaterState(status: UpdaterStatus.idle);
  }
}

final autoUpdaterProvider = NotifierProvider<AutoUpdaterNotifier, AutoUpdaterState>(AutoUpdaterNotifier.new);
