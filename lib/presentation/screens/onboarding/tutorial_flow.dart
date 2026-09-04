import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../../data/database/app_database.dart';

class TutorialFlow extends StatefulWidget {
  const TutorialFlow({Key? key}) : super(key: key);

  @override
  State<TutorialFlow> createState() => _TutorialFlowState();
}

class _TutorialFlowState extends State<TutorialFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.work_outline,
      'title': 'Willkommen beim JobTracker!',
      'text': 'Dein moderner, sicherer Bewerbungsmanager. Behalte den Überblick über alle deine Bewerbungen. Alle Daten bleiben zu 100% lokal auf deinem Gerät - maximale Privatsphäre garantiert.',
      'color': Colors.blue,
    },
    {
      'icon': Icons.view_kanban_outlined,
      'title': 'Die Candidate Journey',
      'text': 'Organisiere deine Bewerbungen im intuitiven Kanban-Board. Verschiebe Karten per Drag & Drop zwischen den Phasen und verfolge deinen Erfolg im interaktiven Dashboard-Trichter.',
      'color': Colors.purple,
    },
    {
      'icon': Icons.auto_awesome,
      'title': 'Smarte KI & Chrome Extension',
      'text': 'Spare extrem viel Zeit! Der JobTracker nutzt lokale KI, um PDFs zu scannen, Jobangebote auszulesen und dir direkt das Wichtigste zusammenzufassen - ganz ohne Cloud-Zwang.',
      'color': Colors.orange,
    },
    {
      'icon': Icons.mark_email_read_outlined,
      'title': 'Intelligenter E-Mail Sync',
      'text': 'Verbinde dein IMAP/SMTP-Postfach: Sende Bewerbungen direkt aus der App und lass Antworten (wie Einladungen oder Absagen) automatisch erkennen und einsortieren!',
      'color': Colors.redAccent,
    },
    {
      'icon': Icons.rocket_launch_outlined,
      'title': 'Startklar!',
      'text': 'Bist du bereit? Lege jetzt deine erste Bewerbung an oder importiere Jobs mit der Chrome-Erweiterung.',
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 600,
        height: 500,
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
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: (page['color'] as Color).withOpacity(0.1),
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
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page['text'] as String,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
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
                          final db = ref.read(databaseProvider);
                          await db.settingsDao.insertOrUpdateSetting(
                            const Setting(key: 'has_seen_tutorial', value: 'true'),
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
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showTutorialIfNeeded(BuildContext context, WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final setting = await db.settingsDao.getSettingByKey('has_seen_tutorial');
  if (setting?.value != 'true' && context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TutorialFlow(),
    );
  }
}
