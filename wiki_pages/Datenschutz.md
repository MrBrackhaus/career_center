# Datenschutz & Sicherheit

Bei der Entwicklung der Bewerbungszentrale stand ein Grundsatz von Anfang an fest: **Deine Daten gehören dir.**

Bewerbungsunterlagen, Lebensläufe, persönliche E-Mails und Notizen zu Vorstellungsgesprächen sind hochsensible Daten. Deshalb haben wir die App nach dem **"Local First"** (und Privacy by Design) Prinzip gebaut.

## 1. Lokale Datenspeicherung (SQLite)
Alle Informationen, die du in die App eingibst (Bewerbungen, Firmen, Notizen, Einstellungen), werden in einer lokalen **SQLite-Datenbank** direkt auf der Festplatte deines Computers gespeichert. 
* Es gibt keinen zentralen Cloud-Server, auf dem deine Daten gesammelt werden.
* Wir haben keinen Zugriff auf deine Datenbank.

## 2. E-Mail-Tracking (IMAP)
Wenn du die Funktion zum E-Mail-Tracking aktivierst, verbindet sich die App direkt (Peer-to-Peer) von deinem Rechner mit dem Mailserver deines Anbieters (z.B. GMX, Gmail, Web.de). 
* Deine IMAP-Zugangsdaten werden nur lokal und verschlüsselt gespeichert.
* Es ist kein Zwischenserver oder Drittanbieter-Dienst in das Lesen deiner E-Mails involviert.

## 3. Nutzung von KI-Features
Solltest du experimentelle KI-Features nutzen (z.B. das automatische Extrahieren von Daten aus PDFs), weist die App explizit darauf hin, wenn für diesen spezifischen Vorgang Daten an eine Schnittstelle (z.B. OpenAI oder lokales LLM) gesendet werden. Du hast jederzeit die volle Kontrolle darüber, ob du diese Komfort-Features nutzen möchtest oder nicht.

## 4. Datensicherung (Backups)
Da es keine Cloud-Synchronisation gibt, bist du selbst für die Sicherung deiner Daten verantwortlich. Wir empfehlen, den Ordner der Anwendungsdaten (in dem die SQLite-Datei liegt) in deine regelmäßigen Windows-Backups einzubeziehen.

> **Transparenz:** Da es sich um ein Open-Source-Projekt handelt, kann der gesamte Quellcode der Software [hier auf GitHub eingesehen werden](https://github.com/MrBrackhaus/career_center). Jeder kann überprüfen, dass keine versteckten Tracker eingebaut sind.
