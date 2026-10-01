/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:career_center/core/utils/error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/notes_provider.dart';

class NotesWidget extends ConsumerStatefulWidget {
  final int applicationId;
  const NotesWidget({super.key, required this.applicationId});

  @override
  ConsumerState<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends ConsumerState<NotesWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider(widget.applicationId));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Neue Notiz...',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                onSubmitted: (_) => _addNote(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addNote,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 16),
        notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) {
              return Text(
                'Noch keine Notizen.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              );
            }
            return Column(
              children: notes.map((note) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(note.content),
                    subtitle: Text(
                      '${note.createdAt.day}.${note.createdAt.month}.${note.createdAt.year} ${note.createdAt.hour}:${note.createdAt.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () => ref
                          .read(
                            notesNotifierProvider(widget.applicationId)
                                .notifier,
                          )
                          .deleteNote(note.id),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Fehler: ${friendlyError(e)}'),
        ),
      ],
    );
  }

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(notesNotifierProvider(widget.applicationId).notifier)
          .addNote(text);
      if (mounted) _controller.clear();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Notiz konnte nicht gespeichert werden: ${friendlyError(e)}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
