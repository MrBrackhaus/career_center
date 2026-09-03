# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/settings/settings_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("'Einstellungen'", "loc.settingsTitle")
text = text.replace("'Sprache / Language'", "loc.settingsLanguage")
text = text.replace("'Design-Modus'", "loc.settingsTheme")
text = text.replace("'Hell'", "loc.settingsThemeLight")
text = text.replace("'Dunkel'", "loc.settingsThemeDark")
text = text.replace("'System-Standard'", "loc.settingsThemeSystem")
text = text.replace("'Preset-Theme'", "loc.settingsPreset")
text = text.replace("'Akzentfarbe (Seed Color)'", "loc.settingsAccentColor")
text = text.replace("'Jobcenter / Arbeitsamt-Modus'", "loc.settingsJobcenterMode")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Settings patched!")
