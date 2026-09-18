import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';
import '../../domain/entities/setting_entity.dart';

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
    final settingsDao = ref.read(settingsRepositoryProvider);
    final lang = await settingsDao.getSettingByKey('app_language');
    if (lang != null && lang.value.isNotEmpty) {
      state = Locale(lang.value);
    } else {
      // Default behavior (force German as default since this is a German app)
      state = const Locale('de');
    }
  }

  Future<void> setLocale(String languageCode) async {
    final settingsDao = ref.read(settingsRepositoryProvider);
    await settingsDao.insertOrUpdateSetting(
      SettingEntity(key: 'app_language', value: languageCode),
    );
    state = Locale(languageCode);
  }

  Future<void> clearLocale() async {
    final settingsDao = ref.read(settingsRepositoryProvider);
    await settingsDao.insertOrUpdateSetting(
      SettingEntity(key: 'app_language', value: ''),
    );
    state = null;
  }
}
