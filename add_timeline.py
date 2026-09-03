path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# 1. Add Timeline Widget Method
timeline_widget = """  Widget _buildTimelineEvent(String title, String? dateStr, bool isCompleted, bool isCurrent, bool isLast, BuildContext context) {
    final color = isCompleted || isCurrent ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: isCurrent ? color : (isCompleted ? color : Colors.transparent),
                border: Border.all(color: color, width: 2),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? color : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCompleted || isCurrent ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant)),
              if (dateStr != null) Text(dateStr, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              if (isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }"""

if "_buildTimelineEvent" not in text:
    text = text.replace("  Future<void> _confirmDelete", timeline_widget + "\n\n  Future<void> _confirmDelete")


# 2. Modify _buildDossierPanel to include the timeline
old_details = """                  const SizedBox(height: 32),
                ],
              ),
            ),"""

new_details = """                  const SizedBox(height: 32),
                  const Text('BEWERBUNGS-VERLAUF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  _buildTimelineForApp(app, context),
                  const SizedBox(height: 32),
                ],
              ),
            ),"""

if "BEWERBUNGS-VERLAUF" not in text:
    text = text.replace(old_details, new_details)

# 3. Add _buildTimelineForApp
timeline_logic = """  Widget _buildTimelineForApp(Application app, BuildContext context) {
    final status = app.status.toLowerCase();
    
    final isVersendet = status == 'versendet' || status == 'interview' || status == 'zusage' || status == 'absage';
    final isInterview = status == 'interview' || status == 'zusage';
    final isDone = status == 'zusage' || status == 'absage';
    
    final appliedDateStr = app.appliedDate != null ? DateFormat('dd.MM.yyyy').format(app.appliedDate!) : null;
    final responseDateStr = app.responseDate != null ? DateFormat('dd.MM.yyyy').format(app.responseDate!) : null;
    
    return Column(
      children: [
        _buildTimelineEvent('In Vorbereitung', appliedDateStr, isVersendet, status == 'offen', false, context),
        _buildTimelineEvent('Bewerbung versendet', isVersendet ? (appliedDateStr ?? 'Erledigt') : null, isInterview, status == 'versendet', false, context),
        _buildTimelineEvent('Interview / Gespräch', isInterview ? (responseDateStr ?? 'Eingeladen') : null, isDone && status == 'zusage', status == 'interview', false, context),
        if (status == 'absage')
          _buildTimelineEvent('Abgesagt', responseDateStr ?? 'Abgeschlossen', true, true, true, context)
        else
          _buildTimelineEvent('Zusage / Angebot', status == 'zusage' ? (responseDateStr ?? 'Angenommen') : null, status == 'zusage', status == 'zusage', true, context),
      ],
    );
  }"""

if "_buildTimelineForApp" not in text:
    text = text.replace("  Widget _buildTimelineEvent", timeline_logic + "\n\n  Widget _buildTimelineEvent")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Added timeline to applications_screen.dart!")
