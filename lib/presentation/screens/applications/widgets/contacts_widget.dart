import '../../../../l10n/app_localizations.dart';

/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/contacts_provider.dart';

class ContactsWidget extends ConsumerWidget {
  final int applicationId;
  const ContactsWidget({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider(applicationId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kontakte', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Hinzufügen'),
              onPressed: () => _showContactDialog(context, ref, applicationId),
            ),
          ],
        ),
        const SizedBox(height: 8),
        contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return const Text(
                'Keine Kontakte.',
                style: TextStyle(color: Colors.grey),
              );
            }
            return Column(
              children: contacts.map((c) {
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(c.name ?? 'Unbekannt'),
                    subtitle: Text(
                      '${c.role ?? ''}\n${c.email ?? ''} | ${c.phone ?? ''}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref
                          .read(
                            contactsNotifierProvider(applicationId).notifier,
                          )
                          .deleteContact(c.id),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Fehler: $e'),
        ),
      ],
    );
  }

  Future<void> _showContactDialog(
      BuildContext context, WidgetRef ref, int appId) async {
    // Der Dialog besitzt seine Controller selbst und gibt sie erst nach der
    // Ausblend-Animation frei (vorher: dispose in .then() -> Absturz beim
    // Speichern, weil die Textfelder noch gezeichnet wurden).
    final result = await showDialog<_NewContact>(
      context: context,
      builder: (_) => const _ContactDialog(),
    );
    if (result == null) return;
    await ref.read(contactsNotifierProvider(appId).notifier).addContact(
          result.name,
          result.email,
          result.phone,
          result.role,
        );
  }
}

class _NewContact {
  final String name;
  final String role;
  final String email;
  final String phone;
  const _NewContact(this.name, this.role, this.email, this.phone);
}

class _ContactDialog extends StatefulWidget {
  const _ContactDialog();

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Neuer Kontakt'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _roleCtrl,
              decoration: const InputDecoration(labelText: 'Rolle (z.B. HR)'),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Telefon'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            _NewContact(
              _nameCtrl.text,
              _roleCtrl.text,
              _emailCtrl.text,
              _phoneCtrl.text,
            ),
          ),
          child: Text(AppLocalizations.of(context)!.formBasicSave),
        ),
      ],
    );
  }
}
