import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_provider.dart';
import '../../../domain/entities/setting_entity.dart';

class TutorialFlow extends StatefulWidget {
  const TutorialFlow({super.key});

  @override
  State<TutorialFlow> createState() => _TutorialFlowState();
}

class _TutorialFlowState extends State<TutorialFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.work_outline,
      'title': 'Willkommen in der Bewerbungszentrale!',
      'text': 'Dein moderner, sicherer Bewerbungsmanager. Behalte den Überblick über alle deine Bewerbungen. Alle Daten bleiben zu 100% lokal auf deinem Gerät - maximale Privatsphäre garantiert.',
      'color': Colors.blue,
    },
    {
      'icon': Icons.security,
      'title': 'KI & Datenschutz (DSGVO)',
      'text': 'Wir nehmen Datenschutz ernst! Diese App nutzt standardmäßig ausschließlich lokale KI-Modelle. Es werden keine Daten ungefragt an Cloud-Anbieter gesendet.\n\nHinweis: Wenn du die App über eine Agent-Schnittstelle (MCP) fernsteuerst oder eigene Cloud-APIs konfigurierst, stimmst du der Datenverarbeitung durch diese Dienste zu.',
      'color': Colors.teal,
    },
    {
      'icon': Icons.edit_document,
      'title': 'Dokumente & Freier Editor',
      'text': 'Unter "Meine Dokumente" pflegst du Lebensläufe und Anschreiben. Importiere PDF-Originale (1:1 Übernahme) oder nutze den "Freien Editor" für pixelperfekte A4-Bewerbungsschreiben mit integrierter ATS-Prüfung.',
      'color': Colors.indigo,
    },
    {
      'icon': Icons.add_link,
      'title': 'Neue Stellenanzeigen importieren',
      'text': 'Unter "Bewerbungen" findest du das Plus-Symbol. Füge dort einfach die URL einer Stellenanzeige (z.B. von der Arbeitsagentur oder StepStone) ein. Die KI liest die Seite aus und trägt Unternehmen, Position und Ansprechpartner automatisch für dich ein!',
      'color': Colors.orange,
    },
    {
      'icon': Icons.picture_as_pdf,
      'title': 'Alte Bewerbungen übernehmen',
      'text': 'Du hast bereits bestehende Bewerbungen? Kein Problem! Lade einfach das PDF deines bisherigen Anschreibens oder der Stellenanzeige hoch. Die App scannt das Dokument und übernimmt alle Daten automatisch in dein Kanban-Board.',
      'color': Colors.deepOrange,
    },
    {
      'icon': Icons.smart_toy_outlined,
      'title': 'KI-Workspace & Auto-Anschreiben',
      'text': 'WICHTIG: Damit die KI funktioniert, musst du in den App-Einstellungen eine lokale LLM-Verbindung hinterlegen (z.B. Ollama über http://localhost:11434 oder deinen Jetson). Danach kannst du den lokalen Chat nutzen und per Knopfdruck personalisierte Anschreiben generieren lassen!',
      'color': Colors.teal,
    },
    {
      'icon': Icons.view_kanban_outlined,
      'title': 'E-Mail Sync & Kanban Board',
      'text': 'Versende Bewerbungen per E-Mail direkt aus der App. Verwalte den Status (z.B. "Interview") per Drag & Drop im Kanban-Board und werte deinen Erfolg im interaktiven Dashboard aus.',
      'color': Colors.purple,
    },
    {
      'icon': Icons.terminal,
      'title': 'Antigravity & MCP-Integration',
      'text': 'Für Profis: Die Bewerbungszentrale fungiert als nativer Model Context Protocol (MCP) Server auf Port 47392! KI-Agenten wie Antigravity können so direkt auf deine Datenbank zugreifen, massenhaft Bewerbungen anlegen oder Anschreiben injizieren.',
      'color': Colors.deepOrange,
    },
    {
      'icon': Icons.rocket_launch_outlined,
      'title': 'Startklar!',
      'text': 'Bist du bereit? Hinterlege nun in den Einstellungen deine LLM-Verbindung und leg direkt deine erste Bewerbung an!',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 550),
        child: Container(
          padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: (page['color'] as Color).withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          page['icon'] as IconData,
                          size: 80,
                          color: page['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        page['title'] as String,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page['text'] as String,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ));
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Indicators
                Row(
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                // Buttons
                Consumer(
                  builder: (context, ref, child) {
                    if (_currentPage == _pages.length - 1) {
                      return FilledButton.icon(
                        onPressed: () async {
                          await ref.read(settingsRepositoryProvider).insertOrUpdateSetting(
                            const SettingEntity(
                              key: 'has_seen_tutorial',
                              value: 'true',
                            ),
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Los gehts!'),
                      );
                    }
                    return TextButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Weiter'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}

Future<void> showTutorialIfNeeded(BuildContext context, WidgetRef ref) async {
  final dao = ref.read(databaseProvider).settingsDao;
  final setting = await dao.getSettingByKey('has_seen_tutorial');
  if (setting?.value != 'true') {
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const TutorialFlow(),
      );
    }
  }
}
