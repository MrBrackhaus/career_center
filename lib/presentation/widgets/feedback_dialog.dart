import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/secrets.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({super.key});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _feedbackType = 'Bug'; // 'Bug', 'Idee', 'Feedback'
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
        const SnackBar(content: Text('Tracker ist noch nicht konfiguriert (Webhook URL fehlt).')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse(Secrets.discordWebhookUrl));
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

      final payload = jsonEncode({
        "embeds": [
          {
            "title": "$prefix: $title",
            "description": desc,
            "color": color,
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
            const SnackBar(content: Text('Nachricht erfolgreich gesendet! Vielen Dank!')),
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
            const Text('Hast du einen Fehler gefunden oder eine tolle Idee für die App? Lass es uns wissen!'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _feedbackType,
              decoration: const InputDecoration(
                labelText: 'Art der Meldung',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Bug', child: Text('🐛 Fehler / Bug')),
                DropdownMenuItem(value: 'Idee', child: Text('💡 Idee / Vorschlag')),
                DropdownMenuItem(value: 'Feedback', child: Text('💬 Allgemeines Feedback')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _feedbackType = val);
              },
            ),
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
                labelText: 'Was genau ist passiert bzw. was ist deine Idee?',
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
