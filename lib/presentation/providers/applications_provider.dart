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
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

final applicationsProvider = StreamProvider<List<Application>>((ref) {
  final repository = ref.watch(applicationsRepositoryProvider);
  return repository.watchAllApplications();
});

final applicationByIdProvider = FutureProvider.family<Application, int>((ref, id) async {
  final repository = ref.watch(applicationsRepositoryProvider);
  return await repository.getApplicationById(id);
});

// A simple state notifier to handle adding/updating without returning streams
class ApplicationNotifier {
  final Ref _ref;

  ApplicationNotifier(this._ref);

  Future<int> addApplication(ApplicationsCompanion app) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    return await repository.addApplication(app);
  }

  Future<void> updateApplication(ApplicationsCompanion app) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    await repository.updateApplication(app);
  }
  
  Future<void> deleteApplication(Application app) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    await repository.deleteApplication(app);
  }
}

final applicationNotifierProvider = Provider<ApplicationNotifier>((ref) {
  return ApplicationNotifier(ref);
});

