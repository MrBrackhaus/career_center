# JobTracker: Refactoring & Architektur-Roadmap

Dieses Dokument fasst alle besprochenen Architektur-Entscheidungen, Tech-Stack-Anpassungen und Feature-Pläne zusammen. Es dient als "Blaupause" für die schrittweise Umsetzung durch die Programmier-KI.

## Phase 0: Code-Qualität, Rechtliche Sicherheit (FLOSS) & Architektur-Standards

Der Code muss hochprofessionell und urheberrechtlich sicher sein (Clean Room Design, keine proprietären Verletzungen).

- [ ] **Urheberrecht & Lizenzen (Legal Compliance):**
  - Alle Dependencies auf Open-Source-Kompatibilität prüfen.
  - *Wichtig:* `syncfusion_flutter_pdfviewer` ist proprietär/kommerziell. Falls keine Community-Lizenz-Registrierung bei Syncfusion erfolgen soll, muss dieses Package durch eine 100% FLOSS Alternative (wie `pdfx`) ersetzt werden, um rechtlich unangreifbar zu sein.
  - Standardmäßige Open-Source-Lizenz-Header (z.B. GPLv3 oder MIT) in allen Quellcode-Dateien einfügen.
- [ ] **Professionelle Code-Architektur:**
  - Trennung von Geschäftslogik und UI (Clean Architecture / Feature-First). "God Objects" (wie die 1000-zeiligen Screens) strikt auflösen.
  - Einheitliches Error-Handling (z.B. mit `fpdart` oder Result-Wrappern) statt stillschweigendem "Fail".
- [ ] **Testing & CI/CD Pipeline:**
  - Grundlegende Unit-Tests für Core-Services (z.B. den `DocumentIntelligenceService`).
  - GitHub Actions Workflow einrichten (Automatisches Linting via `very_good_analysis` oder `flutter_lints`, und Build-Tests).

---

## Phase 1: Tech-Stack Bereinigung & Sicherheit (Quick Fixes)

Bevor neue Features eingebaut werden, müssen die technischen Schulden im aktuellen Stack behoben werden:

- [ ] **Dependencies aktualisieren (`pubspec.yaml`):**
  - `sqlite3_flutter_libs` von der EOL-Version auf die aktuelle stabile Version anheben.
  - Die Version von `encrypt` pinnen (statt `any`).
  - `crypto` explizit als Dependency hinzufügen (wird in `imap_service.dart` genutzt, fehlt aber).
  - Unbenutzte oder redundante Packages aufräumen (`file_picker` vs `file_selector`).
- [ ] **Sicherheitslücke beheben (IMAP Passwörter):**
  - Den hartcodierten AES-Salt & IV (`jobtracker_local_secret_salt_2026`) aus `imap_service.dart` entfernen.
  - Das Package `flutter_secure_storage` integrieren, um den Master-Key für die Ver-/Entschlüsselung der E-Mail-Passwörter sicher im OS-Schlüsselbund zu speichern.
- [ ] **PDF-Export Bugfix (Jobcenter-Nachweis):**
  - In `pdf_generator.dart`: Das Layout von `pw.Page` auf `pw.MultiPage` umstellen, da der Export bei vielen Bewerbungen sonst aufgrund eines Überlaufs (Overflow) abstürzt.
- [ ] **Riverpod State Management säubern:**
  - Hacks wie den `customColumnsRefreshProvider` (manueller Counter) entfernen und durch standardmäßiges `ref.invalidate()` ersetzen.
  - Notifier-Typen vereinheitlichen.
- [ ] **Code-Splitting (Refactoring):**
  - Die Datei `application_form_screen.dart` (aktuell >45KB) in kleinere, wartbare Widgets aufteilen (z.B. Tabs für Basisdaten, Dokumente, Notizen).

---

## Phase 2: UX (Benutzerfreundlichkeit) & Feature-Erweiterungen

Die App muss intuitiv bedienbar werden, auch für technisch weniger versierte Nutzer.

- [ ] **Onboarding & Empty States:**
  - Einen Tutorial-Flow beim ersten Start einbauen (Wie lege ich eine Bewerbung an? Wie nutze ich das Chrome-Plugin?).
  - Hübsche "Empty States" (Illustrationen) anzeigen, wenn z.B. noch keine Bewerbungen in der Liste sind.
- [ ] **Echtes Drag & Drop Kanban:**
  - Die bestehende (statische) Kanban-Ansicht in `applications_screen.dart` mit Flutters `Draggable` und `DragTarget` ausstatten.
  - Beim Verschieben einer Karte muss der Status (`offen`, `versendet`, `interview` etc.) in der Drift-DB automatisch aktualisiert werden.
