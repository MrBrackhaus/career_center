# -*- coding: utf-8 -*-
import os
import re
import json

translations = {
    # Jobcenter Report
    "Generiert am:": ("reportGeneratedAt", "Generiert am:", "Generated at:"),
    " Uhr": ("reportTimeSuffix", " Uhr", ""),
    
    # Dashboard Weekly Report
    "Wochenziel:": ("weeklyGoal", "Wochenziel:", "Weekly Goal:"),
    " von 5 Bewerbungen": ("weeklyGoalSuffix", " von 5 Bewerbungen", " of 5 applications"),
    "Diese Woche ": ("weeklyThisWeek", "Diese Woche ", "This week "),
    " Bewerbungen vs. letzte Woche ": ("weeklyVs", " Bewerbungen vs. letzte Woche ", " applications vs. last week "),
    " Bewerbungen": ("weeklyApplications", " Bewerbungen", " applications"),
    "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀": ("weeklyMotivationalFooter", "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀", "Keep it up! Every step brings you closer to the perfect job. 🚀"),
    "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job.": ("weeklyMotivationalFooterNoIcon", "Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job.", "Keep it up! Every step brings you closer to the perfect job."),
    
    # Templates Screen
    "Meine Vorlagen": ("templatesTabMy", "Meine Vorlagen", "My Templates"),
    "Muster & Beispiele": ("templatesTabExamples", "Muster & Beispiele", "Patterns & Examples"),
    
    # Prompt Generator
    "KI Prompt Generator": ("promptTitle", "KI Prompt Generator", "AI Prompt Generator"),
    "Fülle die Felder aus und generiere einen professionellen Prompt, den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst.": ("promptDesc", "Fülle die Felder aus und generiere einen professionellen Prompt, den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst.", "Fill in the fields to generate a professional prompt that you can use in ChatGPT, Claude, or any other AI of your choice."),
    "F\\u00fclle die Felder aus und generiere einen professionellen Prompt, den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst.": ("promptDesc", "Fülle die Felder aus und generiere einen professionellen Prompt, den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst.", "Fill in the fields to generate a professional prompt that you can use in ChatGPT, Claude, or any other AI of your choice."),
    "Position / Stellentitel": ("promptPosition", "Position / Stellentitel", "Position / Job Title"),
    "Firma": ("promptCompany", "Firma", "Company"),
    "Deine Top-Skills & Erfahrung": ("promptSkills", "Deine Top-Skills & Erfahrung", "Your Top Skills & Experience"),
    "Tonalität": ("promptTone", "Tonalität", "Tone"),
    "Tonalit\\u00e4t": ("promptTone", "Tonalität", "Tone"),
    "professionell und freundlich": ("promptToneDefault", "professionell und freundlich", "professional and friendly"),
    "Prompt generieren": ("promptGenerate", "Prompt generieren", "Generate Prompt"),
    
    # Examples
    "Initiativbewerbung": ("tplInitiative", "Initiativbewerbung", "Spontaneous Application"),
    "Antwort auf Stellenanzeige": ("tplReply", "Antwort auf Stellenanzeige", "Response to Job Ad"),
    "Erinnerung / Follow-up": ("tplFollowUp", "Erinnerung / Follow-up", "Reminder / Follow-up"),
    "Absage höflich beantworten": ("tplRejection", "Absage höflich beantworten", "Polite Rejection Response"),
    "Absage h\\u00f6flich beantworten": ("tplRejection", "Absage höflich beantworten", "Polite Rejection Response"),
    "ANSCHREIBEN": ("tplTypeCover", "ANSCHREIBEN", "COVER LETTER"),
    "TEXTBAUSTEIN": ("tplTypeSnippet", "TEXTBAUSTEIN", "TEXT SNIPPET"),
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
print("Applied missing translations 5!")
