import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:career_center/data/database/app_database.dart';

void main() {
  group('Database Migration Tests', () {
    test('Migration von V1 auf V12 läuft ohne Datenverlust', () async {
      // 1. Wir erstellen eine In-Memory SQLite Datenbank (raw)
      final sqliteDb = sqlite3.openInMemory();
      
      // 2. Wir simulieren das exakte Schema von Version 1
      sqliteDb.execute('''
        CREATE TABLE applications (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          company TEXT NOT NULL,
          position TEXT NOT NULL,
          address TEXT,
          industry TEXT,
          contact_name TEXT,
          contact_email TEXT,
          contact_phone TEXT,
          status TEXT NOT NULL DEFAULT 'offen',
          priority INTEGER NOT NULL DEFAULT 2,
          applied_date INTEGER,
          response_date INTEGER,
          followup_date INTEGER,
          commute_car INTEGER,
          commute_transit INTEGER,
          salary_wish INTEGER,
          salary_offered INTEGER,
          next_step TEXT,
          notes TEXT,
          rejection_reason TEXT,
          job_url TEXT,
          company_url TEXT,
          created_at INTEGER,
          updated_at INTEGER
        );
      ''');

      sqliteDb.execute('''
        CREATE TABLE templates (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          content TEXT,
          created_at INTEGER
        );
      ''');

      sqliteDb.execute('''
        CREATE TABLE settings (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL
        );
      ''');

      // Wir schreiben SQLite-User-Version explizit auf 1
      sqliteDb.execute('PRAGMA user_version = 1;');

      // 3. Wir fügen Testdaten in das alte v1 Format ein (Unix Timestamps für Datum)
      sqliteDb.execute('''
        INSERT INTO applications (company, position, status, created_at)
        VALUES ('Test Firma GmbH', 'Flutter Entwickler', 'offen', ${DateTime.now().millisecondsSinceEpoch ~/ 1000});
      ''');

      // 4. Jetzt verbinden wir die Drift AppDatabase mit genau dieser existierenden Connection.
      // Das zwingt Drift dazu, die Migration von 1 auf 12 auszuführen.
      final driftDb = AppDatabase.forTesting(NativeDatabase.opened(sqliteDb));

      // 5. Wenn wir jetzt eine Query ausführen, triggert das die Migration.
      final apps = await driftDb.applicationsDao.getAllApplications();

      // Überprüfen, ob Daten noch da sind
      expect(apps.length, 1);
      final migratedApp = apps.first;
      expect(migratedApp.company, 'Test Firma GmbH');
      expect(migratedApp.position, 'Flutter Entwickler');

      // Überprüfen, ob neue Spalten existieren und (wie erwartet) null sind
      expect(migratedApp.customFields, isNull); // V2
      expect(migratedApp.coverLetterContent, isNull); // V7
      expect(migratedApp.jobDescriptionText, isNull); // V7
      expect(migratedApp.cvContent, isNull); // V11

      // Überprüfen, ob neue Tabellen angelegt wurden (Beispiel: Contacts aus V6)
      final newContactId = await driftDb.contactsDao.insertContact(
        ContactsCompanion.insert(
          applicationId: migratedApp.id,
          name: const Value('Max Mustermann'),
        )
      );
      expect(newContactId, greaterThan(0));

      // Clean up
      await driftDb.close();
    });
  });
}
