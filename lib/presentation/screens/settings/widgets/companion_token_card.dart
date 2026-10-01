import 'package:career_center/core/utils/error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/companion_server_service.dart';

/// Zeigt den API-Token des lokalen Companion-Servers an, damit er in die
/// Browser-Erweiterung eingefügt werden kann (Kopplung), und erlaubt das
/// Neu-Erzeugen des Tokens.
class CompanionTokenCard extends StatefulWidget {
  const CompanionTokenCard({super.key, this.service});

  /// Optionaler Service (für Tests); standardmäßig das Singleton.
  final CompanionServerService? service;

  @override
  State<CompanionTokenCard> createState() => _CompanionTokenCardState();
}

class _CompanionTokenCardState extends State<CompanionTokenCard> {
  late final CompanionServerService _service =
      widget.service ?? CompanionServerService();

  String? _token;
  String? _error;
  bool _obscured = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = await _service.loadApiToken();
      if (mounted) {
        setState(() {
          _token = token;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Token konnte nicht geladen werden: $e');
      }
    }
  }

  Future<void> _copy() async {
    final token = _token;
    if (token == null) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: token));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token in die Zwischenablage kopiert.')),
      );
    }
  }

  Future<void> _regenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Token neu erzeugen?'),
        content: const Text(
          'Der bisherige Token wird sofort ungültig. Die Browser-Erweiterung '
          'und andere verbundene Programme funktionieren erst wieder, wenn du '
          'den neuen Token dort einträgst.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Neu erzeugen'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    setState(() => _busy = true);
    try {
      final token = await _service.regenerateApiToken();
      if (mounted) {
        setState(() {
          _token = token;
          _error = null;
          _obscured = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Neuer Token erzeugt. Bitte in der Browser-Erweiterung eintragen.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: ${friendlyError(e)}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final token = _token;

    Widget tokenView;
    if (_error != null) {
      tokenView = Text(_error!, style: TextStyle(color: theme.colorScheme.error));
    } else if (token == null) {
      tokenView = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else {
      tokenView = SelectableText(
        _obscured ? '•' * 24 : token,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.extension, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Browser-Erweiterung koppeln', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Kopiere diesen Token und füge ihn im Popup der Browser-Erweiterung '
              '„Bewerbungszentrale Companion“ in das Feld „App-Token“ ein. '
              'Gib den Token nicht weiter – er erlaubt Zugriff auf deine Profildaten.',
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(child: tokenView),
                  IconButton(
                    tooltip: _obscured ? 'Token anzeigen' : 'Token verbergen',
                    icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
                    onPressed: token == null ? null : () => setState(() => _obscured = !_obscured),
                  ),
                  IconButton(
                    tooltip: 'Token kopieren',
                    icon: const Icon(Icons.copy),
                    onPressed: token == null ? null : _copy,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: (_busy || token == null) ? null : _regenerate,
                icon: _busy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: const Text('Token neu erzeugen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
