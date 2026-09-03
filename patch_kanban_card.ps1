$content = Get-Content "lib\presentation\screens\applications\applications_screen.dart" -Raw
$newCard = @"
  Widget _buildKanbanCard(Application app, bool isArchive) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/applications/edit/${app.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      app.position,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Bearbeiten'),
                        onTap: () => context.go('/applications/edit/${app.id}'),
                      ),
                      PopupMenuItem(
                        child: const Text('Löschen', style: TextStyle(color: Colors.red)),
                        onTap: () => Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _confirmDelete(context, app),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.business, size: 14, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      app.company,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (app.location != null && app.location!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        app.location!,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (app.appliedDate != null)
                    _buildTag(
                      Icons.calendar_today,
                      '${app.appliedDate!.day.toString().padLeft(2, '0')}.${app.appliedDate!.month.toString().padLeft(2, '0')}.${app.appliedDate!.year}',
                      Colors.blueGrey,
                    ),
                  if (app.remotePercentage != null && app.remotePercentage! > 0)
                    _buildTag(
                      Icons.home_work,
                      '${app.remotePercentage}% Remote',
                      Colors.teal,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
"@

$content = $content -replace "  Future<void> _confirmDelete", "$newCard`n`n  Widget _buildTag(IconData icon, String label, Color color) {`n    return Container(`n      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),`n      decoration: BoxDecoration(`n        color: color.withOpacity(0.1),`n        borderRadius: BorderRadius.circular(8),`n        border: Border.all(color: color.withOpacity(0.3)),`n      ),`n      child: Row(`n        mainAxisSize: MainAxisSize.min,`n        children: [`n          Icon(icon, size: 12, color: color),`n          const SizedBox(width: 4),`n          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),`n        ],`n      ),`n    );`n  }`n`n  Future<void> _confirmDelete"
Set-Content "lib\presentation\screens\applications\applications_screen.dart" -Value $content -Encoding UTF8
