import codecs

# Patch spell_checker.dart
with codecs.open('s:/Projekte/career_center/lib/core/utils/spell_checker.dart', 'r', 'utf-8') as f:
    text = f.read()

text = text.replace("// 'de': 'Deutsch', // Removed due to GPL license", "'de': 'Deutsch',")
text = text.replace("_currentLanguage = 'en'", "_currentLanguage = 'de'")
text = text.replace("language = 'en'", "language = 'de'")

with codecs.open('s:/Projekte/career_center/lib/core/utils/spell_checker.dart', 'w', 'utf-8') as f:
    f.write(text)

# Patch settings_screen.dart
with codecs.open('s:/Projekte/career_center/lib/presentation/screens/settings/settings_screen.dart', 'r', 'utf-8') as f:
    text2 = f.read()

text2 = text2.replace("String _spellCheckLanguage = 'en';", "String _spellCheckLanguage = 'de';")

with codecs.open('s:/Projekte/career_center/lib/presentation/screens/settings/settings_screen.dart', 'w', 'utf-8') as f:
    f.write(text2)

# Patch settings_dao.dart
with codecs.open('s:/Projekte/career_center/lib/data/database/daos/settings_dao.dart', 'r', 'utf-8') as f:
    text3 = f.read()
text3 = text3.replace("return (await getSettingByKey('spellCheckLanguage'))?.value ?? 'en';", "return (await getSettingByKey('spellCheckLanguage'))?.value ?? 'de';")
with codecs.open('s:/Projekte/career_center/lib/data/database/daos/settings_dao.dart', 'w', 'utf-8') as f:
    f.write(text3)

print("Default language switched back to German")
