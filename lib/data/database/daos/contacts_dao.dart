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