- [ ] **Bewerbungs-Trichter (Funnel) im Dashboard:**
  - Mit `fl_chart` ein Trichter-Diagramm ins Dashboard einbauen, das die Conversion-Rate visualisiert (z.B. 100 Versendet -> 15 Interviews -> 2 Zusagen).

---

## Phase 3: Die 100% Lokale Extraktions-Strategie (Privacy First)

Um rechtliche DSGVO-Risiken und Hardware-Überlastung auf alten PCs auszuschließen, verzichtet die App komplett auf integrierte Cloud-LLMs oder API-Keys. Die Extraktion bleibt zu 100% lokal, schnell und ressourcenschonend.

- [ ] **Stufe 1: JSON-LD / Schema.org Parsing (Der Cheat Code):**
  - Den `JobPostingExtractor` so erweitern, dass er das HTML-DOM (`html` Package) nach `<script type="application/ld+json">` durchsucht.
  - Jobbörsen wie Stepstone/LinkedIn nutzen dort das `JobPosting`-Schema. Das JSON via `jsonDecode` auslesen, um Firma, Gehalt und Position mit 0% CPU-Last und 100% Präzision zu erhalten.
- [ ] **Stufe 2: Optimiertes Offline-Fallback:**
  - Den bestehenden `NaiveBayesClassifier` von simplen Wortzählungen auf **TF-IDF** (Term Frequency-Inverse Document Frequency) umbauen, um die Präzision bei unstrukturiertem Text zu erhöhen, ohne alte CPUs zu belasten.
- [ ] **Stufe 3: Das manuelle Sicherheitsnetz:**
  - Die geplante "Split-View mit Smart-Markern" (PDF/Web-Ansicht rechts, Formular links) ist das primäre Rückfallsystem. Der Nutzer markiert Daten manuell, falls automatische Wege versagen.

---

## Phase 4: Die Companion Chrome-Erweiterung ("Smart Clipboard")

Um die fehlenden Schnittstellen zum Browser (Teal-Import & Simplify-Ausfüllen) zu schließen, wird ein winziges "Companion Plugin" gebaut. WICHTIG: Es agiert juristisch sicher als reines Assistenz-Tool (kein automatisiertes Scraping!).

- [ ] **Lokale Brücke in der Flutter-App:**
  - Das Package `shelf` implementieren. Einen lokalen HTTP-Server (z.B. `localhost:8080`) starten.
- [ ] **Erweiterte Fenster-Steuerung (Desktop):**
  - Das Package `window_manager` integrieren.
  - **Aktion Import:** Sendet das Plugin Daten, ruft Flutter `windowManager.show()` und `.focus()` auf.
  - **Aktion Auto-Fill:** Die Flutter-App verkleinert sich in einen "Side-Panel Overlay-Modus" (`setAlwaysOnTop(true)`), um Daten bequem herüberzuziehen.
- [ ] **Bau der Chrome Erweiterung (Manifest V3 - Smart Clipboard):**
  - Ein minimales JS-Plugin mit `host_permissions` für `http://localhost:8080/`.
  - **Manueller Import-Modus:** Das Plugin liest die Seite **nur** auf expliziten Klick des Nutzers (oder liest nur den vom Nutzer markierten Text) und schickt diesen an die lokale App. Kein automatisiertes Abgrasen im Hintergrund (Ban-Schutz).
  - **Ausfüll-Modus:** Plugin fragt die lokale Flutter-App nach Profildaten und fügt sie auf Klick ins aktuelle Formular ein.

---

## Phase 5: Externe KI-Assistenz (MCP Integration)

Die App selbst bleibt KI-frei. Wenn der Nutzer KI-Magie (Automatisierte Anschreiben, Datenbank-Analyse) wünscht, nutzt er seinen eigenen lokalen Entwickler-Assistenten (wie Antigravity/Gemini) über das **Model Context Protocol (MCP)**.

- [ ] **JobTracker MCP-Adapter erstellen:**
  - Einen lokalen MCP-Server für JobTracker einrichten (entweder als Script in `.agents/` oder in den `shelf`-Server integriert), der Lese- und Schreibzugriff auf die `jobtracker.sqlite` Datenbank bietet.
- [ ] **Tools für externe KI definieren:**
  - Freigabe von Tools wie: `get_applications()`, `add_application(data)`, `update_status(id)`.
- [ ] **Ergebnis (Unix-Philosophie):**
  - JobTracker bleibt eine winzige, blitzschnelle Datenbank-App.
  - Externe KI-Agenten können auf Zuruf (z.B. "Markiere Bewerbung X als abgesagt") via MCP mit der App interagieren.


