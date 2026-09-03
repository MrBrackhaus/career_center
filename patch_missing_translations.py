# -*- coding: utf-8 -*-
import os
import re
import json

translations = {
    # Settings
    "Sprache / Language": ("settingsLanguageTitle", "Sprache / Language", "Language"),
    "App Sprache": ("settingsAppLanguage", "App Sprache", "App Language"),
    "Design & Personalisierung": ("settingsDesignTitle", "Design & Personalisierung", "Design & Personalization"),
    "Design Mode": ("settingsDesignMode", "Design Modus", "Design Mode"),
    "Accent Color": ("settingsAccentColorTitle", "Akzentfarbe", "Accent Color"),
    "Preset Theme": ("settingsPresetTheme", "Preset Theme", "Preset Theme"),
    "Vorgefertigte Design-Kombinationen": ("settingsPresetDesc", "Vorgefertigte Design-Kombinationen", "Pre-made design combinations"),
    "Jobcenter / Unemployment Agency Mode": ("settingsJobcenterTitle", "Jobcenter-Modus", "Jobcenter Mode"),
    "Zeigt den \"Nachweis Eigenbemühungen\"-Tab in der Navigation an": ("settingsJobcenterDesc", "Zeigt den 'Nachweis'-Tab an", "Shows the 'Proof of Efforts' tab"),
    "Dein Berufsfeld & Eigene Spalten": ("settingsFieldTitle", "Dein Berufsfeld & Eigene Spalten", "Your Profession & Custom Columns"),
    "Berufsfeld auswählen": ("settingsFieldSelect", "Berufsfeld auswählen", "Select profession"),
    "Zusätzliche Spalten (kommagetrennt)": ("settingsCustomCols", "Zusätzliche Spalten (kommagetrennt)", "Custom columns (comma separated)"),
    "Persönliche Daten (für PDF-Export)": ("settingsPersonalData", "Persönliche Daten (für PDF-Export)", "Personal Data (for PDF Export)"),
    "Dein Name": ("settingsYourName", "Dein Name", "Your Name"),
    "Deine Adresse": ("settingsYourAddress", "Deine Adresse", "Your Address"),
    
    # Dashboard
    "Aktuelle Woche": ("dashboardTabWeek", "Aktuelle Woche", "Current Week"),
    "Gesamtübersicht": ("dashboardTabTotal", "Gesamtübersicht", "Overview"),
    "Jede Reise beginnt mit dem ersten Schritt!": ("dashboardMsgStart", "Jede Reise beginnt mit dem ersten Schritt!", "Every journey begins with a single step!"),
    "Guter Start! Weiter so!": ("dashboardMsgGood", "Guter Start! Weiter so!", "Good start! Keep it up!"),
    "Starke Leistung diese Woche!": ("dashboardMsgStrong", "Starke Leistung diese Woche!", "Strong performance this week!"),
    "FANTASTISCHE ARBEIT DIESE WOCHE!": ("dashboardMsgFantastic", "FANTASTISCHE ARBEIT DIESE WOCHE!", "FANTASTIC WORK THIS WEEK!"),
    "NEUE BEWERBUNGEN": ("dashboardNewApps", "NEUE BEWERBUNGEN", "NEW APPLICATIONS"),
    "AKTIVE BEWERBUNGEN": ("dashboardActiveApps", "AKTIVE BEWERBUNGEN", "ACTIVE APPLICATIONS"),
    "Wochenziel:": ("dashboardGoal", "Wochenziel:", "Weekly goal:"),
    "Diese Woche": ("dashboardThisWeek", "Diese Woche", "This week"),
    "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀": ("dashboardFooter", "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀", "Keep going! Every step brings you closer to your dream job. 🚀"),
    "Bleib dran! Jeder Schritt bringt dich n\u00e4her an den perfekten Job. \ud83d\ude80": ("dashboardFooter", "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀", "Keep going! Every step brings you closer to your dream job. 🚀"),
    "vs. letzte Woche": ("dashboardVsLastWeek", "vs. letzte Woche", "vs. last week"),
    "Bewerbungen": ("dashboardAppsLabel", "Bewerbungen", "applications"),
    
    # Applications
    "Suchen": ("appSearch", "Suchen", "Search"),
    "Suche nach Firma, Position, Ort...": ("appSearchHint", "Suche nach Firma, Position, Ort...", "Search company, position, location..."),
    "Alle": ("appFilterAll", "Alle", "All"),
    "Posteingang checken": ("appCheckInbox", "Posteingang checken", "Check Inbox"),
    "Zeit für den ersten Schritt!": ("appEmptyTitle", "Zeit für den ersten Schritt!", "Time for the first step!"),
    "Lege deine erste Bewerbung an und organisiere deinen Weg zum Traumjob.": ("appEmptyDesc", "Lege deine erste Bewerbung an und organisiere deinen Weg zum Traumjob.", "Create your first application and organize your path to your dream job."),
    
    # Calendar
    "Klicke auf einen markierten Tag fuer Details.": ("calClickDetails", "Klicke auf einen markierten Tag für Details.", "Click on a highlighted day for details."),
    "Klicke auf einen markierten Tag f\u00fcr Details.": ("calClickDetails", "Klicke auf einen markierten Tag für Details.", "Click on a highlighted day for details."),
    "Ueberfaellig": ("calOverdue", "Überfällig", "Overdue"),
    "Nachhaken": ("calFollowUp", "Nachhaken", "Follow-up"),
    
    # Report
    "Generiert am:": ("reportGeneratedOn", "Generiert am:", "Generated on:"),
    "Keine Bewerbungen vorhanden.": ("reportNoApps", "Keine Bewerbungen vorhanden.", "No applications found."),
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
                    # Handle raw string replacement cautiously
                    safe_orig = orig.replace('(', r'\(').replace(')', r'\)').replace('?', r'\?').replace('.', r'\.')
                    
                    # Regex to match 'orig' or "orig"
                    pattern = r"['\"]" + safe_orig + r"['\"]"
                    replacement = f"AppLocalizations.of(context)!.{key}"
                    
                    if re.search(pattern, content):
                        content = re.sub(pattern, replacement, content)
                        changed = True
                        
                if changed:
                    # Remove const wrapping AppLocalizations if we introduced any
                    content = re.sub(r"const\s+([A-Za-z0-9_]+)\s*\(([^)]*AppLocalizations[^)]*)\)", r"\1(\2)", content)
                    content = re.sub(r"const\s+Text\s*\(\s*AppLocalizations", r"Text(AppLocalizations", content)
                    
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(content)

update_arbs()
patch_files()
print("Applied missing translations!")
