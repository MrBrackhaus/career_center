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

part 'contacts_dao.g.dart';

@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase> with _$ContactsDaoMixin {
  ContactsDao(AppDatabase db) : super(db);

  Stream<List<Contact>> watchContactsForApplication(int applicationId) {
    return (select(contacts)
          ..where((c) => c.applicationId.equals(applicationId)))
        .watch();
  }

  Future<List<Contact>> getContactsForApplication(int applicationId) {
    return (select(contacts)..where((c) => c.applicationId.equals(applicationId))).get();
  }

  Future<int> insertContact(ContactsCompanion contact) => into(contacts).insert(contact);
  Future<bool> updateContact(ContactsCompanion contact) => update(contacts).replace(contact);
  Future<void> deleteContact(int id) => (delete(contacts)..where((c) => c.id.equals(id))).go();
}

