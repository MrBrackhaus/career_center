import codecs

# Patch spell_checker.dart
with codecs.open('s:/Projekte/career_center/lib/core/utils/spell_checker.dart', 'r', 'utf-8') as f:
    text = f.read()

text = text.replace("'de': 'Deutsch',", "// 'de': 'Deutsch', // Removed due to GPL license")
text = text.replace("_currentLanguage = 'de'", "_currentLanguage = 'en'")
text = text.replace("language = 'de'", "language = 'en'")

with codecs.open('s:/Projekte/career_center/lib/core/utils/spell_checker.dart', 'w', 'utf-8') as f:
    f.write(text)

# Patch settings_screen.dart
with codecs.open('s:/Projekte/career_center/lib/presentation/screens/settings/settings_screen.dart', 'r', 'utf-8') as f:
    text2 = f.read()

text2 = text2.replace("String _spellCheckLanguage = 'de';", "String _spellCheckLanguage = 'en';")

with codecs.open('s:/Projekte/career_center/lib/presentation/screens/settings/settings_screen.dart', 'w', 'utf-8') as f:
    f.write(text2)

# Patch settings_dao.dart
with codecs.open('s:/Projekte/career_center/lib/data/database/daos/settings_dao.dart', 'r', 'utf-8') as f:
    text3 = f.read()
text3 = text3.replace("return (await getSettingByKey('spellCheckLanguage'))?.value ?? 'de';", "return (await getSettingByKey('spellCheckLanguage'))?.value ?? 'en';")
with codecs.open('s:/Projekte/career_center/lib/data/database/daos/settings_dao.dart', 'w', 'utf-8') as f:
    f.write(text3)

print("Default language switched to English")
