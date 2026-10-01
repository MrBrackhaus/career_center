import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Verwaltet den Ablageort für Bewerbungsdokumente.
///
/// Neue Dateien landen in `<ApplicationSupport>/documents` (nicht im
/// Benutzer-Dokumente-Ordner, der unter Windows oft per OneDrive
/// synchronisiert wird). Ältere Einträge behalten ihre absoluten Pfade in
/// den früheren Ordnern `jobtracker_docs` bzw. `career_center_docs`.
class DocumentStorageService {
  static const String folderName = 'documents';
  static const List<String> legacyFolderNames = [
    'jobtracker_docs',
    'career_center_docs',
  ];

  /// Ordner für neue Dokumente (wird bei Bedarf angelegt).
  static Future<Directory> documentsDirectory() async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Alle Ordner, die von der App verwaltet werden (neu + Altbestand).
  static Future<List<String>> managedRoots() async {
    final roots = <String>[];
    try {
      final support = await getApplicationSupportDirectory();
      roots.add(p.join(support.path, folderName));
    } catch (_) {}
    try {
      final docs = await getApplicationDocumentsDirectory();
      for (final legacy in legacyFolderNames) {
        roots.add(p.join(docs.path, legacy));
      }
    } catch (_) {}
    return roots;
  }

  /// Erzeugt einen eindeutigen Dateinamen mit Zeitstempel-Präfix.
  static String uniqueFileName(String originalName, {DateTime? now}) {
    final base = p.basename(originalName);
    final safe = base.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_');
    final ts = (now ?? DateTime.now()).microsecondsSinceEpoch;
    return '${ts}_$safe';
  }

  /// Kopiert [sourcePath] in den Dokumente-Ordner und gibt den neuen Pfad
  /// zurück.
  static Future<String> importFile(String sourcePath) async {
    final dir = await documentsDirectory();
    final target = p.join(dir.path, uniqueFileName(sourcePath));
    await File(sourcePath).copy(target);
    return target;
  }

  /// Schreibt [bytes] als neue Datei in den Dokumente-Ordner.
  static Future<String> writeBytes(List<int> bytes, String fileName) async {
    final dir = await documentsDirectory();
    final target = p.join(dir.path, uniqueFileName(fileName));
    await File(target).writeAsBytes(bytes, flush: true);
    return target;
  }

  /// Prüft rein über Pfade, ob [filePath] innerhalb eines der [roots] liegt.
  static bool isInsideAnyRoot(String filePath, List<String> roots) {
    final normalized = p.normalize(p.absolute(filePath));
    for (final root in roots) {
      final r = p.normalize(p.absolute(root));
      if (p.isWithin(r, normalized)) return true;
      if (Platform.isWindows &&
          p.isWithin(r.toLowerCase(), normalized.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  /// Löscht die Datei, sofern sie in einem App-eigenen Ordner liegt.
  /// Gibt `true` zurück, wenn eine Datei gelöscht wurde.
  static Future<bool> deleteManagedFile(String filePath) async {
    final roots = await managedRoots();
    if (!isInsideAnyRoot(filePath, roots)) return false;
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }
}
