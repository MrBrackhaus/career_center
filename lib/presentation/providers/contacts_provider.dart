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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../data/database/app_database.dart';
import 'database_provider.dart';

final contactsProvider = StreamProvider.family.autoDispose<List<Contact>, int>((
  ref,
  applicationId,
) {
  return ref
      .watch(databaseProvider)
      .contactsDao
      .watchContactsForApplication(applicationId);
});

class ContactsNotifier extends Notifier<AsyncValue<void>> {
  final int applicationId;
  ContactsNotifier(this.applicationId);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addContact(
    String? name,
    String? email,
    String? phone,
    String? role,
  ) async {
    final db = ref.read(databaseProvider);
    await db.contactsDao.insertContact(
      ContactsCompanion.insert(
        applicationId: applicationId,
        name: drift.Value(name),
        email: drift.Value(email),
        phone: drift.Value(phone),
        role: drift.Value(role),
      ),
    );
  }

  Future<void> updateContact(Contact contact) async {
    final db = ref.read(databaseProvider);
    await db.contactsDao.updateContact(contact.toCompanion(true));
  }

  Future<void> deleteContact(int id) async {
    final db = ref.read(databaseProvider);
    await db.contactsDao.deleteContact(id);
  }
}

final contactsNotifierProvider = NotifierProvider.autoDispose
    .family<ContactsNotifier, AsyncValue<void>, int>(
      (id) => ContactsNotifier(id),
    );
