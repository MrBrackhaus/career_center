# -*- coding: utf-8 -*-
import os
import re
import json

translations = {
    # Settings IMAP
    "E-Mail Synchronisation (IMAP)": ("settingsImapTitle", "E-Mail Synchronisation (IMAP)", "Email Synchronization (IMAP)"),
    "Empfängt Absagen/Einladungen automatisch": ("settingsImapDesc", "Empfängt Absagen/Einladungen automatisch", "Automatically receives rejections/invitations"),
    "EXPERIMENTELL": ("settingsImapExp", "EXPERIMENTELL", "EXPERIMENTAL"),
    "Diese Funktion ist noch in Entwicklung. Die automatische Erkennung von Firmennamen und Bewerbungen kann ungenau sein. Importierte Einträge bitte manuell prüfen.": ("settingsImapWarning", "Diese Funktion ist noch in Entwicklung. Die automatische Erkennung von Firmennamen und Bewerbungen kann ungenau sein. Importierte Einträge bitte manuell prüfen.", "This feature is still in development. Automatic detection of company names and applications may be inaccurate. Please check imported entries manually."),
    "Anbieter": ("settingsImapProvider", "Anbieter", "Provider"),
    "Manuell / Eigener Server": ("settingsImapManual", "Manuell / Eigener Server", "Manual / Custom Server"),
    "IMAP Server": ("settingsImapServer", "IMAP Server", "IMAP Server"),
    "Port": ("settingsImapPort", "Port", "Port"),
    "E-Mail Adresse": ("settingsImapEmail", "E-Mail Adresse", "Email Address"),
    "Passwort (App-Passwort)": ("settingsImapPassword", "Passwort (App-Passwort)", "Password (App Password)"),
    "Daten speichern": ("settingsImapSave", "Daten speichern", "Save Data"),
    
    # Settings Export
    "Daten-Export": ("settingsExportTitle", "Daten-Export", "Data Export"),
    "Jobcenter-Nachweis exportieren (PDF)": ("settingsExportPdf", "Jobcenter-Nachweis exportieren (PDF)", "Export Jobcenter Report (PDF)"),
    "Export als CSV": ("settingsExportCsv", "Export als CSV", "Export as CSV"),
    "Datenbank Backup exportieren (.sqlite)": ("settingsExportBackup", "Datenbank Backup exportieren (.sqlite)", "Export Database Backup (.sqlite)"),
    "Datenbank aus Backup wiederherstellen": ("settingsExportRestore", "Datenbank aus Backup wiederherstellen", "Restore Database from Backup"),
    "Info: App-Neustart nach Import erforderlich.": ("settingsExportRestart", "Info: App-Neustart nach Import erforderlich.", "Info: App restart required after import."),
    "App beenden": ("settingsAppQuit", "App beenden", "Quit App"),
    
    # Applications
    "Nichts gefunden.": ("appNotFoundTitle", "Nichts gefunden.", "Nothing found."),
    "Mit diesen Filtereinstellungen gibt es leider keine Treffer.": ("appNotFoundDesc", "Mit diesen Filtereinstellungen gibt es leider keine Treffer.", "There are no matches for these filter settings."),
    "Suche nach Firma, Position, Ort...": ("appSearchHint", "Suche nach Firma, Position, Ort...", "Search company, position, location..."),
    "Alle": ("appFilterAll", "Alle", "All"),
}

def update_arbs():
    for lang, idx in [('de', 1), ('en', 2)]:
        path = f'lib/l10n/app_{lang}.arb'
        with open(path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for orig, (key, de_val, en_val) in translations.items():
            if key not in data:
                data[key] = de_val if lang == 'de' else en_val
                
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

def patch_files():
    directory = 'lib/presentation/screens'
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                changed = False
                for orig, (key, _, _) in translations.items():
                    safe_orig = orig.replace('(', r'\(').replace(')', r'\)').replace('?', r'\?').replace('.', r'\.').replace('🚀', r'🚀')
                    
                    pattern = r"['\"]" + safe_orig + r"['\"]"
                    replacement = f"AppLocalizations.of(context)!.{key}"
                    
                    if re.search(pattern, content):
                        content = re.sub(pattern, replacement, content)
                        changed = True
                        
                if changed:
                    content = re.sub(r"const\s+([A-Za-z0-9_]+)\s*\(([^)]*AppLocalizations[^)]*)\)", r"\1(\2)", content)
                    content = re.sub(r"const\s+Text\s*\(\s*AppLocalizations", r"Text(AppLocalizations", content)
                    content = re.sub(r"const\s+Tab\s*\(\s*text:\s*AppLocalizations", r"Tab(text: AppLocalizations", content)
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(content)

update_arbs()
patch_files()
print("Applied missing translations 3!")
