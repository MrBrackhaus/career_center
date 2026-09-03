# -*- coding: utf-8 -*-
import os
import re
import json

translations = {
    # Application Form Tabs
    "Basisdaten": ("formTabBasic", "Basisdaten", "Basic Data"),
    "E-Mails & Kontakte": ("formTabEmails", "E-Mails & Kontakte", "Emails & Contacts"),
    "Dokumente": ("formTabDocs", "Dokumente", "Documents"),
    "Notizen": ("formTabNotes", "Notizen", "Notes"),
    
    # Basic Data Tab
    "Kontakt & Adresse": ("formBasicContact", "Kontakt & Adresse", "Contact & Address"),
    "Speichern": ("formBasicSave", "Speichern", "Save"),
    "Interview": ("formBasicInterview", "Interview", "Interview"),
    "Gehaltswunsch ('/Jahr)": ("formBasicSalary", "Gehaltswunsch (€/Jahr)", "Salary Expectation (€/Year)"),
    "Gehaltswunsch (€/Jahr)": ("formBasicSalary", "Gehaltswunsch (€/Jahr)", "Salary Expectation (€/Year)"),
    "Offen": ("formBasicOpen", "Offen", "Open"),
    "Zusage": ("formBasicAccepted", "Zusage", "Offer"),
    "Absage": ("formBasicRejected", "Absage", "Rejected"),
    "Link zur Stellenausschreibung": ("formBasicJobLink", "Link zur Stellenausschreibung", "Link to Job Posting"),
    "Füge einen Job-Link ein oder lade ein PDF hoch (z.B. Jobcenter), um Daten zu extrahieren.": ("formBasicJobLinkHint", "Füge einen Job-Link ein oder lade ein PDF hoch (z.B. Jobcenter), um Daten zu extrahieren.", "Paste a job link or upload a PDF (e.g., Jobcenter) to extract data."),
    "F\u00fcge einen Job-Link ein oder lade ein PDF hoch (z.B. Jobcenter), um Daten zu extrahieren.": ("formBasicJobLinkHint", "Füge einen Job-Link ein oder lade ein PDF hoch (z.B. Jobcenter), um Daten zu extrahieren.", "Paste a job link or upload a PDF (e.g., Jobcenter) to extract data."),
    "Ausfüllen": ("formBasicAutofill", "Ausfüllen", "Autofill"),
    "Ausf\u00fcllen": ("formBasicAutofill", "Ausfüllen", "Autofill"),
    "Pendelzeit Auto (Min.)": ("formBasicCommute", "Pendelzeit Auto (Min.)", "Commute Time (Min.)"),
    "Absagegrund": ("formBasicRejectionReason", "Absagegrund", "Rejection Reason"),
    "Oder PDF hochladen (Bewerbungsschreiben / Jobcenter)": ("formBasicUploadPdf", "Oder PDF hochladen", "Or upload PDF"),
    "Status": ("formBasicStatus", "Status", "Status"),
    "Webseite der Firma (z.B. https://)": ("formBasicCompanyWeb", "Webseite der Firma (z.B. https://)", "Company Website (e.g., https://)"),
    "Magic Auto-Fill": ("formBasicMagic", "Magic Auto-Fill", "Magic Auto-Fill"),
    "Löschen": ("formBasicDelete", "Löschen", "Delete"),
    "L\u00f6schen": ("formBasicDelete", "Löschen", "Delete"),
    "Versendet": ("formBasicSent", "Versendet", "Sent"),
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
                    safe_orig = orig.replace('(', r'\(').replace(')', r'\)').replace('?', r'\?').replace('.', r'\.').replace('+', r'\+').replace('€', r'€')
                    
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
print("Applied missing translations 4!")
