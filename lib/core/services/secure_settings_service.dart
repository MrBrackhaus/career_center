import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/database/app_database.dart';

/// Zugriff auf Geheimnisse (API-Keys), die nicht im Klartext in der
/// Settings-Tabelle liegen sollen.
class SecureSettingsService {
  static const _storage = FlutterSecureStorage();
  static const _aiApiKey = 'aiApiKey';

  static Future<String> getAiApiKey() async {
    return await _storage.read(key: _aiApiKey) ?? '';
  }

  static Future<void> setAiApiKey(String value) async {
    if (value.isEmpty) {
      await _storage.delete(key: _aiApiKey);
    } else {
      await _storage.write(key: _aiApiKey, value: value);
    }
  }

  /// Verschiebt einen alten, im Klartext gespeicherten API-Key aus der
  /// Settings-Tabelle in den Secure Storage und löscht ihn dort.
  static Future<void> migrateLegacyAiApiKey(AppDatabase db) async {
    final legacy = await db.settingsDao.getSettingByKey(_aiApiKey);
    if (legacy == null) return;
    if (legacy.value.isNotEmpty && (await getAiApiKey()).isEmpty) {
      await setAiApiKey(legacy.value);
    }
    await (db.delete(db.settings)..where((t) => t.key.equals(_aiApiKey))).go();
  }
}
