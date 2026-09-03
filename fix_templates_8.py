import json

arb_files = ['lib/l10n/app_de.arb', 'lib/l10n/app_en.arb']

for file in arb_files:
    with open(file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if file == 'lib/l10n/app_de.arb':
        data['promptSubtitle'] = "Fülle die Felder aus und generiere einen professionellen Prompt, den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst."
    else:
        data['promptSubtitle'] = "Fill out the fields and generate a professional prompt that you can use in ChatGPT, Claude, or any other AI of your choice."
        
    with open(file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

print("Added promptSubtitle to ARB files!")
