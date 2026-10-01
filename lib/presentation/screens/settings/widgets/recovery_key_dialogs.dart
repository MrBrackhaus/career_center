import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fragt nach, ob der Wiederherstellungsschlüssel angezeigt werden soll, und
/// erklärt, wofür er benötigt wird. Gibt `true` zurück, wenn bestätigt.
Future<bool> confirmShowRecoveryKey(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Wiederherstellungsschlüssel anzeigen?'),
      content: const Text(
        'Deine Datenbank und alle Backups sind mit diesem Schlüssel verschlüsselt.\n\n'
        'Du brauchst ihn, um ein Backup auf einem anderen PC oder nach einer '
        'Neuinstallation von Windows wiederherzustellen. Ohne den Schlüssel '
        'lassen sich deine Backups NICHT mehr öffnen.\n\n'
        'Bewahre ihn sicher auf (z.B. im Passwort-Manager) und gib ihn niemandem weiter – '
        'wer Schlüssel und Backup besitzt, kann deine Daten lesen.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Anzeigen')),
      ],
    ),
  );
  return confirmed == true;
}

/// Zeigt den Wiederherstellungsschlüssel [recoveryKey] mit Kopier-Button an.
Future<void> showRecoveryKeyDialog(BuildContext context, String recoveryKey) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('🔑 Wiederherstellungsschlüssel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bewahre diesen Schlüssel sicher auf. Er wird benötigt, um Backups wiederherzustellen.'),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              recoveryKey,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('Kopieren'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: recoveryKey));
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Wiederherstellungsschlüssel kopiert.')),
              );
            }
          },
        ),
        ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Schließen')),
      ],
    ),
  );
}

/// Fragt den Wiederherstellungsschlüssel eines Backups ab, das nicht mit dem
/// aktuellen Schlüssel verschlüsselt ist. Gibt `null` bei Abbruch zurück.
Future<String?> askForBackupRecoveryKey(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => const _AskRecoveryKeyDialog(),
  );
}

class _AskRecoveryKeyDialog extends StatefulWidget {
  const _AskRecoveryKeyDialog();

  @override
  State<_AskRecoveryKeyDialog> createState() => _AskRecoveryKeyDialogState();
}

class _AskRecoveryKeyDialogState extends State<_AskRecoveryKeyDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wiederherstellungsschlüssel eingeben'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dieses Backup wurde mit einem anderen Schlüssel verschlüsselt '
            '(z.B. auf einem anderen PC oder vor einer Neuinstallation).\n\n'
            'Gib den Wiederherstellungsschlüssel ein, der zu diesem Backup gehört. '
            'Er wird nach dem Import zum neuen Schlüssel dieser Installation.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Wiederherstellungsschlüssel',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.key),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
        ElevatedButton(onPressed: _submit, child: const Text('Prüfen & importieren')),
      ],
    );
  }
}
