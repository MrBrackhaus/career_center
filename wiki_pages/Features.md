# Features & Funktionen

Die Bewerbungszentrale ist vollgepackt mit smarten, datenschutzfreundlichen Tools, die den kompletten Bewerbungsprozess abdecken. Hier ist ein ausführlicher Überblick aller Funktionen:

## 📝 Zentraler "Freier Editor" & ATS-Analyse
* **Ein Editor für alles:** Egal ob Vorlagen, Notizen oder konkrete Bewerbungsanschreiben – alles wird im einheitlichen, leistungsstarken "Freien Editor" verfasst.
* **Pro-Canvas & Lineal:** Der Editor simuliert ein echtes A4-Blatt (Google Docs Style) mit maßstabsgetreuem Lineal zur perfekten Einhaltung der DIN-5008-Formatierung (z. B. Briefkopf-Ränder).
* **Live Job-Fit (ATS):** Während du tippst, vergleicht die App in einer Seitenleiste deinen Text mit der Stellenanzeige und hakt geforderte Keywords in Echtzeit ab.
* **Offline-Rechtschreibprüfung:** Integrierte, blitzschnelle Grammatik- und Rechtschreibkorrektur mit 12 riesigen Offline-Wörterbüchern.

## 🤖 KI-Workspace & Auto-Anschreiben (100% Lokal)
* **Lokale LLM-Integration:** Verbinde die App über die Einstellungen mit deinem lokalen Ollama-Server oder NVIDIA Jetson. Keine Daten fließen in die Cloud!
* **Chatte mit deiner KI:** Der KI-Workspace-Tab bietet einen voll funktionsfähigen Chatbot, der dir hilft, Vorstellungsgespräche zu üben oder Textpassagen zu verfeinern.
* **1-Klick Anschreiben:** Auf Basis der extrahierten Stellendaten und deines hinterlegten Profils kann die KI vollautomatisch ein hochgradig personalisiertes Anschreiben generieren und direkt in den Editor einfügen.

## 📄 Meine Dokumente (Lebensläufe & Vorlagen)
* **1:1 PDF-Übernahme:** Lade deinen fertigen Lebenslauf als PDF hoch. Er wird sicher in der App gespeichert und bei Bedarf 1:1 an Unternehmen verschickt.
* **Vorlagen-Verwaltung:** Speichere erfolgreiche Anschreiben als wiederverwendbare Templates.

## 🗂️ Bewerbungen: Kanban-Board & Auto-Import
* **Visuelles Tracking:** Verwalte den Status deiner Bewerbungen (Vorbereitung, Versendet, Interview, Zusage, Absage) per einfachem Drag & Drop.
* **Smarter Import:** Lege Bewerbungen manuell an, ODER füge einfach eine Stellen-URL (z. B. Arbeitsagentur) bzw. ein Job-PDF ein. Die App extrahiert automatisch Jobtitel, Firma und die Beschreibung (mit robustem Regex-Fallback für blitzsauberen Text).

## 🌐 Chrome Browser-Erweiterung
* Surfe auf Jobportalen und importiere Stellenanzeigen mit nur einem Klick direkt in deine lokale Bewerbungszentrale.

## 📧 E-Mail Sync (IMAP & SMTP)
* **Integrierter Postausgang:** Versende fertige Bewerbungen (inkl. angehängtem Lebenslauf und Anschreiben) direkt aus der App.
* **Postfach-Überwachung:** Verknüpfe dein IMAP-Postfach sicher und lokal. Die App erkennt automatisiert Antworten von Unternehmen (z. B. Einladungen oder Absagen) und aktualisiert das Kanban-Board.

## 📊 Statistiken, Dashboards & Wochenberichte
* **Dashboard:** Lerne aus deinen Daten! Das Dashboard zeigt dir Antwort- und Absagequoten, durchschnittliche Pendelzeiten, einen Bewerbungs-Funnel und die Top-Absagegründe.
* **Dein Wochenbericht:** Ein motivierender Report, der vergleicht, wie viele Bewerbungen du diese Woche vs. letzte Woche geschafft hast.

## 📅 Integrierter Kalender
* Behalte Fristen, geplante Interviews und Versanddaten in einer klaren Monatsübersicht im Blick.

## 🏛️ Jobcenter-Nachweise
* Generiere auf Knopfdruck tabellarische PDFs als Nachweis deiner Eigenbemühungen für die Agentur für Arbeit oder das Jobcenter. Alle relevanten Daten (Datum, Firma, Status, Absagegrund) werden automatisch formatiert.

## 🔌 Antigravity & Model Context Protocol (MCP)
* **Für Entwickler und Power-User:** Die App fungiert als nativer MCP-Server auf Port 47392.
* Erlaube KI-Agenten (wie Antigravity), JSON-RPC-Befehle zu senden, um die Datenbank auszulesen, Lebensläufe zu durchsuchen oder komplette Workflows extern zu automatisieren.
