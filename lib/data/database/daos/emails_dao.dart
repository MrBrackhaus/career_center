/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:drift/drift.dart';

import '../app_database.dart';

part 'emails_dao.g.dart';

@DriftAccessor(tables: [Emails])
class EmailsDao extends DatabaseAccessor<AppDatabase> with _$EmailsDaoMixin {
  EmailsDao(super.db);

  Future<List<Email>> getEmailsForApplication(int applicationId) {
    return (select(emails)
          ..where((e) => e.applicationId.equals(applicationId))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.receivedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  Stream<List<Email>> watchEmailsForApplication(int applicationId) {
    return (select(emails)
          ..where((e) => e.applicationId.equals(applicationId))
          ..orderBy([
            (e) =>
                OrderingTerm(expression: e.receivedAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<void> insertEmail(EmailsCompanion email) {
    return into(emails).insert(email, mode: InsertMode.insertOrIgnore);
  }

  Future<Email?> getEmailByMessageId(String messageId) {
    return (select(
      emails,
    )..where((e) => e.messageId.equals(messageId))).getSingleOrNull();
  }

  Future<List<Email>> getAllEmails() {
    return select(emails).get();
  }

  Stream<List<Email>> watchAllEmails() {
    return select(emails).watch();
  }
}
