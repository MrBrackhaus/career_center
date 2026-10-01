/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
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
