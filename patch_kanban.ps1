$content = Get-Content "lib\presentation\screens\applications\applications_screen.dart" -Raw
$newKanban = @"
  Widget _buildKanbanBoard(List<Application> apps) {
    final columns = [
      {'status': 'offen', 'title': (AppLocalizations.of(context)?.kanbanPreparation ?? 'In Vorbereitung')},
      {'status': 'versendet', 'title': (AppLocalizations.of(context)?.kanbanWaiting ?? 'Warten auf Antwort')},
      {'status': 'interview', 'title': (AppLocalizations.of(context)?.kanbanInterview ?? 'Im Gespräch')},
      {'status': 'zusage', 'title': (AppLocalizations.of(context)?.kanbanOffers ?? 'Angebote')},
      {'status': 'absage', 'title': (AppLocalizations.of(context)?.kanbanArchive ?? 'Archiv (Absagen)')},
    ];

    Widget buildColumn(Map<String, String> colDef, double width) {
      final status = colDef['status']!;
      final title = colDef['title']!;
      final isArchive = status == 'absage';
      final columnApps = apps.where((a) => a.status.toLowerCase() == status).toList();
      
      return DragTarget<Application>(
        onWillAcceptWithDetails: (details) {
          return details.data.status.toLowerCase() != status;
        },
        onAcceptWithDetails: (details) async {
          final app = details.data;
          final repository = ref.read(applicationsRepositoryProvider);
          await repository.updateApplication(app.copyWith(status: status).toCompanion(false));
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          
          return Opacity(
            opacity: isArchive ? 0.75 : 1.0,
            child: Container(
              width: width,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isHovering 
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5) 
                    : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(isArchive ? 0.3 : 0.5),
                borderRadius: BorderRadius.circular(16),
                border: isHovering 
                    ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) 
                    : (isArchive ? Border.all(color: Colors.grey.withOpacity(0.2), width: 1) : null),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${columnApps.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: columnApps.length,
                      itemBuilder: (context, index) {
                        final app = columnApps[index];
                        return Draggable<Application>(
                          data: app,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: width - 16, // match column width minus padding
                              child: _buildKanbanCard(app, isArchive),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildKanbanCard(app, isArchive),
                          ),
                          child: _buildKanbanCard(app, isArchive),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Mobile: Use PageView for snapping
          return PageView.builder(
            controller: PageController(viewportFraction: 0.85),
            itemCount: columns.length,
            itemBuilder: (context, index) {
              return buildColumn(columns[index], constraints.maxWidth * 0.85);
            },
          );
        } else {
          // Desktop/Tablet: Horizontal scrolling row
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns.map((col) => buildColumn(col, 320)).toList(),
            ),
          );
        }
      },
    );
  }
"@
$content = $content -replace "(?s)  Widget _buildKanbanBoard\(List<Application> apps\) \{.*?\n  \}" , $newKanban
Set-Content "lib\presentation\screens\applications\applications_screen.dart" -Value $content -Encoding UTF8
