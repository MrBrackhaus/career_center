# -*- coding: utf-8 -*-
import os
import re

path_settings = 'lib/presentation/screens/settings/settings_screen.dart'
with open(path_settings, 'r', encoding='utf-8') as f:
    text_settings = f.read()

# We use regex to match ANY string before Obsidian
text_settings = re.sub(r"Text\('.*?Obsidian'\)", "Text('\U0001F5A4 Obsidian')", text_settings)

with open(path_settings, 'w', encoding='utf-8') as f:
    f.write(text_settings)

path_theme = 'lib/presentation/providers/theme_provider.dart'
with open(path_theme, 'r', encoding='utf-8') as f:
    text_theme = f.read()

text_theme = text_theme.replace("Color(0xFF262626)", "Color(0xFF181818)")
text_theme = text_theme.replace("Color(0xFF363636)", "Color(0xFF2A2A2A)")
text_theme = text_theme.replace("Color(0xFF2F2F2F)", "Color(0xFF222222)")
text_theme = text_theme.replace("Color(0xFF323232)", "Color(0xFF252525)")
text_theme = text_theme.replace("Color(0xFF282828)", "Color(0xFF1C1C1C)")
text_theme = text_theme.replace("Color(0xFF1A1A1A)", "Color(0xFF121212)")

with open(path_theme, 'w', encoding='utf-8') as f:
    f.write(text_theme)

print("Obsidian fixes applied!")
