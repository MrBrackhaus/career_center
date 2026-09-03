# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace(
    "String _statusFilter = AppLocalizations.of(context)!.appFilterAll;",
    "String? _statusFilter;"
)
text = text.replace(
    "final List<String> _statusOptions = [AppLocalizations.of(context)!.appFilterAll, 'offen', 'versendet', 'interview', 'absage', 'zusage'];",
    ""
)

# In build, add _statusOptions and handle _statusFilter
build_addition = """
    final loc = AppLocalizations.of(context)!;
    final statusOptions = [loc.appFilterAll, 'offen', 'versendet', 'interview', 'absage', 'zusage'];
    final currentStatusFilter = _statusFilter ?? loc.appFilterAll;
"""
text = text.replace(
    "final loc = AppLocalizations.of(context)!;",
    build_addition
)

text = text.replace("_statusFilter = val", "_statusFilter = val == loc.appFilterAll ? null : val")
text = text.replace("value: _statusFilter,", "value: currentStatusFilter,")
text = text.replace("items: _statusOptions", "items: statusOptions")

# Wait, there's another place: the filter logic
# if (_statusFilter != loc.appFilterAll) 
# The old code was: if (_statusFilter != AppLocalizations.of(context)!.appFilterAll)
# wait, actually the logic was:
# if (_statusFilter != 'Alle') ... -> this was replaced by patch_missing_translations2.py
# So if (_statusFilter != AppLocalizations.of(context)!.appFilterAll) -> if (currentStatusFilter != loc.appFilterAll)

text = text.replace("if (_statusFilter != AppLocalizations.of(context)!.appFilterAll)", "if (currentStatusFilter != loc.appFilterAll)")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed state initialization!")
