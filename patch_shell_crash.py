import os

path = 'lib/presentation/widgets/responsive_shell.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("return Column(", "return Material(\n      color: Theme.of(context).colorScheme.surface,\n      child: Column(")

# Find the end of the build method to close the Material widget
import re
# The end of the file is currently:
#         ),
#       ],
#     );
#   }
# }
text = re.sub(r"        \),\n      \],\n    \);\n  }\n}\n?", "        ),\n      ],\n    ),\n    );\n  }\n}\n", text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Patched!")
