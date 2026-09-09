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
}
