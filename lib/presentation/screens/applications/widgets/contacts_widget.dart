import '../../../../l10n/app_localizations.dart';
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
            )
          ],
        ),
        const SizedBox(height: 8),
        contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) return const Text('Keine Kontakte.', style: TextStyle(color: Colors.grey));
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: contacts.length,
              itemBuilder: (context, i) {
                final c = contacts[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(c.name ?? 'Unbekannt'),
                    subtitle: Text('${c.role ?? ''}\n${c.email ?? ''} | ${c.phone ?? ''}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => ref.read(contactsNotifierProvider(applicationId).notifier).deleteContact(c.id),
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

  void _showContactDialog(BuildContext context, WidgetRef ref, int appId) {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Neuer Kontakt'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Rolle (z.B. HR)')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'E-Mail')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefon')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Abbrechen')),
          TextButton(
            onPressed: () {
              ref.read(contactsNotifierProvider(appId).notifier).addContact(nameCtrl.text, emailCtrl.text, phoneCtrl.text, roleCtrl.text);
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.formBasicSave),
          ),
        ],
      ),
    );
  }
}

