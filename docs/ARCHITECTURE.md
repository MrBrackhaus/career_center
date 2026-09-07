# Architektur der Bewerbungszentrale

Dieses Dokument beschreibt die technische Architektur, die eingesetzten Technologien und den strukturellen Aufbau der Bewerbungszentrale (Career Center).

## 1. Technologie-Stack

Die Anwendung ist als Desktop-First Flutter-App konzipiert, optimiert für Windows.

*   **Framework:** Flutter (Dart)
*   **State Management:** Riverpod (lutter_riverpod)
*   **Lokale Datenbank:** SQLite via Drift (drift, sqlite3_flutter_libs)
*   **Texteditor:** Flutter Quill (lutter_quill) für den "Freien Editor"
*   **PDF-Generierung & Parsing:** pdf (für Reports) und pdfrx / syncfusion_flutter_pdf (für den 1:1 Lebenslauf-Import)
*   **KI-Anbindung:** HTTP/REST (direkte Anbindung an lokale LLMs wie Ollama)
*   **E-Mail-Sync:** enough_mail (IMAP/SMTP)
*   **Routing:** GoRouter (go_router)

## 2. Projektstruktur

Die Struktur folgt grob einem Feature-basierten Ansatz, aufgeteilt in Core, Data und Presentation.

\\\
lib/
  ├── core/               # App-weite Utilities, Services, Theme, Router
  │   ├── mcp/            # Model Context Protocol Server (Port 47392)
  │   ├── services/       # E-Mail, KI, Dokumenten-Analyse
  │   └── utils/          # Hilfsfunktionen (PDF, Keyword Extraction)
  ├── data/               # Datenhaltung (Drift SQLite)
  │   └── database/
  │       ├── daos/       # Data Access Objects (Applications, Templates, Settings)
  │       └── app_database.dart
  ├── l10n/               # Lokalisierung (ARB-Dateien)
  ├── presentation/       # UI Layer
  │   ├── providers/      # Riverpod State Notifier & Provider
  │   ├── screens/        # Einzelne Ansichten (Kanban, Editor, Settings, etc.)
  │   └── widgets/        # Wiederverwendbare UI-Komponenten
  └── main.dart           # Einstiegspunkt
\\\

## 3. Datenmodell (Drift SQLite)

Die App verwendet eine rein lokale SQLite-Datenbank. Die wichtigsten Tabellen sind:

*   **Applications (Bewerbungen):** Speichert Metadaten (Firma, Position, Status, Daten) sowie das Anschreiben (Quill Delta JSON) und ATS-Daten.
*   **Templates (Vorlagen):** Speichert Lebensläufe, Textbausteine und Anschreiben-Vorlagen. Enthält Pfade zu Original-PDFs.
*   **Settings (Einstellungen):** Key-Value-Store für Nutzerdaten, KI-Konfiguration (LLM URL, Modell) und E-Mail-Zugangsdaten.
*   **Emails (Postfach):** Speichert den Verlauf der ein- und ausgehenden E-Mails zu den jeweiligen Bewerbungen.

## 4. Model Context Protocol (MCP) Integration

Die Bewerbungszentrale startet beim Booten automatisch einen **JSON-RPC Server auf Port 47392**.
Dies erlaubt es lokalen KI-Agenten (wie Antigravity), die App zu steuern, ohne auf die GUI angewiesen zu sein.

*   **Protokoll:** JSON-RPC 2.0 über TCP
*   **Zweck:** Automatisierung, Batch-Erstellung von Bewerbungen, Injizieren von generierten Anschreiben.
*   **Implementierung:** Zu finden unter \lib/core/mcp/\.

## 5. KI-Integration (Local First)

Um maximale Privatsphäre zu gewährleisten, nutzt die App lokale LLMs (Large Language Models) für Features wie:
*   **Auto-Anschreiben:** Generiert ein Anschreiben auf Basis von Profil + Job-Beschreibung.
*   **KI-Workspace:** Ein Chat zur Vorbereitung auf Interviews.
*   **Kommunikation:** Erfolgt über einfache HTTP POST-Requests (kompatibel mit der Ollama-API \/api/generate\ und \/api/chat\).

