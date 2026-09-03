import json

arb_files = ['lib/l10n/app_de.arb', 'lib/l10n/app_en.arb']

for file in arb_files:
    with open(file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if file == 'lib/l10n/app_de.arb':
        data['noAppsFound'] = "Keine Bewerbungen gefunden."
        data['templatesEmptyState'] = "Noch keine Vorlagen erstellt."
        data['templatesEmptyStateSub'] = "Erstelle dein erstes Anschreiben oder einen Textbaustein!"
    else:
        data['noAppsFound'] = "No applications found."
        data['templatesEmptyState'] = "No templates created yet."
        data['templatesEmptyStateSub'] = "Create your first cover letter or text snippet!"
        
    with open(file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

print("Added keys to ARB files!")
