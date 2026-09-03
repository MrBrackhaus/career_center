$content = Get-Content "lib\presentation\screens\applications\application_form_screen.dart" -Raw
$newSplit = @"
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              Expanded(flex: 2, child: _buildDocumentPreview(context)),
              const Divider(height: 1, thickness: 1),
              Expanded(flex: 3, child: formWidget),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: formWidget),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: _buildDocumentPreview(context)),
          ],
        );
      },
    );
"@
$content = $content -replace "(?s)      return Row\(\r?\n        children: \[\r?\n          // Left: Form\r?\n          Expanded\(child: formWidget\),\r?\n          // Right: Document Preview\r?\n          Expanded\(\r?\n            child: _buildDocumentPreview\(context\),\r?\n          \),\r?\n        \],\r?\n      \);", $newSplit
Set-Content "lib\presentation\screens\applications\application_form_screen.dart" -Value $content -Encoding UTF8
