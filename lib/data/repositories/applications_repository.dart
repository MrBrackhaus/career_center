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
import '../database/app_database.dart';
import '../database/daos/applications_dao.dart';

class ApplicationsRepository {
  final ApplicationsDao _dao;

  ApplicationsRepository(this._dao);

  Stream<List<Application>> watchAllApplications() {
    return _dao.watchAllApplications();
  }

  Future<List<Application>> getAllApplications() {
    return _dao.getAllApplications();
  }

  Future<Application> getApplicationById(int id) {
    return _dao.getApplicationById(id);
  }

  Future<void> addApplication(ApplicationsCompanion app) async {
    await _dao.insertApplication(app);
  }

  Future<void> updateApplication(ApplicationsCompanion app) async {
    await _dao.updateApplication(app);
  }

  Future<void> deleteApplication(Application app) async {
    await _dao.deleteApplication(app);
  }
}

