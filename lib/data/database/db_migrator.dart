import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

const _plaintextHeader = 'SQLite format 3';

/// Suffix of the backup that keeps the original, unencrypted database until
/// the encrypted copy has been verified.
const unencryptedBackupSuffix = '.unencrypted.bak';

/// Escapes [value] for use inside a single-quoted SQL string literal.
String escapeSqlString(String value) => value.replaceAll("'", "''");

/// Returns `true` if [file] exists and starts with the plaintext SQLite
/// header. Only the first 16 bytes are read.
bool isPlaintextSqlite(File file) {
  if (!file.existsSync()) return false;
  final raf = file.openSync();
  try {
    final bytes = raf.readSync(16);
    if (bytes.length < 16) return false;
    return String.fromCharCodes(bytes).startsWith(_plaintextHeader);
  } finally {
    raf.closeSync();
  }
}

/// Deletes the SQLite side files (`-journal`, `-wal`, `-shm`) of [path].
void _deleteSideFiles(String path) {
  for (final suffix in const ['-journal', '-wal', '-shm']) {
    final f = File('$path$suffix');
    if (f.existsSync()) f.deleteSync();
  }
}

void _deleteWithSideFiles(File file) {
  if (file.existsSync()) file.deleteSync();
  _deleteSideFiles(file.path);
}

/// Returns `true` if [file] can be opened and read with [encryptionKey].
bool _opensWithKey(File file, String encryptionKey) {
  if (!file.existsSync() || isPlaintextSqlite(file)) return false;
  Database? db;
  try {
    db = sqlite3.open(file.path);
    db.execute("PRAGMA key = '${escapeSqlString(encryptionKey)}';");
    db.select('SELECT count(*) FROM sqlite_master;');
    return true;
  } catch (e) {
    log('Encrypted database ${file.path} could not be opened: $e',
        name: 'db_migrator', level: 1000);
    return false;
  } finally {
    db?.close();
  }
}

/// Encrypts an existing plaintext database [file] in place with SQLCipher.
///
/// The original file is kept as `<file>.unencrypted.bak` until the encrypted
/// copy has been moved into place and verified, so an interruption at any
/// point never loses data. Returns `true` if the file was migrated.
bool migrateToEncryptedIfNecessary(File file, String encryptionKey) {
  final backup = File('${file.path}$unencryptedBackupSuffix');

  // Recover from an interrupted earlier run.
  if (backup.existsSync()) {
    if (!file.existsSync()) {
      log('Restoring unencrypted backup after interrupted migration',
          name: 'db_migrator', level: 900);
      backup.renameSync(file.path);
    } else if (_opensWithKey(file, encryptionKey)) {
      // Rename succeeded last time, only the cleanup was missing.
      backup.deleteSync();
      return false;
    } else if (!isPlaintextSqlite(file)) {
      // The target is neither plaintext nor readable with our key: it is a
      // broken half-migrated file. The backup is the source of truth.
      log('Encrypted database unreadable, restoring unencrypted backup',
          name: 'db_migrator', level: 900);
      _deleteWithSideFiles(file);
      backup.renameSync(file.path);
    }
  }

  if (!isPlaintextSqlite(file)) return false;

  final tempFile = File(p.join(file.parent.path, 'temp_encrypted.sqlite'));
  _deleteWithSideFiles(tempFile);

  final key = escapeSqlString(encryptionKey);
  final tempPath = escapeSqlString(tempFile.path);

  // Opening the plaintext DB rolls back a hot -journal or replays a -wal, so
  // their content ends up in the export.
  final unencryptedDb = sqlite3.open(file.path);
  try {
    unencryptedDb.execute(
        "ATTACH DATABASE '$tempPath' AS encrypted KEY '$key';");
    unencryptedDb.execute("SELECT sqlcipher_export('encrypted');");
    unencryptedDb.execute('DETACH DATABASE encrypted;');
  } catch (e, st) {
    log('SQLCipher export failed (SQLCipher not available?): $e',
        name: 'db_migrator', level: 1000, error: e, stackTrace: st);
    unencryptedDb.close();
    _deleteWithSideFiles(tempFile);
    return false;
  }
  unencryptedDb.close();

  if (!_opensWithKey(tempFile, encryptionKey)) {
    _deleteWithSideFiles(tempFile);
    return false;
  }

  // Keep the original until the encrypted copy is in place and verified.
  if (backup.existsSync()) backup.deleteSync();
  file.renameSync(backup.path);
  // Leftover plaintext -wal/-journal files must not be applied to the
  // encrypted database (their content is already part of the export).
  _deleteSideFiles(file.path);
  try {
    tempFile.renameSync(file.path);
  } catch (e) {
    log('Could not move encrypted database into place: $e',
        name: 'db_migrator', level: 1000);
    backup.renameSync(file.path);
    _deleteWithSideFiles(tempFile);
    return false;
  }

  if (_opensWithKey(file, encryptionKey)) {
    backup.deleteSync();
    return true;
  }

  // Should not happen as the temp file was verified – roll back.
  log('Encrypted database failed verification, restoring original',
      name: 'db_migrator', level: 1000);
  _deleteWithSideFiles(file);
  backup.renameSync(file.path);
  return false;
}
