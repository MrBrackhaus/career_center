path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Fix matchesStatus
old_matchesStatus = """final matchesStatus = _statusFilter == AppLocalizations.of(context)!.appFilterAll ||
                        app.status.toLowerCase() == (_statusFilter?.toLowerCase());"""
new_matchesStatus = """final matchesStatus = _statusFilter == null || _statusFilter == loc.appFilterAll ||
                        app.status.toLowerCase() == _statusFilter!.toLowerCase();"""
text = text.replace(old_matchesStatus, new_matchesStatus)

# Fix empty state title
old_emptyCheck = "_searchQuery.isEmpty && _statusFilter == AppLocalizations.of(context)!.appFilterAll"
new_emptyCheck = "_searchQuery.isEmpty && _statusFilter == null"
text = text.replace(old_emptyCheck, new_emptyCheck)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed filter logic")
