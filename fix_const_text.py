# -*- coding: utf-8 -*-
path = 'lib/presentation/screens/settings/settings_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Fix the EXPERIMENTELL
text = text.replace(
    "child: const Text(\n                                      '⚗ EXPERIMENTELL',",
    "child: Text(\n                                      AppLocalizations.of(context)!.settingsImapExp,"
)
# Just in case there is no newline
text = text.replace(
    "child: const Text('⚗ EXPERIMENTELL',",
    "child: Text(AppLocalizations.of(context)!.settingsImapExp,"
)
text = text.replace(
    "child: const Text('⚗ EXPERIMENTELL'",
    "child: Text(AppLocalizations.of(context)!.settingsImapExp"
)

# And make sure "const Row(" on line 464 is gone.
text = text.replace("child: const Row(", "child: Row(")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed EXPERIMENTELL")
