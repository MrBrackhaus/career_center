# Redesign & Phase 2 Implementierungsplan

Das Ziel ist es, die App hochgradig nutzerfreundlich zu machen, das Layout an die Web-Dashboard-Screenshots anzupassen und die Phase 2 abzuschließen.

## User Review Required
> [!IMPORTANT]
> - **Rich Text Editor**: Das Paket `flutter_quill` wird für Vorlagen/Textbausteine installiert (Word-ähnliche Formatierung).
> - **Datenbank-Update**: Der Drift-Tabelle `Applications` wird eine Spalte `customFields` (Text) hinzugefügt, um die dynamischen Berufs-Daten als JSON zu speichern. Dazu wird ein `build_runner` Lauf nötig.

## Proposed Changes

### 1. Navigation & Hauptlayout (`main_screen.dart`)
- **Top-Navigation**: Die BottomNavigationBar wird durch eine stylische obere Leiste (ähnlich einer Web-App) ersetzt.
- **Tabs**: "Profi-Übersicht", "Wochenbericht", "Vorlagen", "Jobcenter-Nachweis", "Statistiken", "Einstellungen".

### 2. Dynamische Berufs-Profile & Spalten (Nutzerfreundlichkeit Prio 1)
- **Berufs-Vorlagen (Presets)**: In den Einstellungen gibt es einen Bereich "Dein Berufsfeld". Wählt der Nutzer z.B. "Handwerk", werden automatisch Spalten wie "Führerscheine", "Maschinen" angelegt. Bei "IT" sind es "Tech-Stack", "Remote-Anteil".
- **Datenbank (`app_database.dart`)**:
  - `[MODIFY]` `Applications` Tabelle: Neue Spalte `TextColumn get customFields => text().nullable()();`
- **Formular (`application_form_screen.dart`)**:
  - Generiert dynamisch zusätzliche Eingabefelder basierend auf den aktiven Spalten.
  - **Magic Auto-Fill (Web Scraping)**: Ein neues Eingabefeld ganz oben für eine Job-URL. Ein Button lädt im Hintergrund die Metadaten (Titel, OpenGraph-Tags) der Website über das Paket `html` oder `metadata_fetch` herunter und versucht, Felder wie "Position" und "Firma" automatisch vorauszufüllen.

### 3. Profi-Übersicht (Dashboard / `applications_screen.dart`)
- **Daten-Tabelle**: Das Listen-Layout wird zu einer scrollbaren, tabellarischen Ansicht umgebaut, die Firma, Position, Datum, Status UND die dynamischen Berufs-Spalten nebeneinander anzeigt. (Analog zum Screenshot).

### 4. Motivations-Wochenbericht
- `[NEW]` `lib/presentation/screens/reports/weekly_report_screen.dart`
  - Ein Gamification-Dashboard.
  - **Wochen-Ziel**: Progress-Bar (z.B. "3 von 5 Bewerbungen geschafft").
  - **Motivation**: Positive Texte ("Starke Leistung!", "Weiter so!").
  - **Vergleich**: Vergleich zur Vorwoche.
  - Anzeige ausstehender Antworten/Interviews der aktuellen Woche.

### 5. Vorlagen, Texteditor & Prompt Generator
- `[NEW]` `lib/presentation/screens/templates/templates_screen.dart`
  - Übersicht der eigenen Vorlagen.
  - **Prompt Generator UI**: Formular (Position, Firma, 3 Stärken) generiert einen fertigen Prompt für ChatGPT/Claude ("Erstelle ein Anschreiben für...").
- `[NEW]` `lib/presentation/screens/templates/template_editor_screen.dart`
  - Integration von `flutter_quill`. Speichert den formatierten Text inkl. möglicher Bilder als Delta-JSON im bestehenden `Templates`-Feld `content`.

### 6. Statistiken (`dashboard_screen.dart` wird umbenannt/verschoben)
- Anpassung an Screenshot 4: BarChart für den monatlichen Verlauf und Top-Absagegründe-Liste unter den KPI-Karten.

## Verification Plan
1. `flutter pub get` & `flutter pub run build_runner build` (für das DB-Update).
2. App starten und Berufs-Profil auf "Handwerk" setzen.
3. Testen, ob das Formular dynamisch das Feld "Führerscheine" anzeigt.
4. Prüfen, ob der Texteditor korrekt lädt und formatiert.
