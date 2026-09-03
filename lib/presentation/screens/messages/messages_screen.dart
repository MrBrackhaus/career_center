import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/database/app_database.dart';
import '../../providers/database_provider.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  int? _selectedApplicationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postfach')),
      body: Row(
        children: [
          // Linke Seite: Liste der Bewerbungen mit E-Mails
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.withOpacity(0.2))),
              ),
              child: _buildApplicationList(),
            ),
          ),
          
          // Rechte Seite: E-Mail-Verlauf und Composer
          Expanded(
            flex: 2,
            child: _selectedApplicationId == null
                ? const Center(child: Text('Wähle eine Konversation aus', style: TextStyle(color: Colors.grey)))
                : _buildChatView(_selectedApplicationId!),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationList() {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<List<Application>>(
      // Wir laden alle Bewerbungen, die Mails haben
      future: db.applicationsDao.getAllApplications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        return FutureBuilder<List<Email>>(
          future: db.emailsDao.getAllEmails(),
          builder: (context, emailSnapshot) {
            if (!emailSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final allApps = snapshot.data!;
            final allEmails = emailSnapshot.data!;
            
            // Filtern: Nur Apps, die Mails haben
            final appsWithEmails = allApps.where((app) {
              return allEmails.any((e) => e.applicationId == app.id);
            }).toList();
            
            if (appsWithEmails.isEmpty) {
              return const Center(child: Text('Noch keine E-Mails vorhanden.'));
            }

            return ListView.builder(
              itemCount: appsWithEmails.length,
              itemBuilder: (context, index) {
                final app = appsWithEmails[index];
                final isSelected = _selectedApplicationId == app.id;
                
                return ListTile(
                  title: Text(app.company, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(app.position),
                  selected: isSelected,
                  selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
                  onTap: () {
                    setState(() => _selectedApplicationId = app.id);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatView(int appId) {
    final db = ref.watch(databaseProvider);
    return FutureBuilder<List<Email>>(
      future: db.emailsDao.getEmailsForApplication(appId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final emails = snapshot.data!;
        emails.sort((a, b) => a.receivedAt.compareTo(b.receivedAt)); // Älteste zuerst

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: emails.length,
                itemBuilder: (context, index) {
                  final email = emails[index];
                  // Sehr einfache Heuristik: Wenn 'sender' mit "An:" anfängt, ist es von uns gesendet.
                  final isSentByUs = email.sender.startsWith('An:') || email.sender.startsWith('Gesendet');

                  return Align(
                    alignment: isSentByUs ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.45,
                      ),
                      decoration: BoxDecoration(
                        color: isSentByUs 
                            ? Theme.of(context).colorScheme.primaryContainer 
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12).copyWith(
                          bottomRight: isSentByUs ? const Radius.circular(0) : const Radius.circular(12),
                          bottomLeft: !isSentByUs ? const Radius.circular(0) : const Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email.subject,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(email.bodySnippet),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat('dd.MM.yyyy HH:mm').format(email.receivedAt),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
