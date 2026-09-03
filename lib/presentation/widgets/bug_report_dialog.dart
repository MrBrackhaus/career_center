import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/secrets.dart';

class BugReportDialog extends StatefulWidget {
  const BugReportDialog({super.key});

  @override
  State<BugReportDialog> createState() => _BugReportDialogState();
}

class _BugReportDialogState extends State<BugReportDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendReport() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte fülle Titel und Beschreibung aus.')),
      );
      return;
    }

    if (Secrets.discordWebhookUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bug-Tracker ist noch nicht konfiguriert (Webhook URL fehlt).')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(Secrets.discordWebhookUrl));
      request.headers.set('Content-Type', 'application/json');

      final payload = jsonEncode({
        "embeds": [
          {
            "title": "🐛 Neuer Bug-Report: $title",
            "description": desc,
            "color": 15158332, // Red
            "footer": {
              "text": "Gesendet aus der Bewerbungszentrale App"
            },
            "timestamp": DateTime.now().toIso8601String()
          }
        ]
      });

      request.add(utf8.encode(payload));
      final response = await request.close();
      client.close();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bug erfolgreich gemeldet! Vielen Dank!')),
          );
        }
      } else {
        throw Exception('HTTP Status: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Senden: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.bug_report, color: Colors.red),
          SizedBox(width: 8),
          Text('Bug melden'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ist dir ein Fehler aufgefallen? Beschreibe ihn hier, damit er behoben werden kann.'),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Kurzer Titel (z.B. PDF stürzt ab)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Was genau ist passiert?',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton.icon(
          onPressed: _isSending ? null : _sendReport,
          icon: _isSending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
          label: const Text('Senden'),
        ),
      ],
    );
  }
}
