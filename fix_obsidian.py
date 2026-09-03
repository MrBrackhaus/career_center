# -*- coding: utf-8 -*-
import os

# Fix emoji in settings_screen.dart
path_settings = 'lib/presentation/screens/settings/settings_screen.dart'
with open(path_settings, 'r', encoding='utf-8') as f:
    text_settings = f.read()

text_settings = text_settings.replace("Text(' Obsidian')", "Text('?? Obsidian')")
text_settings = text_settings.replace("Text('?YY£ Obsidian')", "Text('?? Obsidian')")
text_settings = text_settings.replace("Text('õŸŸ£ Obsidian')", "Text('?? Obsidian')")

# Also just in case there are other weird variants
import re
text_settings = re.sub(r"Text\('.*?Obsidian'\)", "Text('?? Obsidian')", text_settings)

with open(path_settings, 'w', encoding='utf-8') as f:
    f.write(text_settings)


# Fix colors in theme_provider.dart
path_theme = 'lib/presentation/providers/theme_provider.dart'
with open(path_theme, 'r', encoding='utf-8') as f:
    text_theme = f.read()

# Make it darker
text_theme = text_theme.replace("Color(0xFF262626)", "Color(0xFF181818)")
text_theme = text_theme.replace("Color(0xFF363636)", "Color(0xFF2A2A2A)")
text_theme = text_theme.replace("Color(0xFF2F2F2F)", "Color(0xFF222222)")
text_theme = text_theme.replace("Color(0xFF323232)", "Color(0xFF252525)")
text_theme = text_theme.replace("Color(0xFF282828)", "Color(0xFF1C1C1C)")
text_theme = text_theme.replace("Color(0xFF1A1A1A)", "Color(0xFF121212)")

with open(path_theme, 'w', encoding='utf-8') as f:
    f.write(text_theme)

print("Obsidian fixes applied!")
