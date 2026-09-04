// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emails_dao.dart';

// ignore_for_file: type=lint
mixin _$EmailsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ApplicationsTable get applications => attachedDatabase.applications;
  $EmailsTable get emails => attachedDatabase.emails;
  EmailsDaoManager get managers => EmailsDaoManager(this);
}

class EmailsDaoManager {
  final _$EmailsDaoMixin _db;
  EmailsDaoManager(this._db);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db.attachedDatabase, _db.applications);
  $$EmailsTableTableManager get emails =>
      $$EmailsTableTableManager(_db.attachedDatabase, _db.emails);
}
