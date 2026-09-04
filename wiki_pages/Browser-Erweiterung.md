# Browser-Erweiterung installieren

Um Stellenanzeigen direkt von Job-Portalen mit einem einzigen Klick in die Bewerbungszentrale zu importieren, bieten wir eine Browser-Erweiterung an.

Da sich die Erweiterung noch in der Alpha-Phase befindet und (noch) nicht in den offiziellen Stores gelistet ist, wird sie manuell installiert ("Sideloading").

## Vorbereitung

In der heruntergeladenen ZIP-Datei der Bewerbungszentrale findest du neben der App (`.exe`) auch einen Ordner namens `browser_extension`. Diesen Ordner benötigst du für die folgenden Schritte.

---

## 🟢 Google Chrome / Brave / Microsoft Edge

1. **Erweiterungs-Seite öffnen:**
   * **Chrome/Brave:** Gib in die Adresszeile `chrome://extensions/` ein.
   * **Edge:** Gib in die Adresszeile `edge://extensions/` ein.
2. **Entwicklermodus aktivieren:** Schalte oben rechts (oder bei Edge unten links) den **"Entwicklermodus"** (Developer mode) ein.
3. **Erweiterung laden:** Klicke oben links auf den neuen Button **"Entpackte Erweiterung laden"** (Load unpacked).
4. **Ordner auswählen:** Wähle den Ordner `browser_extension` aus, den du zuvor aus der ZIP-Datei entpackt hast. 

Die Erweiterung ist nun aktiv!

---

## 🦊 Mozilla Firefox

1. **Debugging-Seite öffnen:** Gib in die Adresszeile `about:debugging#/runtime/this-firefox` ein.
2. **Temporäres Add-on laden:** Klicke auf den Button **"Temporäres Add-on laden..."**.
3. **Datei auswählen:** Navigiere in den Ordner `browser_extension` und wähle die Datei `manifest.json` aus.

Die Erweiterung ist nun aktiv (in Firefox muss dies ggf. nach einem Neustart des Browsers wiederholt werden, da es temporär geladen wird).

---

## Nutzung

Wenn du dich auf einer unterstützten Jobbörse befindest (z.B. Indeed, Stepstone, LinkedIn), klicke einfach auf das Icon der Erweiterung oben rechts in deinem Browser, um die Daten der aktuellen Stellenanzeige in deine laufende Career Center App zu senden.
