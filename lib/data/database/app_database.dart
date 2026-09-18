/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'db_migrator.dart';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'daos/applications_dao.dart';
import 'daos/templates_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/emails_dao.dart';
import 'daos/notes_dao.dart';
import 'daos/documents_dao.dart';
import 'daos/contacts_dao.dart';
import 'daos/cv_dao.dart';

part 'app_database.g.dart';

class Applications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get company => text()();
  TextColumn get position => text()();
  TextColumn get address => text().nullable()();
  TextColumn get industry => text().nullable()();
  TextColumn get contactName => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('offen'))();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  DateTimeColumn get appliedDate => dateTime().nullable()();
  DateTimeColumn get responseDate => dateTime().nullable()();
  DateTimeColumn get followupDate => dateTime().nullable()();
  IntColumn get commuteCar => integer().nullable()(); // Minuten
  IntColumn get commuteTransit => integer().nullable()();
  IntColumn get salaryWish => integer().nullable()();
  IntColumn get salaryOffered => integer().nullable()();
  TextColumn get nextStep => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get rejectionReason => text().nullable()();
  TextColumn get jobUrl => text().nullable()();
  TextColumn get companyUrl => text().nullable()();
  TextColumn get customFields =>
      text().nullable()(); // JSON string for dynamic columns
  TextColumn get coverLetterContent =>
      text().nullable()(); // JSON string for Quill document
  TextColumn get cvContent =>
      text().nullable()(); // JSON string for CV Data
  TextColumn get jobDescriptionText =>
      text().nullable()(); // Plain text for ATS analysis
  DateTimeColumn get createdAt => dateTime().nullable().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt => dateTime().nullable().clientDefault(() => DateTime.now())();
}

class Templates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // anschreiben | textbaustein | lebenslauf
  TextColumn get content => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable().clientDefault(() => DateTime.now())();
  IntColumn get applicationId =>
      integer().nullable().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath =>
      text().nullable()(); // NEW: Für originale PDF-Dateien
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Emails extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get messageId => text()(); // IMAP UID or Message-ID
  TextColumn get subject => text()();
  TextColumn get sender => text()();
  TextColumn get bodySnippet => text()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isSentByMe => boolean().withDefault(const Constant(false))();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().nullable().clientDefault(() => DateTime.now())();
}

class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()(); // absolute path in AppDocuments
  TextColumn get fileType => text()(); // pdf, docx, other
  DateTimeColumn get uploadedAt => dateTime().nullable()();
}

class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get role =>
      text().nullable()(); // e.g. "HR-Managerin", "Recruiter"
}

// === NEW CV TABLES ===
class CvWorkExperiences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId => integer().nullable().references(
    Applications,
    #id,
    onDelete: KeyAction.cascade,
  )(); // null = Master-Pool
  TextColumn get company => text()();
  TextColumn get position => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();
  TextColumn get description => text().nullable()();
}

class CvEducations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId =>
      integer().nullable().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get institution => text()();
  TextColumn get degree => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get description => text().nullable()();
}

class CvSkills extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId =>
      integer().nullable().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get level => integer().withDefault(const Constant(3))(); // 1-5
}

class CvLanguages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId =>
      integer().nullable().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get level => text()(); // e.g. "Muttersprache", "B2"
}

class CvCustomItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId =>
      integer().nullable().references(Applications, #id, onDelete: KeyAction.cascade)();
  TextColumn get sectionName => text()(); // e.g. "Zertifikate", "Hobbys"
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get dateRange => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DriftDatabase(
  tables: [
    Applications,
    Templates,
    Settings,
    Emails,
    Notes,
    Documents,
    Contacts,
    CvWorkExperiences,
    CvEducations,
    CvSkills,
    CvLanguages,
    CvCustomItems,
  ],
  daos: [
    ApplicationsDao,
    TemplatesDao,
    SettingsDao,
    EmailsDao,
    NotesDao,
    DocumentsDao,
    ContactsDao,
    CvDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  EmailsDao get emailsDao => EmailsDao(this);
  @override
  NotesDao get notesDao => NotesDao(this);
  @override
  DocumentsDao get documentsDao => DocumentsDao(this);
  @override
  ContactsDao get contactsDao => ContactsDao(this);
  @override
  CvDao get cvDao => CvDao(this);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        // Enable SQLite foreign key constraints (disabled by default)
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          try { await m.addColumn(applications, applications.customFields); } catch (e) { print(e); }
        }
        if (from < 3) {
          await m.createTable(emails);
        }
        if (from < 4) {
          await m.createTable(notes);
        }
        if (from < 5) {
          await m.createTable(documents);
        }
        if (from < 6) {
          await m.createTable(contacts);
        }
        if (from < 7) {
          try { await m.addColumn(applications, applications.coverLetterContent); } catch (e) { print(e); }
          try { await m.addColumn(applications, applications.jobDescriptionText); } catch (e) { print(e); }
        }
        if (from < 8) {
          try { await m.addColumn(templates, templates.applicationId); } catch (e) { print(e); }
        }
        if (from < 9) {
          try { await m.addColumn(templates, templates.filePath); } catch (e) { print(e); }
        }
        if (from < 10) {
          await m.createTable(cvWorkExperiences);
          await m.createTable(cvEducations);
          await m.createTable(cvSkills);
          await m.createTable(cvLanguages);
        }
        if (from < 11) {
          try { await m.addColumn(applications, applications.cvContent); } catch (e) { print(e); }
        }

        if (from < 12) {
          try { await m.addColumn(emails, emails.isSentByMe); } catch (e) { print('isSentByMe already exists'); }
        }
        if (from < 14) {
          try { await m.createTable(cvWorkExperiences); } catch (e) { print(e); }
          try { await m.createTable(cvEducations); } catch (e) { print(e); }
          try { await m.createTable(cvSkills); } catch (e) { print(e); }
          try { await m.createTable(cvLanguages); } catch (e) { print(e); }
          try { await m.createTable(cvCustomItems); } catch (e) { print(e); }
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'career_center.sqlite'));

    const storage = FlutterSecureStorage();
    String? encryptionKey = await storage.read(key: 'db_encryption_key');
    if (encryptionKey == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      encryptionKey = base64UrlEncode(values);
      await storage.write(key: 'db_encryption_key', value: encryptionKey);
    }

    try {
      try {
        migrateToEncryptedIfNecessary(file, encryptionKey!);
      } catch (e, stack) {
        print('Migration failed: $e\n$stack');
      }
      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          db.execute("PRAGMA key = '$encryptionKey';");
        },
      );
    } on Exception catch (_) {
      // If the database file is corrupted, back it up and create a fresh one
      final backupFile = File('${file.path}.backup');
      if (file.existsSync()) {
        file.copySync(backupFile.path);
        file.deleteSync();
      }
      // Try again
      return NativeDatabase.createInBackground(
        file,
        setup: (db) {
          db.execute("PRAGMA key = '$encryptionKey';");
        },
      );
    }
  });
}





