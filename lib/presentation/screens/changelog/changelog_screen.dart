import 'package:flutter/material.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changelog & Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Version 0.8.1',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Release Notes - 18. September 2026',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSection('🚀 Design & Editor Updates', [
            'Die Seitenränder (Slider) gelten nun strikt für das gesamte Dokument, inklusive der Briefköpfe im Anschreiben. Keine in den Rand gedruckten Balken mehr!',
            'Der Briefkopf des "Modern" Designs im Anschreiben wurde radikal überarbeitet: Er ist nun eine elegante, dezente Karte mit vertikaler Akzentlinie statt einem riesigen blauen Block.',
            'Typografie- und Darstellungsfehler (wie kaputte Bullet-Points) im klassischen Design wurden behoben.',
            'Die hartcodierten Abstände im Monogram-Lebenslauf wurden entfernt, sodass das Monogram-Logo nun das allgemeine Seitenraster respektiert.',
            'Im Lebenslauf (Monogram-Design) werden Fähigkeiten, Sprachen und eigene Abschnitte nun wieder zuverlässig gerendert.',
            'Der "Eigene Abschnitt" ist nun wieder im Editor verstell- und umbenennbar dank des neuen Dialogs.',
            'Ein Fehler beim Speichern (endlos drehendes Lade-Symbol) im Freien Editor wurde durch ein Fail-Safe behoben.',
          ]),
          _buildSection('🛠️ System & Stabilität', [
            'Das Export/Backup-System sichert und überschreibt nun zuverlässig die korrekte career_center.sqlite Datenbank anstatt alte Relikte.',
            'Auf Windows schließt die App nun vor dem Einspielen eines Backups sicher die Datenbankverbindung, um fatale Dateisperren (File-Locks) zu verhindern.',
            'Ein Absturz der App beim Start auf Windows-Geräten (hervorgerufen durch das Fehlen der SQLCipher-Bibliothek) wird nun sicher abgefangen.',
          ]),
          const Divider(height: 48),
          const Text(
            'Version 0.8.0',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Release Notes - 18. September 2026',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSection('🌟 Major Features', [
            'Globaler Text-Color-Picker: Neue Farbpalette im Editor, um die Textfarbe für alle Lebenslauf- und Anschreiben-Designs global anzupassen.',
            'Sprachen-Expansion: Vollständige Übersetzung der App in 100 Sprachen, inklusive Klingonisch, Esperanto und Sindarin.',
            'Mock Interviews: Neues interaktives KI-Training (ai_interview_service) für die Vorbereitung auf anstehende Bewerbungsgespräche.',
            'ICS Kalender Export: Bewerbungs- und Interview-Termine können nun als .ics für Outlook und Google Calendar exportiert werden.',
            'Magic Clipboard: Automatisches Erkennen und Einfügen relevanter Bewerbungsdaten aus der Zwischenablage.',
            'KI E-Mail Ausleser: Integration von LLMs zur automatischen Auswertung und Kategorisierung von HR-Antworten (ai_email_extractor_service).',
          ]),
          _buildSection('⚡ Editor Overhaul & Verbesserungen', [
            'CV Editor Overhaul: Der Editor wurde komplett modernisiert. Keine Dummy-Daten mehr! Die linke Seitenleiste lädt nun echte Datenbankeinträge, rechts rendert das Echtzeit-PDF.',
            'Native Formulare: "Berufserfahrung" und "Ausbildung" nutzen nun native DatePicker und Eingabe-Validierung vor dem Speichern.',
            'Eigene Abschnitte bearbeiten: Hinzugefügte Abschnitte können nun über ein Stift-Icon direkt editiert statt nur gelöscht werden.',
            'Intelligente DIN 5008 Elemente: Kopf- und Fußzeilen-Optionen verschwinden nun intelligent, wenn der Lebenslauf bearbeitet wird, und sind nur im Anschreiben aktiv.',
            'Test Framework: Über 50 neue Unit, Widget- und Integration-Tests wurden hinzugefügt (abgesichert durch GitHub Actions).',
          ]),
          const Divider(height: 48),
          const Text(
            'Version 0.7.2 Alpha',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Release Notes - 14. September 2026',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSection('🚀 Neue Features & Verbesserungen', [
            'Auto-Updater: Die App sucht nun automatisch über GitHub (MrBrackhaus/career_center) nach neuen Versionen. Updates können über ein neues Status-Banner bequem eingesehen und installiert werden.',
            'Unterschriften-Funktion (Feature Comeback): Die vermisste Funktion ist zurück! Zeichne deine persönliche Unterschrift in den Einstellungen auf dem digitalen Zeichenbrett und stempel sie im Anschreiben-Editor als echtes Bild unter dein Dokument.',
            'Profilbilder im Lebenslauf: Das im Editor ausgewählte Profilbild wird nun endlich beim Export in den PDF-Lebenslauf (Classic & Modern Design) gerendert (vorher war dies nur ein unfertiger Platzhalter).',
            'Intelligente Fehlerberichte: Der Feedback-Dialog ("Bug melden") sendet nun bei jedem Bugreport vollautomatisch die exakte App- und Build-Version an Discord mit, um Support und Debugging zu erleichtern.',
          ]),
          _buildSection('🏗️ Architektur-Upgrade', [
            'Clean Architecture: Die gesamte Code-Basis wurde nach den Prinzipien der "Clean Architecture" refaktorisiert (Trennung von UI, Domain- und Data-Layer).',
            'Neue Repositories: Komplette Entkopplung der Datenbank. Einstellungen und E-Mails verwenden nun sichere Domain-Entities (SettingEntity, EmailEntity) statt direkter Datenbank-Modelle.',
            'State-Management: Umstellung und Optimierung der Riverpod-Provider-Kette. Unnötige UI-Rebuilds wurden eliminiert.',
            'Code-Gesundheit: Eine Code-KI hat in einem gewaltigen Audit über 100 Warnungen, Null-Safety- und Typ-Fehler (Drift-Mappers) in über 18 Dateien behoben. Der Code kompiliert nun fehlerfrei und stabil.',
            'Entschlackung: Über 20 alte, ungenutzte Pakete und Abhängigkeiten wurden restlos entfernt. Die App startet nun schneller und ist schlanker.',
          ]),
          _buildSection('🛠️ Bugfixes', [
            'App-Crash bei Datenbank-Migration: Ein schwerer Crash-Fehler durch fehlerhafte SQLite-Migration (doppelte Spalten, z.B. is_sent_by_me) beim App-Start wurde behoben.',
            'Editor-UI Klammer-Glitches: Zahlreiche Layout-Fehler im Editor und Dashboard, die durch fehlerhafte Widget-Bäume entstanden waren, wurden repariert.',
          ]),
          const Divider(height: 48),
          const Text(
            'Version 0.7.1 Alpha',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Release Notes - 7. September 2026',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildSection('🚀 Neue Features & Verbesserungen', [
            'KI-Workspace: Der leere KI-Workspace Tab wurde durch einen funktionierenden, lokalen LLM-Chat ersetzt. Nutze ihn, um dich auf Interviews vorzubereiten oder Fragen zu Bewerbungen zu stellen.',
            'Zentraler "Freier Editor": Alle Dokumententypen (Vorlagen, Anschreiben, freie Texte) nutzen nun durchgehend denselben vollausgestatteten Editor inkl. ATS-Features und Rechtschreibprüfung. Der alte, abgespeckte Vorlagen-Editor wurde komplett entfernt.',
          ]),
          _buildSection('🛠️ Bugfixes', [
            'HTML-Extraktion: Ein Fehler wurde behoben, bei dem die Job-Beschreibung beim Import über eine URL (z.B. Arbeitsagentur) als roher HTML-Code im Textfeld landete. Es gibt nun einen robusten Regex-Fallback, der garantiert, dass nur noch reiner Text übernommen wird.',
          ]),
          const Divider(height: 48),
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
            '🌍 Lokalisierung: Vollständige Zwei-Sprachen-Unterstützung (Deutsch & Englisch) eingebaut.',
          ]),
          _buildSection('🛠 Verbesserungen & UI-Upgrades', [
            '📑 Tab-Layout für Bewerbungen: Bessere Übersicht durch Reiter (Basisdaten, E-Mails, Dokumente, Notizen).',
            '📖 DualView-Funktion: Beim Eintragen der Basisdaten könnt ihr jetzt per Split-View parallel das PDF der Stellenausschreibung betrachten.',
            '📝 Rich-Text Editor: Vorlagen (Anschreiben, Textbausteine) können jetzt dank Quill mit Formatierungen versehen werden.',
            '✉️ E-Mail (IMAP) Integration: Grundlagen für automatische Zuweisung von Firmenantworten an die jeweilige Bewerbung gelegt.',
            '🎨 Pipette / Color Picker: App-Akzentfarbe lässt sich nun über die Einstellungen mit der Pipette präzise anpassen.',
            '🤖 MCP Funktionen: Implementierung des Model Context Protocol (MCP) für erweiterten KI-Zugriff und Daten-Extraktion.',
          ]),
          _buildSection('🐛 Bugfixes', [
            'Code-Optimierungen (Entfernung alter "withOpacity"-Aufrufe, Wechsel auf "withValues").',
            'Behebung des kritischen Layout-Fehlers im Template-Editor (fehlende Klammern beim UI-Aufbau).',
            'Drift-Datenbank-Migrationspfade auf Version 6 aktualisiert.',
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
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
