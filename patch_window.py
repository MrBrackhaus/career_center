import os

# 1. Update main.dart
path_main = 'lib/main.dart'
with open(path_main, 'r', encoding='utf-8') as f:
    text_main = f.read()

text_main = text_main.replace("TitleBarStyle.normal", "TitleBarStyle.hidden")
with open(path_main, 'w', encoding='utf-8') as f:
    f.write(text_main)

# 2. Update responsive_shell.dart
path_shell = 'lib/presentation/widgets/responsive_shell.dart'
with open(path_shell, 'r', encoding='utf-8') as f:
    text_shell = f.read()

if "import 'package:window_manager/window_manager.dart';" not in text_shell:
    text_shell = "import 'dart:io';\nimport 'package:flutter/foundation.dart';\nimport 'package:window_manager/window_manager.dart';\n" + text_shell

# Wrap LayoutBuilder
old_builder = "return LayoutBuilder("
new_builder = """return Column(
      children: [
        if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS))
          WindowCaption(
            brightness: Theme.of(context).brightness,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        Expanded(
          child: LayoutBuilder("""
text_shell = text_shell.replace(old_builder, new_builder)

# Since we wrapped LayoutBuilder in Expanded, we must close it.
# The layout builder ends at the end of the build method.
# The original end was `    );` before the closing brace of build.
import re
text_shell = re.sub(r"    \);\n  }\n}\n", "    ),\n        ),\n      ],\n    );\n  }\n}\n", text_shell)

with open(path_shell, 'w', encoding='utf-8') as f:
    f.write(text_shell)

print("Window modernized!")
