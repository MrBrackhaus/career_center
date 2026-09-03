import os

path = 'lib/presentation/widgets/responsive_shell.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Wrap WindowCaption in a SizedBox with fixed height, and provide a title
old_code = """          WindowCaption(
            brightness: Theme.of(context).brightness,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),"""

new_code = """          SizedBox(
            height: 32, // Fixed height for title bar
            child: WindowCaption(
              brightness: Theme.of(context).brightness,
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text(''), // Empty title
            ),
          ),"""

text = text.replace(old_code, new_code)

# Let's also make sure the Column has stretch just in case
text = text.replace("child: Column(\n      children: [", "child: Column(\n      crossAxisAlignment: CrossAxisAlignment.stretch,\n      children: [")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed WindowCaption!")
