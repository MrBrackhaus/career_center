import os

path = 'lib/core/router/app_router.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import_stmt = "import '../../presentation/widgets/responsive_shell.dart';\n"
if "responsive_shell.dart" not in text:
    text = text.replace("import '../../presentation/screens/settings/settings_screen.dart';", "import '../../presentation/screens/settings/settings_screen.dart';\n" + import_stmt)

# We need to replace the Scaffold inside ScaffoldWithTopBar's build method.
import re

# Find the start of `return Scaffold(` and the end `body: child,\n    );`
pattern = re.compile(r'return Scaffold\([\s\S]*?body: child,\n\s*\);')
match = pattern.search(text)
if match:
    text = text[:match.start()] + 'return ResponsiveShell(child: child);' + text[match.end():]
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Replaced Scaffold with ResponsiveShell!")
else:
    print("Could not find Scaffold block!")
