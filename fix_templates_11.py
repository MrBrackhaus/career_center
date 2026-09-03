path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re

# Find the point where `_promptToneController` text field is being defined (which is at line ~268-274).
# We know that `children: [` and `TextField(` happens before it.
# Wait! In the current file, the duplicate `_promptToneController` was inserted by `fix_templates_10.py`.
# Let's just find the FIRST occurrence of "controller: _promptCompanyController,"
# and keep everything up to the END of that TextField block, which is `),` on line 220ish.
# Actually, the file has 189 `dart analyze` issues!
# Let's truncate the file manually.

lines = text.split('\n')
valid_lines = []
for i, line in enumerate(lines):
    valid_lines.append(line)
    if "prefixIcon: Icon(Icons.work)," in line:
        pass
    if "prefixIcon: Icon(Icons.business)," in line:
        pass
    if "prefixIcon: Icon(Icons.psychology)," in line:
        # this is the _promptSkillsController TextField
        pass
    # The last text field originally was _promptToneController but we'll just rewrite everything after _promptSkillsController to be safe.

# Let's print the lines around _promptSkillsController to see where to cut.
