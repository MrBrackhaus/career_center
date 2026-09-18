import 'dart:io';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;

bool migrateToEncryptedIfNecessary(File file, String encryptionKey) {
  if (!file.existsSync()) return false;
  
  final bytes = file.readAsBytesSync();
  if (bytes.length < 16) return false;
  
  final header = String.fromCharCodes(bytes.take(16));
  if (header.startsWith('SQLite format 3')) {
    // Es ist unverschlüsselt! Wir migrieren.
    final tempFile = File(p.join(file.parent.path, 'temp_encrypted.sqlite'));
    if (tempFile.existsSync()) tempFile.deleteSync();

    final unencryptedDb = sqlite3.open(file.path);
    unencryptedDb.execute("ATTACH DATABASE '${tempFile.path}' AS encrypted KEY '$encryptionKey';");
    try {
      unencryptedDb.execute("SELECT sqlcipher_export('encrypted');");
    } catch (e) {
      print('SQLCipher export failed (SQLCipher might not be available on this platform): $e');
      unencryptedDb.close();
      if (tempFile.existsSync()) tempFile.deleteSync();
      return false;
    }
    unencryptedDb.execute("DETACH DATABASE encrypted;");
    unencryptedDb.close();

    file.deleteSync();
    tempFile.renameSync(file.path);
    return true;
  }
  return false;
}
