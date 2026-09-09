import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';
import '../../data/database/app_database.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    _loadLocale();
    return null;
  }

  Future<void> _loadLocale() async {
    final settingsDao = ref.read(databaseProvider).settingsDao;
    final lang = await settingsDao.getSettingByKey('app_language');
    if (lang != null && lang.value.isNotEmpty) {
      state = Locale(lang.value);
    } else {
      // Default behavior (system locale)
      state = null;
    }
  }

  Future<void> setLocale(String languageCode) async {
    final settingsDao = ref.read(databaseProvider).settingsDao;
    await settingsDao.insertOrUpdateSetting(
      Setting(key: 'app_language', value: languageCode),
    );
    state = Locale(languageCode);
  }

  Future<void> clearLocale() async {
    final settingsDao = ref.read(databaseProvider).settingsDao;
    await settingsDao.insertOrUpdateSetting(
      Setting(key: 'app_language', value: ''),
    );
    state = null;
  }
}
