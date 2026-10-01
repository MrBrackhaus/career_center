import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'db_migrator.dart';

/// Minimaler Schlüssel-Wert-Speicher für den Datenbankschlüssel. Erlaubt es,
/// in Tests einen In-Memory-Speicher statt des Secure Storage zu verwenden.
abstract class DbKeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// Produktiv-Implementierung auf Basis von `flutter_secure_storage`.
class SecureDbKeyStore implements DbKeyStore {
  const SecureDbKeyStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

/// Ergebnis der Prüfung einer Backup-Datei gegen den aktuellen Schlüssel.
enum BackupKeyStatus {
  /// Unverschlüsselte SQLite-Datei – wird beim nächsten Start verschlüsselt.
  plaintext,

  /// Lässt sich mit dem aktuellen Schlüssel öffnen.
  currentKey,

  /// Verschlüsselt, aber nicht mit dem aktuellen Schlüssel lesbar.
  otherKey,
}

/// Verwaltet den SQLCipher-Schlüssel der Datenbank (Wiederherstellungsschlüssel).
class DbKeyService {
  DbKeyService({DbKeyStore? store, DateTime Function()? clock})
      : _store = store ?? const SecureDbKeyStore(),
        _clock = clock ?? DateTime.now;

  /// Name des Eintrags im Secure Storage.
  static const storageKey = 'db_encryption_key';

  /// Namensbestandteil für beiseitegelegte, nicht lesbare Datenbanken:
  /// `career_center.sqlite.locked-<timestamp>`.
  static const lockedMarker = '.locked-';

  final DbKeyStore _store;
  final DateTime Function() _clock;

  /// Liest den aktuellen Schlüssel oder `null`, falls keiner gespeichert ist.
  Future<String?> readKey() async {
    final key = await _store.read(storageKey);
    return (key == null || key.isEmpty) ? null : key;
  }

  /// Speichert [key] als neuen Datenbankschlüssel.
  Future<void> writeKey(String key) => _store.write(storageKey, key);

  /// Erzeugt einen zufälligen 256-Bit-Schlüssel (base64url).
  static String generateKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(values);
  }

  /// Liefert den Schlüssel zum Öffnen von [dbFile].
  ///
  /// Ist kein Schlüssel gespeichert, existiert aber bereits eine verschlüsselte
  /// Datenbank, wird diese NICHT überschrieben, sondern nach
  /// `<dbFile>.locked-<timestamp>` umbenannt (inkl. Journal-/WAL-Dateien).
  /// Anschließend wird ein neuer Schlüssel erzeugt und mit einer leeren
  /// Datenbank gestartet. Die beiseitegelegte Datei kann später über
  /// "Backup wiederherstellen" mit dem Wiederherstellungsschlüssel
  /// importiert werden.
  Future<String> obtainKeyForDatabase(File dbFile) async {
    final existing = await readKey();
    if (existing != null) {
      // Gespeicherter Schlüssel passt nicht zur vorhandenen Datei (z. B.
      // andere Installation mit eigenem Secure Storage): Datei beiseitelegen
      // statt mit "file is not a database" zu scheitern.
      if (_isEncryptedDatabase(dbFile) && _isWrongKey(dbFile, existing)) {
        final locked = lockDatabase(dbFile);
        log('Datenbankschlüssel passt nicht – Datenbank wurde nach '
            '${locked.path} verschoben.',
            name: 'db_key_service', level: 1000);
      }
      return existing;
    }

    if (_isEncryptedDatabase(dbFile)) {
      final locked = lockDatabase(dbFile);
      log('Kein Datenbankschlüssel gefunden – verschlüsselte Datenbank wurde '
          'nach ${locked.path} verschoben.',
          name: 'db_key_service', level: 1000);
    }

    final key = generateKey();
    await writeKey(key);
    return key;
  }

  /// `true` nur, wenn SQLCipher die Datei mit [key] eindeutig als
  /// "not a database" ablehnt (SQLITE_NOTADB). Andere Fehler (z. B. eine
  /// gesperrte Datei) führen nie dazu, dass die Datenbank verschoben wird.
  static bool _isWrongKey(File file, String key) {
    Database? db;
    try {
      db = sqlite3.open(file.path, mode: OpenMode.readOnly);
      db.execute("PRAGMA key = '${escapeSqlString(key)}';");
      db.select('SELECT count(*) FROM sqlite_master;');
      return false;
    } on SqliteException catch (e) {
      return e.resultCode == 26 || e.extendedResultCode == 26;
    } catch (_) {
      return false;
    } finally {
      db?.close();
    }
  }

  static bool _isEncryptedDatabase(File file) =>
      file.existsSync() && file.lengthSync() > 0 && !isPlaintextSqlite(file);

  /// Benennt [dbFile] samt Nebendateien in `<dbFile>.locked-<timestamp>` um.
  File lockDatabase(File dbFile) {
    final stamp = _clock()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    var target = File('${dbFile.path}$lockedMarker$stamp');
    var n = 1;
    while (target.existsSync()) {
      target = File('${dbFile.path}$lockedMarker$stamp-$n');
      n++;
    }
    dbFile.renameSync(target.path);
    for (final suffix in const ['-journal', '-wal', '-shm']) {
      final side = File('${dbFile.path}$suffix');
      if (side.existsSync()) side.renameSync('${target.path}$suffix');
    }
    return target;
  }

  /// Alle beiseitegelegten Datenbanken neben [dbFile], neueste zuerst.
  static List<File> findLockedDatabases(File dbFile) {
    final dir = dbFile.parent;
    if (!dir.existsSync()) return const [];
    final prefix = '${p.basename(dbFile.path)}$lockedMarker';
    final result = dir
        .listSync()
        .whereType<File>()
        .where((f) {
          final name = p.basename(f.path);
          return name.startsWith(prefix) &&
              !name.endsWith('-journal') &&
              !name.endsWith('-wal') &&
              !name.endsWith('-shm');
        })
        .toList()
      ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    return result;
  }

  /// `true`, wenn [file] eine verschlüsselte Datenbank ist, die sich mit
  /// [key] öffnen und lesen lässt.
  static bool opensWithKey(File file, String key) {
    if (!file.existsSync() || isPlaintextSqlite(file)) return false;
    Database? db;
    try {
      db = sqlite3.open(file.path, mode: OpenMode.readOnly);
      db.execute("PRAGMA key = '${escapeSqlString(key)}';");
      db.select('SELECT count(*) FROM sqlite_master;');
      return true;
    } catch (_) {
      return false;
    } finally {
      db?.close();
    }
  }

  /// Prüft, ob die Backup-Datei [file] mit [currentKey] geöffnet werden kann.
  static BackupKeyStatus checkBackup(File file, String? currentKey) {
    if (isPlaintextSqlite(file)) return BackupKeyStatus.plaintext;
    if (currentKey != null && opensWithKey(file, currentKey)) {
      return BackupKeyStatus.currentKey;
    }
    return BackupKeyStatus.otherKey;
  }
}
