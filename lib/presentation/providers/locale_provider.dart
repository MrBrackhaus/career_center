import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';
import '../../domain/entities/setting_entity.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

/// Gespeicherter Wert für "Systemstandard". Ein leerer String wurde früher
/// ebenfalls für "Systemstandard" geschrieben und wird weiterhin so gelesen.
const String kSystemLocaleSentinel = 'system';

/// Bildet den gespeicherten Wert von `app_language` auf eine Locale ab.
///
/// * kein Eintrag (erster Start) → Deutsch (bisheriges Standardverhalten)
/// * `'system'` oder `''` (ältere Versionen) → `null` = Systemsprache
/// * sonst → die gespeicherte Sprache
Locale? localeFromStoredValue(String? stored) {
  if (stored == null) return const Locale('de');
  final value = stored.trim();
  if (value.isEmpty || value == kSystemLocaleSentinel) return null;
  return Locale(value);
}

class LocaleNotifier extends Notifier<Locale?> {
  /// Wird gesetzt, sobald der Nutzer selbst eine Sprache wählt. Das initiale
  /// Laden darf diese Wahl dann nicht mehr überschreiben.
  bool _userChanged = false;

  @override
  Locale? build() {
    _loadLocale();
    return null;
  }

  Future<void> _loadLocale() async {
    try {
      final settingsDao = ref.read(settingsRepositoryProvider);
      final lang = await settingsDao.getSettingByKey('app_language');
      if (!ref.mounted || _userChanged) return;
      state = localeFromStoredValue(lang?.value);
    } catch (e, st) {
      log('Sprache konnte nicht geladen werden: $e', error: e, stackTrace: st);
      if (ref.mounted && !_userChanged) state = const Locale('de');
    }
  }

  Future<void> setLocale(String languageCode) async {
    _userChanged = true;
    state = Locale(languageCode);
    final settingsDao = ref.read(settingsRepositoryProvider);
    await settingsDao.insertOrUpdateSetting(
      SettingEntity(key: 'app_language', value: languageCode),
    );
  }

  Future<void> clearLocale() async {
    _userChanged = true;
    state = null;
    final settingsDao = ref.read(settingsRepositoryProvider);
    await settingsDao.insertOrUpdateSetting(
      const SettingEntity(key: 'app_language', value: kSystemLocaleSentinel),
    );
  }
}
