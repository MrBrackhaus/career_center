path = 'lib/presentation/screens/applications/application_form_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re
pattern = r"child:\s*PdfViewer\.data\(\s*_loadedPdfBytes!,\s*sourceName:\s*'upload\.pdf',\s*\),"

new_code = """child: PdfViewer.data(
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
                ),"""

if re.search(pattern, text):
    text = re.sub(pattern, new_code, text)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Fixed PdfViewer via regex!")
else:
    print("Could not find via regex.")
