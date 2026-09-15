# Architektur-Notizen & Zukunftsplanung

## Lebenslauf-Editor & PDF-Vorschau (Stand: MVP / Version 1.0)
Aktuell verwenden wir für den WYSIWYG-Editor des Lebenslaufs eine **Live-PDF-Vorschau** (über das `printing` und `pdf` Paket).
- **Grund:** Flutter bietet nativ keine Textsatz-Engine (Typesetting) an, die Textblöcke und Widgets automatisch über mehrere A4-Seiten (Container) umbricht. Das `pdf` Paket übernimmt diese Paginierung für uns (`pw.MultiPage`).
- **Langfristiges Ziel (Vom Nutzer angestrebt):** Eine saubere, native Flutter-Lösung ohne ständiges PDF-Rendering im Hintergrund finden. Eine Möglichkeit wäre die Entwicklung oder Einbindung einer spezialisierten Layout-Delegate-Engine, die Höhen misst und native Widgets auf mehrere Pages aufteilt, um ein noch performanteres und "echteres" Frontend-Erlebnis zu schaffen.
