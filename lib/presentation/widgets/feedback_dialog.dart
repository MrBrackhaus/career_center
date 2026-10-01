import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/secrets.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

/// Maximale Länge des Titels (Discord-Embed-Titel: 256 Zeichen inkl. Präfix,
/// zu lange Titel werden beim Senden gekürzt).
const int _maxTitleLength = 256;

/// Maximale Länge der Beschreibung (Discord-Embed-Beschreibung: 4096 Zeichen).
const int _maxDescriptionLength = 4000;

const Duration _connectionTimeout = Duration(seconds: 10);
const Duration _requestTimeout = Duration(seconds: 20);

class _FeedbackDialogState extends State<FeedbackDialog> {
  HttpClient? _client;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _feedbackType = 'Bug'; // 'Bug', 'Idee', 'Feedback'
  bool _isSending = false;

  @override
  void dispose() {
    _client?.close(force: true);
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _sendReport() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte fülle Titel und Beschreibung aus.'),
        ),
      );
      return;
    }

    if (Secrets.discordWebhookUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tracker ist noch nicht konfiguriert (Webhook URL fehlt).',
          ),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    final client = HttpClient()..connectionTimeout = _connectionTimeout;
    _client = client;
    try {
      final request = await client
          .postUrl(Uri.parse(Secrets.discordWebhookUrl))
          .timeout(_requestTimeout);
      request.headers.set('Content-Type', 'application/json');

      int color = 15158332; // Red (Bug)
      String prefix = "🐛 Neuer Bug-Report";

      if (_feedbackType == 'Idee') {
        color = 3066993; // Green
        prefix = "💡 Neue Idee/Vorschlag";
      } else if (_feedbackType == 'Feedback') {
        color = 3447003; // Blue
        prefix = "💬 Neues Feedback";
      }

      String versionStr = "Unbekannt";
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        versionStr = "${packageInfo.version}+${packageInfo.buildNumber}";
      } catch (e) {
        // ignore
      }

      final payload = jsonEncode({
        "embeds": [
          {
            // Discord begrenzt Embed-Titel auf 256 Zeichen.
            "title": _truncate("$prefix: $title", 256),
            "description": desc,
            "color": color,
            "footer": {"text": "App Version: $versionStr"},
            "timestamp": DateTime.now().toIso8601String(),
          },
        ],
      });

      request.add(utf8.encode(payload));
      final response = await request.close().timeout(_requestTimeout);
      await response.drain<void>().timeout(_requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nachricht erfolgreich gesendet! Vielen Dank!'),
            ),
          );
        }
      } else {
        throw Exception('HTTP Status: ${response.statusCode}');
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Zeitüberschreitung beim Senden. Bitte prüfe deine Internetverbindung.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fehler beim Senden: $e')));
      }
    } finally {
      client.close(force: true);
      if (identical(_client, client)) _client = null;
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  static String _truncate(String text, int max) =>
      text.length <= max ? text : '${text.substring(0, max - 1)}…';

  void _cancel() {
    // Laufende Übertragung abbrechen und Dialog schließen.
    _client?.close(force: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.rate_review, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text('Feedback & Bugs'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hast du einen Fehler gefunden oder eine tolle Idee für die App? Lass es uns wissen!',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _feedbackType,
              decoration: const InputDecoration(
                labelText: 'Art der Meldung',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Bug', child: Text('🐛 Fehler / Bug')),
                DropdownMenuItem(
                  value: 'Idee',
                  child: Text('💡 Idee / Vorschlag'),
                ),
                DropdownMenuItem(
                  value: 'Feedback',
                  child: Text('💬 Allgemeines Feedback'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _feedbackType = val);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              maxLength: _maxTitleLength,
              decoration: const InputDecoration(
                labelText: 'Kurzer Titel (z.B. PDF stürzt ab)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 5,
              maxLength: _maxDescriptionLength,
              decoration: const InputDecoration(
                labelText: 'Was genau ist passiert bzw. was ist deine Idee?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hinweis: Deine Meldung (Art, Titel, Beschreibung und App-Version) '
              'wird an den Discord-Server des Entwicklers gesendet. Bitte gib '
              'keine persönlichen Daten ein.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Abbrechen'),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _sendReport,
          icon: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: const Text('Senden'),
        ),
      ],
    );
  }
}
