import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import 'package:career_center/data/database/db_migrator.dart';

void main() {
  group('Database Migrator', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('db_migrator_test');
      dbFile = File(p.join(tempDir.path, 'test_db.sqlite'));
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('migrateToEncryptedIfNecessary catches exception when SQLCipher is missing', () {
      // Create a valid unencrypted sqlite3 database
      final db = sqlite3.open(dbFile.path);
      db.execute('CREATE TABLE dummy (id INTEGER PRIMARY KEY);');
      db.close();

      // Read the header to ensure it starts with "SQLite format 3"
      final bytes = dbFile.readAsBytesSync();
      final header = String.fromCharCodes(bytes.take(16));
      expect(header.startsWith('SQLite format 3'), isTrue);

      // Call the migrator. Since standard sqlite3 used in tests 
      // doesn't have sqlcipher_export, it should throw, but our migrator 
      // is patched to catch it and return false, leaving the DB unencrypted.
      final result = migrateToEncryptedIfNecessary(dbFile, 'test_key');
      
      expect(result, isFalse, reason: 'Should return false when SQLCipher fails gracefully');
      expect(dbFile.existsSync(), isTrue, reason: 'Original DB file should still exist');
    });
  });
}
