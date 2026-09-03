import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/settings_dao.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final db = ref.watch(databaseProvider);
  return LocaleNotifier(db.settingsDao);
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final SettingsDao _settingsDao;

  LocaleNotifier(this._settingsDao) : super(null) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final lang = await _settingsDao.getSettingByKey('app_language');
    if (lang != null && lang.value.isNotEmpty) {
      state = Locale(lang.value);
    } else {
      // Default behavior (system locale)
      state = null; 
    }
  }

  Future<void> setLocale(String languageCode) async {
    await _settingsDao.insertOrUpdateSetting(Setting(key: 'app_language', value: languageCode));
    state = Locale(languageCode);
  }
  
  Future<void> clearLocale() async {
    await _settingsDao.insertOrUpdateSetting(Setting(key: 'app_language', value: ''));
    state = null;
  }
}


