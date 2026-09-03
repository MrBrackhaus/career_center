path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Add import for ApplicationCard
if "import 'widgets/application_card.dart';" not in text:
    text = text.replace("import 'package:go_router/go_router.dart';", "import 'package:go_router/go_router.dart';\nimport 'widgets/application_card.dart';")

# 1. Modify the Toolbar (remove big search bar, replace with compact one + Add Button)
old_toolbar = """            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.appSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: currentStatusFilter,
                    items: statusOptions.map((String status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) => setState(() => _statusFilter = value == loc.appFilterAll ? null : value),
                  ),
                ],
              ),
            ),"""

new_toolbar = """            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Compact Search
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.appSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    ),
                  ),
                  const Spacer(),
                  // Filter
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentStatusFilter,
                        icon: const Icon(Icons.filter_list, size: 18),
                        items: statusOptions.map((String status) {
                          return DropdownMenuItem(value: status, child: Text(status));
                        }).toList(),
                        onChanged: (value) => setState(() => _statusFilter = value == loc.appFilterAll ? null : value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // New Application Button (moved from FAB)
                  FilledButton.icon(
                    onPressed: () => context.go('/applications/add'),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.btnNewApplication),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),"""
text = text.replace(old_toolbar, new_toolbar)

# 2. Replace DataTable with ListView of ApplicationCards
import re
# We need to replace the entire SingleChildScrollView containing DataTable
pattern = r"return SingleChildScrollView\(\s*scrollDirection: Axis\.horizontal,.*?\);\s*\}\s*\)\s*\]\s*\)\s*;\s*\}\s*\)\s*,\s*\)\s*,\s*\]\s*,\s*\)\s*,\s*floatingActionButton:"
# Actually, let's just use string replacement for the body block
# It's better to just replace the child of Expanded from applicationsAsync.when ...
# I'll just write a script that does it safely.
