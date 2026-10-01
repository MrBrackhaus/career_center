import 'dart:io';

import 'package:career_center/data/database/db_key_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class _MemoryStore implements DbKeyStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

void _createDb(File file, {String? key}) {
  final db = sqlite3.open(file.path);
  if (key != null) db.execute("PRAGMA key = '$key';");
  db.execute('CREATE TABLE t (v TEXT);');
  db.execute("INSERT INTO t (v) VALUES ('daten');");
  db.close();
}

void main() {
  late Directory tempDir;
  late File dbFile;
  late _MemoryStore store;
  late DbKeyService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('db_key_service_test');
    dbFile = File(p.join(tempDir.path, 'career_center.sqlite'));
    store = _MemoryStore();
    service = DbKeyService(
      store: store,
      clock: () => DateTime(2026, 10, 1, 12, 30, 15),
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('obtainKeyForDatabase', () {
    test('returns the stored key unchanged', () async {
      store.values[DbKeyService.storageKey] = 'vorhanden';
      _createDb(dbFile, key: 'vorhanden');

      expect(await service.obtainKeyForDatabase(dbFile), 'vorhanden');
      expect(dbFile.existsSync(), isTrue);
      expect(DbKeyService.findLockedDatabases(dbFile), isEmpty);
    });

    test('generates and stores a key when no database exists', () async {
      final key = await service.obtainKeyForDatabase(dbFile);

      expect(key, isNotEmpty);
      expect(store.values[DbKeyService.storageKey], key);
      expect(DbKeyService.findLockedDatabases(dbFile), isEmpty);
    });

    test('keeps a plaintext database in place (it gets migrated)', () async {
      _createDb(dbFile);

      final key = await service.obtainKeyForDatabase(dbFile);

      expect(key, isNotEmpty);
      expect(dbFile.existsSync(), isTrue);
      expect(DbKeyService.findLockedDatabases(dbFile), isEmpty);
    });

    test('moves an encrypted database aside instead of overwriting it',
        () async {
      _createDb(dbFile, key: 'verlorener-schluessel');
      File('${dbFile.path}-wal').writeAsStringSync('wal');
      final originalBytes = dbFile.readAsBytesSync();

      final key = await service.obtainKeyForDatabase(dbFile);

      expect(key, isNot('verlorener-schluessel'));
      expect(store.values[DbKeyService.storageKey], key);
      expect(dbFile.existsSync(), isFalse);
      expect(File('${dbFile.path}-wal').existsSync(), isFalse);

      final locked = DbKeyService.findLockedDatabases(dbFile);
      expect(locked, hasLength(1));
      expect(p.basename(locked.single.path),
          startsWith('career_center.sqlite.locked-2026-10-01T12-30-15'));
      expect(locked.single.readAsBytesSync(), originalBytes);
      expect(File('${locked.single.path}-wal').existsSync(), isTrue);
      // The old database is still readable with the old key.
      expect(DbKeyService.opensWithKey(locked.single, 'verlorener-schluessel'),
          isTrue);
    });

    test('does not overwrite an existing locked file', () async {
      _createDb(dbFile, key: 'a');
      await service.obtainKeyForDatabase(dbFile);
      store.values.clear();
      _createDb(dbFile, key: 'b');
      await service.obtainKeyForDatabase(dbFile);

      expect(DbKeyService.findLockedDatabases(dbFile), hasLength(2));
    });
  });

  group('checkBackup', () {
    test('detects plaintext backups', () {
      final backup = File(p.join(tempDir.path, 'backup.sqlite'));
      _createDb(backup);
      expect(DbKeyService.checkBackup(backup, 'egal'), BackupKeyStatus.plaintext);
    });

    test('detects backups encrypted with the current key', () {
      final backup = File(p.join(tempDir.path, 'backup.sqlite'));
      _createDb(backup, key: 'aktuell');
      expect(DbKeyService.checkBackup(backup, 'aktuell'),
          BackupKeyStatus.currentKey);
    });

    test('detects backups encrypted with another key', () {
      final backup = File(p.join(tempDir.path, 'backup.sqlite'));
      _createDb(backup, key: 'anderer');
      expect(DbKeyService.checkBackup(backup, 'aktuell'),
          BackupKeyStatus.otherKey);
      expect(DbKeyService.checkBackup(backup, null), BackupKeyStatus.otherKey);
      expect(DbKeyService.opensWithKey(backup, 'anderer'), isTrue);
      expect(DbKeyService.opensWithKey(backup, "it's falsch"), isFalse);
    });

    test('opensWithKey does not create missing files', () {
      final missing = File(p.join(tempDir.path, 'fehlt.sqlite'));
      expect(DbKeyService.opensWithKey(missing, 'x'), isFalse);
      expect(missing.existsSync(), isFalse);
    });
  });

  test('readKey / writeKey round trip', () async {
    expect(await service.readKey(), isNull);
    await service.writeKey('neu');
    expect(await service.readKey(), 'neu');
  });
}
