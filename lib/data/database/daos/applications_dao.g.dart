// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'applications_dao.dart';

// ignore_for_file: type=lint
mixin _$ApplicationsDaoMixin on DatabaseAccessor<AppDatabase> {
  $ApplicationsTable get applications => attachedDatabase.applications;
  ApplicationsDaoManager get managers => ApplicationsDaoManager(this);
}

class ApplicationsDaoManager {
  final _$ApplicationsDaoMixin _db;
  ApplicationsDaoManager(this._db);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db.attachedDatabase, _db.applications);
}
