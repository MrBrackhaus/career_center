import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/database/app_database.dart';

class ApplicationCard extends StatefulWidget {
  final Application application;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ApplicationCard({
    Key? key,
    required this.application,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final colorScheme = Theme.of(context).colorScheme;
    final hasLogoUrl = app.companyUrl != null && app.companyUrl!.isNotEmpty;
    // Extrahiere Domain für Clearbit Logo
    String? logoUrl;
    if (hasLogoUrl) {
      try {
        final uri = Uri.parse(app.companyUrl!);
        logoUrl = 'https://logo.clearbit.com/${uri.host}';
      } catch (_) {}
    }

    final avatar = logoUrl != null
        ? CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(logoUrl),
            onBackgroundImageError: (_, __) {},
            radius: 20,
          )
        : CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            radius: 20,
            child: Text(
              app.company.isNotEmpty ? app.company[0].toUpperCase() : '?',
              style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.2)
                : (_isHovering ? colorScheme.surfaceContainerHigh : colorScheme.surfaceContainer),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: _isHovering && !widget.isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                avatar,
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.position,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        app.company,
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  app.appliedDate != null ? DateFormat('dd.MM.yyyy').format(app.appliedDate!) : '-',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                ),
                const SizedBox(width: 16),
                _buildStatusBadge(app.status),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.go('/applications/edit/${app.id}');
                    } else if (value == 'delete') {
                      widget.onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Bearbeiten')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Löschen', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'offen': bgColor = Colors.orange; break;
      case 'versendet': bgColor = Colors.blue; break;
      case 'interview': bgColor = Colors.purple; break;
      case 'zusage': bgColor = Colors.green; break;
      case 'absage': bgColor = Colors.red; break;
      default: bgColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
