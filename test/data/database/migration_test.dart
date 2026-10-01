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

    test('Migration von V14 auf V15 entfernt doppelte E-Mails und legt eindeutigen Index an', () async {
      final sqliteDb = sqlite3.openInMemory();

      // 1. Aktuelles Schema anlegen lassen
      final setupDb = AppDatabase.forTesting(
        NativeDatabase.opened(sqliteDb, closeUnderlyingOnClose: false),
      );
      await setupDb.applicationsDao.getAllApplications();
      await setupDb.close();

      // 2. Zustand von V14 simulieren: kein Index, Duplikate vorhanden
      sqliteDb.execute('DROP INDEX IF EXISTS idx_emails_application_message;');
      sqliteDb.execute('PRAGMA user_version = 14;');
      sqliteDb.execute('''
        INSERT INTO applications (id, company, position, status, priority)
        VALUES (1, 'Nordlicht Energie AG', 'Sachbearbeiterin', 'offen', 2),
               (2, 'Muster GmbH', 'Buchhalter', 'offen', 2);
      ''');
      final ts = DateTime(2026, 9, 1).millisecondsSinceEpoch ~/ 1000;
      sqliteDb.execute('''
        INSERT INTO emails (id, application_id, message_id, subject, sender, body_snippet, received_at, is_read, is_sent_by_me)
        VALUES (10, 1, '<abc@mail>', 'Eingangsbestätigung', 'hr@nordlicht.de', 'Danke', $ts, 0, 0),
               (11, 1, '<abc@mail>', 'Eingangsbestätigung (Kopie)', 'hr@nordlicht.de', 'Danke', $ts, 0, 0),
               (12, 1, '<abc@mail>', 'Eingangsbestätigung (Kopie 2)', 'hr@nordlicht.de', 'Danke', $ts, 0, 0),
               (13, 2, '<abc@mail>', 'Gleiche ID, andere Bewerbung', 'hr@muster.de', 'Hallo', $ts, 0, 0),
               (14, 1, '<def@mail>', 'Einladung', 'hr@nordlicht.de', 'Gespräch', $ts, 0, 0);
      ''');

      // 3. Migration 14 → 15 auslösen
      final driftDb = AppDatabase.forTesting(NativeDatabase.opened(sqliteDb));
      final emails = await driftDb.emailsDao.getAllEmails();
      expect(emails.map((e) => e.id).toList()..sort(), [10, 13, 14]);

      // getEmailByMessageId wirft nicht, obwohl die ID mehrfach vorkommt
      final byId = await driftDb.emailsDao.getEmailByMessageId('<abc@mail>');
      expect(byId?.id, 10);

      // Index existiert und verhindert neue Duplikate
      final index = await driftDb.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_emails_application_message'",
      ).get();
      expect(index, hasLength(1));

      await driftDb.emailsDao.insertEmail(EmailsCompanion.insert(
        applicationId: 1,
        messageId: '<abc@mail>',
        subject: 'Nochmal',
        sender: 'hr@nordlicht.de',
        bodySnippet: '',
        receivedAt: DateTime(2026, 9, 2),
      ));
      expect(await driftDb.emailsDao.getEmailsForApplication(1), hasLength(2));

      await driftDb.close();
    });

    test('Migration von V14 auf V15 vereinheitlicht alte Statuswerte', () async {
      final sqliteDb = sqlite3.openInMemory();
      final setupDb = AppDatabase.forTesting(
        NativeDatabase.opened(sqliteDb, closeUnderlyingOnClose: false),
      );
      await setupDb.applicationsDao.getAllApplications();
      await setupDb.close();

      sqliteDb.execute('PRAGMA user_version = 14;');
      sqliteDb.execute('''
        INSERT INTO applications (id, company, position, status, priority)
        VALUES (1, 'A GmbH', 'X', 'bestaetigung', 2),
               (2, 'B GmbH', 'X', 'angebot', 2),
               (3, 'C GmbH', 'X', 'Absage', 2),
               (4, 'D GmbH', 'X', 'Vorstellungsgespräch', 2),
               (5, 'E GmbH', 'X', 'offen', 2);
      ''');

      final driftDb = AppDatabase.forTesting(NativeDatabase.opened(sqliteDb));
      final apps = await driftDb.applicationsDao.getAllApplications();
      final byId = {for (final a in apps) a.id: a.status};
      expect(byId, {
        1: 'versendet',
        2: 'zusage',
        3: 'absage',
        4: 'interview',
        5: 'offen',
      });
      await driftDb.close();
    });

    test('Neue Datenbank hat den eindeutigen E-Mail-Index', () async {
      final driftDb = AppDatabase.forTesting(NativeDatabase.memory());
      final index = await driftDb.customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_emails_application_message'",
      ).get();
      expect(index, hasLength(1));
      await driftDb.close();
    });
  });
}
