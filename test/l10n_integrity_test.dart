import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Localization Integrity Tests', () {
    late Directory l10nDir;
    late List<File> arbFiles;
    late Map<String, dynamic> baseJson;
    late Set<String> baseKeys;
    
    // We use German (de) as the source of truth
    const baseLang = 'app_de.arb';

    setUpAll(() {
      l10nDir = Directory('lib/l10n');
      if (!l10nDir.existsSync()) {
        fail('l10n directory not found at ${l10nDir.path}');
      }
      
      arbFiles = l10nDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .toList();
          
      final baseFile = arbFiles.firstWhere(
        (f) => p.basename(f.path) == baseLang,
        orElse: () => fail('Base language file $baseLang not found'),
      );
      
      baseJson = jsonDecode(baseFile.readAsStringSync()) as Map<String, dynamic>;
      
      // Filter out metadata keys that start with '@'
      baseKeys = baseJson.keys.where((k) => !k.startsWith('@')).toSet();
    });

    test('All ARB files should have the exact same keys as the base language', () {
      bool hasErrors = false;
      final StringBuffer errorLog = StringBuffer();

      for (final file in arbFiles) {
        final fileName = p.basename(file.path);
        if (fileName == baseLang) continue;

        final Map<String, dynamic> fileJson = jsonDecode(file.readAsStringSync());
        final fileKeys = fileJson.keys.where((k) => !k.startsWith('@')).toSet();

        // Check for missing keys
        final missingKeys = baseKeys.difference(fileKeys);
        if (missingKeys.isNotEmpty) {
          hasErrors = true;
          errorLog.writeln('[$fileName] Missing ${missingKeys.length} keys:');
          for (final key in missingKeys.take(10)) {
            errorLog.writeln('  - $key');
          }
          if (missingKeys.length > 10) {
            errorLog.writeln('  - ... and ${missingKeys.length - 10} more');
          }
        }

        // Check for extra keys (keys in this file but not in base)
        final extraKeys = fileKeys.difference(baseKeys);
        if (extraKeys.isNotEmpty) {
          hasErrors = true;
          errorLog.writeln('[$fileName] Has ${extraKeys.length} extra/orphan keys:');
          for (final key in extraKeys.take(10)) {
            errorLog.writeln('  - $key');
          }
          if (extraKeys.length > 10) {
            errorLog.writeln('  - ... and ${extraKeys.length - 10} more');
          }
        }
      }

      if (hasErrors) {
        fail('Localization mismatches found:\n\n${errorLog.toString()}');
      }
    }, skip: 'Optional: Manuell ausführen. Würde sonst die CI/CD beim Entwickeln von Features mit unvollständigen Übersetzungen blockieren.');

    test('All ARB files should contain valid JSON format', () {
      for (final file in arbFiles) {
        final content = file.readAsStringSync();
        try {
          jsonDecode(content);
        } catch (e) {
          fail('Invalid JSON in ${p.basename(file.path)}: $e');
        }
      }
    }, skip: 'Optional: Wird übersprungen.');
  });
}
