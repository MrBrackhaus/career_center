import 'dart:io';
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

part 'app_database.g.dart';

class Applications extends Table {
  IntColumn get id            => integer().autoIncrement()();
  TextColumn get company      => text()();
  TextColumn get position     => text()();
  TextColumn get address      => text().nullable()();
  TextColumn get industry     => text().nullable()();
  TextColumn get contactName  => text().nullable()();
  TextColumn get contactEmail => text().nullable()();
  TextColumn get contactPhone => text().nullable()();
  TextColumn get status       => text().withDefault(const Constant('offen'))();
  IntColumn  get priority     => integer().withDefault(const Constant(2))();
  DateTimeColumn get appliedDate   => dateTime().nullable()();
  DateTimeColumn get responseDate  => dateTime().nullable()();
  DateTimeColumn get followupDate  => dateTime().nullable()();
  IntColumn  get commuteCar        => integer().nullable()(); // Minuten
  IntColumn  get commuteTransit    => integer().nullable()();
  IntColumn  get salaryWish        => integer().nullable()();
  IntColumn  get salaryOffered     => integer().nullable()();
  TextColumn get nextStep          => text().nullable()();
  TextColumn get notes             => text().nullable()();
  TextColumn get rejectionReason   => text().nullable()();
  TextColumn get jobUrl            => text().nullable()();
  TextColumn get companyUrl        => text().nullable()();
  TextColumn get customFields      => text().nullable()(); // JSON string for dynamic columns
  TextColumn get coverLetterContent => text().nullable()(); // JSON string for Quill document
  TextColumn get jobDescriptionText => text().nullable()(); // Plain text for ATS analysis
  DateTimeColumn get createdAt     => dateTime().nullable()();
  DateTimeColumn get updatedAt     => dateTime().nullable()();
}

class Templates extends Table {
  IntColumn  get id        => integer().autoIncrement()();
  TextColumn get name      => text()();
  TextColumn get type      => text()(); // anschreiben | textbaustein | lebenslauf
  TextColumn get content   => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

class Settings extends Table {
  TextColumn get key   => text()();
  TextColumn get value => text()();
  
  @override
  Set<Column> get primaryKey => {key};
}

class Emails extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id)();
  TextColumn get messageId => text()(); // IMAP UID or Message-ID
  TextColumn get subject => text()();
  TextColumn get sender => text()();
  TextColumn get bodySnippet => text()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

class Notes extends Table {
  IntColumn get id            => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id)();
  TextColumn get content      => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}

class Documents extends Table {
  IntColumn get id            => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id)();
  TextColumn get fileName     => text()();
  TextColumn get filePath     => text()(); // absolute path in AppDocuments
  TextColumn get fileType     => text()(); // pdf, docx, other
  DateTimeColumn get uploadedAt => dateTime().nullable()();
}

class Contacts extends Table {
  IntColumn get id            => integer().autoIncrement()();
  IntColumn get applicationId => integer().references(Applications, #id)();
  TextColumn get name         => text().nullable()();
  TextColumn get email        => text().nullable()();
  TextColumn get phone        => text().nullable()();
  TextColumn get role         => text().nullable()(); // e.g. "HR-Managerin", "Recruiter"
}

@DriftDatabase(
  tables: [Applications, Templates, Settings, Emails, Notes, Documents, Contacts],
  daos: [ApplicationsDao, TemplatesDao, SettingsDao, EmailsDao, NotesDao, DocumentsDao, ContactsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  EmailsDao get emailsDao => EmailsDao(this);
  NotesDao get notesDao => NotesDao(this);
  DocumentsDao get documentsDao => DocumentsDao(this);
  ContactsDao get contactsDao => ContactsDao(this);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(applications, applications.customFields);
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
          await m.addColumn(applications, applications.coverLetterContent);
          await m.addColumn(applications, applications.jobDescriptionText);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'career_center.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}


