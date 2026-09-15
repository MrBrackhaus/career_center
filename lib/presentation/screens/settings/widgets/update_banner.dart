import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auto_updater_provider.dart';

class UpdateBanner extends ConsumerWidget {
  const UpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(autoUpdaterProvider);
    final notifier = ref.read(autoUpdaterProvider.notifier);

    if (state.status == UpdaterStatus.idle || state.status == UpdaterStatus.checking) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.system_update, color: colorScheme.onPrimaryContainer, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getTitle(state.status, state.updateInfo?.version),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                if (state.status == UpdaterStatus.available || state.status == UpdaterStatus.error || state.status == UpdaterStatus.upToDate)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => notifier.dismissUpdate(),
                  ),
              ],
            ),
            if (state.status == UpdaterStatus.available && state.updateInfo != null) ...[
              const SizedBox(height: 8),
              Text(
                'Release Notes:',
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 100),
                child: SingleChildScrollView(
                  child: Text(
                    state.updateInfo!.releaseNotes,
                    style: TextStyle(fontSize: 13, color: colorScheme.onPrimaryContainer),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => notifier.downloadUpdate(),
                  icon: const Icon(Icons.download),
                  label: const Text('Update herunterladen'),
                ),
              ),
            ],
            if (state.status == UpdaterStatus.downloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: state.downloadProgress,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                'Wird heruntergeladen... ${(state.downloadProgress * 100).toStringAsFixed(1)}%',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ],
            if (state.status == UpdaterStatus.readyToInstall) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => notifier.installUpdate(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Jetzt installieren & neustarten'),
                ),
              ),
            ],
            if (state.status == UpdaterStatus.error) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Unbekannter Fehler',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTitle(UpdaterStatus status, String? version) {
    switch (status) {
      case UpdaterStatus.available:
        return 'Neue Version $version verfügbar!';
      case UpdaterStatus.upToDate:
        return 'Die App ist auf dem neuesten Stand.';
      case UpdaterStatus.downloading:
        return 'Update wird heruntergeladen...';
      case UpdaterStatus.readyToInstall:
        return 'Update bereit zur Installation!';
      case UpdaterStatus.error:
        return 'Fehler beim Update';
      default:
        return 'Update';
    }
  }
}
