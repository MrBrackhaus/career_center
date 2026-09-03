path = 'lib/presentation/screens/applications/application_form_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

old_code = """              Expanded(
                child: PdfViewer.data(
                  _loadedPdfBytes!,
                  sourceName: 'upload.pdf',
                ),
              ),"""

new_code = """              Expanded(
                child: PdfViewer.data(
                  _loadedPdfBytes!,
                  sourceName: 'upload.pdf',
                  params: PdfViewerParams(
                    textSelectionParams: PdfTextSelectionParams(
                      onTextSelectionChange: (selection) async {
                        if (selection != null && selection.hasSelectedText) {
                          final selectedText = await selection.getSelectedText();
                          if (selectedText.isNotEmpty && _activeMarkerField != null) {
                            _applyMarkerText(selectedText);
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),"""

if old_code in text:
    text = text.replace(old_code, new_code)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Fixed PdfViewer!")
else:
    print("Could not find PdfViewer snippet.")
