import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:career_center/data/database/db_migrator.dart';

void main() {
  group('Database Migrator', () {
    late Directory tempDir;
    late File dbFile;
    late File backupFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync("db_migrator_test_O'Brien");
      dbFile = File(p.join(tempDir.path, 'test_db.sqlite'));
      backupFile = File('${dbFile.path}$unencryptedBackupSuffix');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    void createPlainDb() {
      final db = sqlite3.open(dbFile.path);
      db.execute('CREATE TABLE dummy (id INTEGER PRIMARY KEY, v TEXT);');
      db.execute("INSERT INTO dummy (v) VALUES ('Jürgen');");
      db.close();
    }

    List<String> readValues(String key) {
      final db = sqlite3.open(dbFile.path);
      try {
        db.execute("PRAGMA key = '${escapeSqlString(key)}';");
        return [
          for (final row in db.select('SELECT v FROM dummy')) row['v'] as String
        ];
      } finally {
        db.close();
      }
    }

    test('escapeSqlString doubles single quotes', () {
      expect(escapeSqlString("a'b''c"), "a''b''''c");
      expect(escapeSqlString('plain'), 'plain');
    });

    test('isPlaintextSqlite detects header and handles small/missing files', () {
      expect(isPlaintextSqlite(dbFile), isFalse);
      dbFile.writeAsBytesSync([1, 2, 3]);
      expect(isPlaintextSqlite(dbFile), isFalse);
      dbFile.deleteSync();
      createPlainDb();
      expect(isPlaintextSqlite(dbFile), isTrue);
    });

    test('returns false for missing file', () {
      expect(migrateToEncryptedIfNecessary(dbFile, 'k'), isFalse);
    });

    test('encrypts a plaintext DB, keeps data and removes the backup', () {
      createPlainDb();
      // Stale leftovers from an earlier crashed run.
      File(p.join(tempDir.path, 'temp_encrypted.sqlite'))
          .writeAsStringSync('garbage');

      const key = "key-with-'quote'";
      expect(migrateToEncryptedIfNecessary(dbFile, key), isTrue);

      expect(isPlaintextSqlite(dbFile), isFalse);
      expect(backupFile.existsSync(), isFalse);
      expect(File(p.join(tempDir.path, 'temp_encrypted.sqlite')).existsSync(),
          isFalse);
      expect(readValues(key), ['Jürgen']);

      // Second run is a no-op.
      expect(migrateToEncryptedIfNecessary(dbFile, key), isFalse);
      expect(readValues(key), ['Jürgen']);
    });

    test('includes data from a pending WAL file', () {
      final db = sqlite3.open(dbFile.path);
      db.execute('PRAGMA journal_mode = WAL;');
      db.execute('PRAGMA wal_autocheckpoint = 0;');
      db.execute('CREATE TABLE dummy (id INTEGER PRIMARY KEY, v TEXT);');
      db.execute("INSERT INTO dummy (v) VALUES ('aus WAL');");
      // Copy the files while the WAL is still un-checkpointed.
      final snapshot = Directory(p.join(tempDir.path, 'snap'))..createSync();
      final snapDb = File(p.join(snapshot.path, 'test_db.sqlite'));
      dbFile.copySync(snapDb.path);
      File('${dbFile.path}-wal').copySync('${snapDb.path}-wal');
      db.close();

      expect(File('${snapDb.path}-wal').existsSync(), isTrue);
      expect(migrateToEncryptedIfNecessary(snapDb, 'k'), isTrue);
      expect(File('${snapDb.path}-wal').existsSync(), isFalse);

      final enc = sqlite3.open(snapDb.path);
      enc.execute("PRAGMA key = 'k';");
      expect(enc.select('SELECT v FROM dummy').single['v'], 'aus WAL');
      enc.close();
    });

    test('restores backup if a previous run crashed before the rename', () {
      createPlainDb();
      dbFile.renameSync(backupFile.path);

      expect(migrateToEncryptedIfNecessary(dbFile, 'k'), isTrue);
      expect(backupFile.existsSync(), isFalse);
      expect(readValues('k'), ['Jürgen']);
    });

    test('removes leftover backup if encrypted DB is already in place', () {
      createPlainDb();
      backupFile.writeAsBytesSync(dbFile.readAsBytesSync());
      expect(migrateToEncryptedIfNecessary(dbFile, 'k'), isTrue);
      backupFile.writeAsStringSync('old plaintext copy');

      expect(migrateToEncryptedIfNecessary(dbFile, 'k'), isFalse);
      expect(backupFile.existsSync(), isFalse);
      expect(readValues('k'), ['Jürgen']);
    });
  });
}
