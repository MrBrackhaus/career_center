# -*- coding: utf-8 -*-
import os

path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# I will insert it right after `Widget build(BuildContext context) {`
build_addition = """
    final loc = AppLocalizations.of(context)!;
    final statusOptions = [loc.appFilterAll, 'offen', 'versendet', 'interview', 'absage', 'zusage'];
    final currentStatusFilter = _statusFilter ?? loc.appFilterAll;
"""

text = text.replace(
    "Widget build(BuildContext context) {\n    final applicationsAsync",
    "Widget build(BuildContext context) {\n" + build_addition + "    final applicationsAsync"
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Inserted state vars!")
