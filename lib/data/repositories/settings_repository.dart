import '../database/app_database.dart';
import '../../domain/entities/setting_entity.dart';

class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  Future<List<SettingEntity>> getAllSettings() async {
    final list = await _db.settingsDao.getAllSettings();
    return list.map((s) => SettingEntity(key: s.key, value: s.value)).toList();
  }

  Stream<List<SettingEntity>> watchAllSettings() {
    return _db.settingsDao.watchAllSettings().map((list) => list.map((s) => SettingEntity(key: s.key, value: s.value)).toList());
  }

  Future<SettingEntity?> getSettingByKey(String key) async {
    final s = await _db.settingsDao.getSettingByKey(key);
    if (s == null) return null;
    return SettingEntity(key: s.key, value: s.value);
  }

  Future<void> insertOrUpdateSetting(SettingEntity setting) async {
    await _db.settingsDao.insertOrUpdateSetting(Setting(key: setting.key, value: setting.value));
  }
}