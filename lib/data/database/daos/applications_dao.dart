/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:drift/drift.dart';

import '../app_database.dart';

part 'applications_dao.g.dart';

@DriftAccessor(tables: [Applications])
class ApplicationsDao extends DatabaseAccessor<AppDatabase>
    with _$ApplicationsDaoMixin {
  ApplicationsDao(super.db);

  Future<List<Application>> getAllApplications() => select(applications).get();

  Stream<List<Application>> watchAllApplications() =>
      select(applications).watch();

  Future<Application?> getApplicationById(int id) {
    return (select(applications)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertApplication(Insertable<Application> application) {
    return into(applications).insert(application);
  }

  /// Ersetzt die komplette Zeile (`replace`). Achtung: Bei einem
  /// [ApplicationsCompanion] werden nicht gesetzte Spalten auf ihre
  /// SQL-Defaults zurückgesetzt – für Teil-Updates [partialUpdate] verwenden.
  Future<bool> updateApplication(Insertable<Application> application) {
    if (application is Application) {
      application = application.copyWith(updatedAt: Value(DateTime.now()));
    } else if (application is ApplicationsCompanion) {
      application = application.copyWith(updatedAt: Value(DateTime.now()));
    }
    return update(applications).replace(application);
  }

  Future<int> partialUpdate(int id, ApplicationsCompanion companion) {
    return (update(applications)..where((t) => t.id.equals(id))).write(
      companion.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> deleteApplication(Application application) {
    return delete(applications).delete(application);
  }
}
