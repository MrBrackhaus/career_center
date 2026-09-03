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
