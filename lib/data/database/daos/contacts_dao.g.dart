// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contacts_dao.dart';

// ignore_for_file: type=lint
mixin _$ContactsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ApplicationsTable get applications => attachedDatabase.applications;
  $ContactsTable get contacts => attachedDatabase.contacts;
  ContactsDaoManager get managers => ContactsDaoManager(this);
}

class ContactsDaoManager {
  final _$ContactsDaoMixin _db;
  ContactsDaoManager(this._db);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db.attachedDatabase, _db.applications);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db.attachedDatabase, _db.contacts);
}
