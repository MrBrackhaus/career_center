import 'package:flutter/material.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changelog & Info'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Version 0.7.0 Alpha',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Release Notes - 6. September 2026',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSection('🚀 Der neue Pro-Editor (A4-Canvas)', [
            'Editor 2.0: Der komplette Texteditor wurde neu aufgebaut. Dokumente werden nun visuell als echtes A4-Blatt (Google Docs Style) dargestellt.',
            'Visuelles Lineal (Ruler): Ein maßstabsgetreues Lineal am oberen und linken Rand hilft bei der perfekten DIN-5008-Formatierung (z.B. 45mm Rand oben).',
            'Pro-Werkzeugleiste: Exakte Schriftgrößen (8pt, 10pt, 12pt) und professionelle Schriftarten (Roboto, Merriweather) können nun präzise gesetzt werden.',
            'Bausteine & Design-Menü: Eine neue linke Seitenleiste erlaubt das Einfügen von Textbausteinen per Klick und die Live-Anpassung des Seiten-Layouts.',
          ]),
          _buildSection('🤖 KI & ATS-Integration', [
            'Live Job-Fit (ATS): Die neue rechte Seitenleiste prüft das Dokument in Echtzeit auf wichtige Keywords aus der Stellenanzeige (inkl. fehlenden und gefundenen Keywords).',
            'Intelligente Offline-Rechtschreibprüfung v2: Erkennt nun deutsche Beugungen (Suffix-Stripping) und Komposita. Fehler werden direkt im Editor markiert.',
            'Offline-Korrekturmenü: Klick auf einen Fehler zeigt blitzschnelle, speichereffiziente Korrekturvorschläge (sortiert nach Häufigkeit).',
            'Mehrsprachige Rechtschreibung: 12 neue, riesige Wörterbücher (Französisch, Spanisch, Türkisch, etc.) stehen in den Einstellungen komplett offline zur Verfügung.',
            'KI-Lektorat: Der neue lila "KI Korrektur"-Button in der Toolbar nutzt lokales Llama 3 (Ollama), um Anschreiben perfekt umzuformulieren und Grammatikfehler vollautomatisch zu tilgen.',
          ]),
          _buildSection('🔌 Model Context Protocol (MCP)', [
            'Die App fungiert nun als nativer MCP-Server! Externe KI-Agenten können via JSON-RPC über Port 47392 direkt mit der Datenbank kommunizieren.',
            'Neue Tool-Routen: "get_applications" liest den Bewerbungsstand aus, "update_cover_letter" injiziert fertige Anschreiben direkt in den Editor.',
          ]),
          _buildSection('🛠️ Verbesserungen & Bugfixes', [
            'Fokus-Bug behoben: Der Cursor springt beim schnellen Tippen nicht mehr weg. Analysen laufen flüssig im Hintergrund (Debouncing).',
            'Sicheres Einfügen: Beim Einfügen von Texten (Strg+V) aus dem Browser werden externe Web-Formatierungen jetzt automatisch entfernt.',
            'Englisch-Fallback in der Rechtschreibung deaktiviert, um treffsicherere deutsche Korrekturvorschläge zu garantieren.',
          ]),
          const Divider(height: 48),
          const Text(
            'Version 0.6.0 Alpha',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Release Notes - 3. September 2026',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSection('🚀 Neue Features', [
            '📊 Neues Statistik-Dashboard: Interaktives Dashboard mit Erfolgsquoten, Ø Pendelzeit, Funnel-Chart und Top-Absagegründen.',
            '🤖 KI Prompt Generator: Generiert maßgeschneiderte ChatGPT-Prompts für Anschreiben basierend auf Position, Skills und Tonfall.',
            '📑 Jobcenter-Nachweis (PDF-Export): Generiert per Klick tabellarische Nachweise eurer Eigenbemühungen als PDF.',
            '📅 Wochenbericht: Vergleicht Bewerbungsleistungen der aktuellen Woche mit der Vorwoche.',
            '🌐 Browser-Erweiterung & lokaler Server: Importiert Stellenanzeigen per Klick (über Port 47392) aus Chrome/Edge.',
            '🌍 Lokalisierung: Vollständige Zwei-Sprachen-Unterstützung (Deutsch & Englisch) eingebaut.'
          ]),
          _buildSection('🛠 Verbesserungen & UI-Upgrades', [
            '📑 Tab-Layout für Bewerbungen: Bessere Übersicht durch Reiter (Basisdaten, E-Mails, Dokumente, Notizen).',
            '📖 DualView-Funktion: Beim Eintragen der Basisdaten könnt ihr jetzt per Split-View parallel das PDF der Stellenausschreibung betrachten.',
            '📝 Rich-Text Editor: Vorlagen (Anschreiben, Textbausteine) können jetzt dank Quill mit Formatierungen versehen werden.',
            '✉️ E-Mail (IMAP) Integration: Grundlagen für automatische Zuweisung von Firmenantworten an die jeweilige Bewerbung gelegt.',
            '🎨 Pipette / Color Picker: App-Akzentfarbe lässt sich nun über die Einstellungen mit der Pipette präzise anpassen.',
            '🤖 MCP Funktionen: Implementierung des Model Context Protocol (MCP) für erweiterten KI-Zugriff und Daten-Extraktion.'
          ]),
          _buildSection('🐛 Bugfixes', [
            'Code-Optimierungen (Entfernung alter "withOpacity"-Aufrufe, Wechsel auf "withValues").',
            'Behebung des kritischen Layout-Fehlers im Template-Editor (fehlende Klammern beim UI-Aufbau).',
            'Drift-Datenbank-Migrationspfade auf Version 6 aktualisiert.'
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 14, height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
