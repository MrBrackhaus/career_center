import codecs

def patch_arb(filepath, target, replacement):
    with codecs.open(filepath, 'r', 'utf-8') as f:
        text = f.read()
    text = text.replace(target, replacement)
    with codecs.open(filepath, 'w', 'utf-8') as f:
        f.write(text)

patch_arb('s:/Projekte/career_center/lib/l10n/app_de.arb', '"navTemplates": "Vorlagen"', '"navTemplates": "Meine Dokumente"')
patch_arb('s:/Projekte/career_center/lib/l10n/app_en.arb', '"navTemplates": "Templates"', '"navTemplates": "My Documents"')
