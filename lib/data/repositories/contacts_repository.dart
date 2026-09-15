import '../database/app_database.dart';
import '../../domain/entities/contact_entity.dart';
import '../mappers/drift_mappers.dart';
import 'package:drift/drift.dart' as drift;

class ContactsRepository {
  final AppDatabase _db;
  ContactsRepository(this._db);

  Stream<List<ContactEntity>> watchContactsForApplication(int applicationId) {
    return _db.contactsDao.watchContactsForApplication(applicationId).map(
      (list) => list.map((c) => c.toEntity()).toList()
    );
  }

  Future<void> addContact(int applicationId, String? name, String? email, String? phone, String? role) async {
    await _db.contactsDao.insertContact(
      ContactsCompanion.insert(
        applicationId: applicationId,
        name: drift.Value(name),
        email: drift.Value(email),
        phone: drift.Value(phone),
        role: drift.Value(role),
      )
    );
  }

  Future<void> updateContact(ContactEntity contact) async {
    await _db.contactsDao.updateContact(contact.toCompanion(true));
  }

  Future<void> deleteContact(int id) async {
    await _db.contactsDao.deleteContact(id);
  }
}
