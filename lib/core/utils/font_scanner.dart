import 'dart:io';

class FontScanner {
  static List<String> _installedFonts = [];
  static bool _isLoaded = false;

  /// Lädt asynchron die installierten Systemschriftarten (aktuell optimiert für Windows)
  static Future<void> loadSystemFonts() async {
    if (_isLoaded) return;

    if (Platform.isWindows) {
      try {
        final result = await Process.run('powershell', [
          '-Command',
          'Add-Type -AssemblyName System.Drawing; [System.Drawing.FontFamily]::Families | Select-Object -ExpandProperty Name',
        ]);

        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          _installedFonts = lines
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (e) {
        // Ignoriere Fehler und nutze Fallback
      }
    }
    // Für andere Plattformen (Linux/Mac) könnte man später Erweiterungen hinzufügen

    _isLoaded = true;
  }

  /// Gibt eine Map für den Quill-Editor zurück (Anzeigename -> Schriftartname)
  static Map<String, String> getEditorFontMap() {
    final map = <String, String>{
      'Standard': 'Clear', // Quill's clear formatting option
    };

    // Einige Standard-Fonts ganz oben platzieren, falls sie existieren
    final priorityFonts = [
      'Segoe UI',
      'Calibri',
      'Arial',
      'Times New Roman',
      'Roboto',
      'Verdana',
      'Tahoma',
      'Georgia',
    ];

    for (final font in priorityFonts) {
      if (_installedFonts.contains(font) || !Platform.isWindows) {
        map[font] = font;
      }
    }

    // Füge alle restlichen gefundenen Schriftarten hinzu
    for (final font in _installedFonts) {
      if (!map.containsKey(font)) {
        map[font] = font;
      }
    }

    // Fallback, falls der Powershell-Aufruf fehlgeschlagen ist
    if (_installedFonts.isEmpty) {
      map.addAll({
        'Segoe UI': 'Segoe UI',
        'Calibri': 'Calibri',
        'Arial': 'Arial',
        'Times New Roman': 'Times New Roman',
        'Verdana': 'Verdana',
        'Tahoma': 'Tahoma',
      });
    }

    return map;
  }
}
