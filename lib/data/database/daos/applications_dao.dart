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

part 'applications_dao.g.dart';

@DriftAccessor(tables: [Applications])
class ApplicationsDao extends DatabaseAccessor<AppDatabase> with _$ApplicationsDaoMixin {
  ApplicationsDao(AppDatabase db) : super(db);

  Future<List<Application>> getAllApplications() => select(applications).get();
  
  Stream<List<Application>> watchAllApplications() => select(applications).watch();

  Future<Application> getApplicationById(int id) {
    return (select(applications)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> insertApplication(Insertable<Application> application) {
    return into(applications).insert(application);
  }

  Future<bool> updateApplication(Insertable<Application> application) {
    return update(applications).replace(application);
  }

  Future<int> deleteApplication(Application application) {
    return delete(applications).delete(application);
  }
}

