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

  /// Liefert die (älteste) E-Mail mit dieser Message-ID.
  ///
  /// Bewusst `get()` statt `getSingleOrNull()`: Dieselbe Message-ID kann
  /// mehreren Bewerbungen zugeordnet sein (oder in Altbeständen doppelt
  /// vorkommen) - das darf nicht zu einer Exception führen.
  Future<Email?> getEmailByMessageId(String messageId) async {
    final rows = await (select(emails)
          ..where((e) => e.messageId.equals(messageId))
          ..orderBy([(e) => OrderingTerm(expression: e.id)])
          ..limit(1))
        .get();
    return rows.firstOrNull;
  }

  Future<List<Email>> getAllEmails() {
    return select(emails).get();
  }

  Stream<List<Email>> watchAllEmails() {
    return select(emails).watch();
  }
}
