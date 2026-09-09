import '../../../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../presentation/providers/imap_provider.dart';

class EmailsTab extends ConsumerWidget {
  final int applicationId;

  const EmailsTab({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailsAsync = ref.watch(applicationEmailsProvider(applicationId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zugeordnete E-Mails',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          emailsAsync.when(
            data: (emails) {
              if (emails.isEmpty) {
                return Text(
                  'Keine zugeordneten E-Mails gefunden.\n(Stelle sicher, dass E-Mail/Firmenname übereinstimmt und drücke auf ${AppLocalizations.of(context)!.appCheckInbox} im Dashboard)',
                  style: TextStyle(color: Colors.grey),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: emails.length,
                itemBuilder: (context, index) {
                  final email = emails[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ExpansionTile(
                      title: Text(
                        email.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${email.sender} — ${email.receivedAt.day}.${email.receivedAt.month}.${email.receivedAt.year}',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SelectableText(email.bodySnippet),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text(
              'Fehler beim Laden der E-Mails: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
