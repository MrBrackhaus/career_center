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

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<List<Setting>> getAllSettings() => select(settings).get();

  Stream<List<Setting>> watchAllSettings() => select(settings).watch();

  Future<Setting?> getSettingByKey(String key) {
    return (select(
      settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
  }

  Future<void> insertOrUpdateSetting(Setting setting) {
    return into(settings).insertOnConflictUpdate(setting);
  }
}
