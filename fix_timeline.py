path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

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

if "_buildTimelineForApp(" not in text:
    text = text.replace("  Future<void> _confirmDelete", timeline_logic + "\n\n  Future<void> _confirmDelete")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Fixed!")
