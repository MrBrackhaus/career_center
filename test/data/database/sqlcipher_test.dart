import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Verifies that the native SQLite library bundled via the `sqlite3` build
/// hook is SQLCipher (configured in pubspec.yaml under
/// `hooks: user_defines: sqlite3: source: sqlcipher`).
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqlcipher_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('bundled sqlite3 is SQLCipher (cipher_version non-empty)', () {
    final db = sqlite3.openInMemory();
    addTearDown(db.close);
    final rows = db.select('PRAGMA cipher_version;');
    expect(rows, isNotEmpty);
    expect((rows.first.values.first as String?) ?? '', isNotEmpty);
  });

  test('NativeDatabase with PRAGMA key writes an encrypted file', () async {
    final file = File(p.join(tempDir.path, 'enc.sqlite'));
    final db = DatabaseConnection(
      NativeDatabase(
        file,
        setup: (raw) => raw.execute("PRAGMA key = 'test-key';"),
      ),
    );
    final executor = db.executor;
    await executor.ensureOpen(_NoopUser());

    final version = await executor.runSelect('PRAGMA cipher_version;', []);
    expect(version, isNotEmpty);
    expect(version.first.values.first.toString(), isNotEmpty);

    await executor.runCustom('CREATE TABLE t (v TEXT);');
    await executor.runInsert('INSERT INTO t (v) VALUES (?);', ['geheim']);
    await executor.close();

    final header = String.fromCharCodes(
      file.readAsBytesSync().take(16),
    );
    expect(header.startsWith('SQLite format 3'), isFalse);

    // Opening without the key must fail, with the key must succeed.
    final noKey = sqlite3.open(file.path);
    expect(() => noKey.select('SELECT * FROM t;'), throwsA(isA<SqliteException>()));
    noKey.close();

    final withKey = sqlite3.open(file.path);
    withKey.execute("PRAGMA key = 'test-key';");
    expect(withKey.select('SELECT v FROM t;').first['v'], 'geheim');
    withKey.close();
  });
}

class _NoopUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(QueryExecutor executor, OpeningDetails details) async {}
}
