import sys

path = 'lib/presentation/screens/settings/settings_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# I need to add import for changelog screen
if "import '../changelog/changelog_screen.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../changelog/changelog_screen.dart';")

# Replace `const SizedBox(height: 32),` at the end of the view with our About section
about_card = """
              // Über diese App
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Über diese App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Version'),
                        trailing: Text('0.6.0 Alpha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.new_releases),
                        title: const Text('Changelog ansehen'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
"""

text = text.replace('              const SizedBox(height: 32),\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n}', about_card + '            ],\n          ),\n        ),\n      ),\n    );\n  }\n}')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated Settings Screen")
