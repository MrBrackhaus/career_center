import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/database/db_key_service.dart';
import '../../../providers/database_provider.dart';

/// Hinweis, falls beim Start eine verschlüsselte Datenbank ohne gespeicherten
/// Schlüssel gefunden und daher beiseitegelegt wurde
/// (`career_center.sqlite.locked-<timestamp>`).
class LockedDatabaseBanner extends ConsumerStatefulWidget {
  const LockedDatabaseBanner({super.key});

  /// Settings-Key, unter dem der zuletzt ausgeblendete Dateiname liegt.
  static const dismissedSettingKey = 'lockedDbNoticeDismissed';

  @override
  ConsumerState<LockedDatabaseBanner> createState() => _LockedDatabaseBannerState();
}

class _LockedDatabaseBannerState extends ConsumerState<LockedDatabaseBanner> {
  File? _lockedFile;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final locked = DbKeyService.findLockedDatabases(File(p.join(dir.path, 'career_center.sqlite')));
      if (locked.isEmpty) return;
      final dismissed = await ref
          .read(databaseProvider)
          .settingsDao
          .getSettingByKey(LockedDatabaseBanner.dismissedSettingKey);
      if (dismissed?.value == p.basename(locked.first.path)) return;
      if (mounted) setState(() => _lockedFile = locked.first);
    } catch (e) {
      debugPrint('Prüfung auf gesperrte Datenbanken fehlgeschlagen: $e');
    }
  }

  Future<void> _dismiss() async {
    final file = _lockedFile;
    if (file == null) return;
    setState(() => _lockedFile = null);
    await ref.read(databaseProvider).settingsDao.insertOrUpdateSetting(
          Setting(key: LockedDatabaseBanner.dismissedSettingKey, value: p.basename(file.path)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final file = _lockedFile;
    if (file == null) return const SizedBox.shrink();
    return MaterialBanner(
      backgroundColor: Colors.orange.withValues(alpha: 0.15),
      leading: const Icon(Icons.lock_outline, color: Colors.orange),
      content: Text(
        'Eine vorhandene Datenbank konnte nicht geöffnet werden (Schlüssel fehlte, z.B. nach einer Neuinstallation). '
        'Sie wurde NICHT gelöscht, sondern gesichert: ${p.basename(file.path)}\n'
        'Wiederherstellen über "Backup wiederherstellen" mit deinem Wiederherstellungsschlüssel.',
      ),
      actions: [
        TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Alte Datenbank gesichert'),
              content: SelectableText(
                'Beim Start war kein Verschlüsselungsschlüssel gespeichert, aber eine verschlüsselte '
                'Datenbank vorhanden. Damit nichts überschrieben wird, wurde sie umbenannt und die App '
                'mit einer leeren Datenbank gestartet.\n\n'
                'Gesicherte Datei:\n${file.path}\n\n'
                'So stellst du sie wieder her: "Export & Backup" → "Backup wiederherstellen", diese Datei '
                'auswählen und den Wiederherstellungsschlüssel eingeben, mit dem sie verschlüsselt wurde.',
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Schließen'))],
            ),
          ),
          child: const Text('Details'),
        ),
        TextButton(onPressed: _dismiss, child: const Text('Verstanden')),
      ],
    );
  }
}
