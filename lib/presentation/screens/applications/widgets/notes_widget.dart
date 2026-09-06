import '../../../../l10n/app_localizations.dart';
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
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider(widget.applicationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Neue Notiz...', border: OutlineInputBorder()),
                maxLines: null,
                onSubmitted: (_) => _addNote(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _addNote,
              color: Theme.of(context).colorScheme.primary,
            )
          ],
        ),
        const SizedBox(height: 16),
        notesAsync.when(
          data: (notes) {
            if (notes.isEmpty) return const Text('Noch keine Notizen.', style: TextStyle(color: Colors.grey));
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder: (context, i) {
                final note = notes[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(note.content),
                    subtitle: Text('${note.createdAt?.day}.${note.createdAt?.month}.${note.createdAt?.year} ${note.createdAt?.hour}:${note.createdAt?.minute.toString().padLeft(2, '0')}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      onPressed: () => ref.read(notesNotifierProvider(widget.applicationId).notifier).deleteNote(note.id),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Fehler: $e'),
        ),
      ],
    );
  }

  void _addNote() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(notesNotifierProvider(widget.applicationId).notifier).addNote(_controller.text.trim());
    _controller.clear();
  }
}

