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
import '../../core/services/imap_service.dart';
import 'database_provider.dart';
import '../../data/database/app_database.dart';

final imapServiceProvider = Provider((ref) => ImapService());

class ImapSyncNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ImapSyncNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<int> syncEmails() async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(databaseProvider);
      final imapService = ref.read(imapServiceProvider);

      final serverSetting = await db.settingsDao.getSettingByKey('imapServer');
      final portSetting = await db.settingsDao.getSettingByKey('imapPort');
      final emailSetting = await db.settingsDao.getSettingByKey('imapEmail');
      final passSetting = await db.settingsDao.getSettingByKey('imapPassword');

      if (serverSetting == null || serverSetting.value.isEmpty ||
          portSetting == null || portSetting.value.isEmpty ||
          emailSetting == null || emailSetting.value.isEmpty ||
          passSetting == null || passSetting.value.isEmpty) {
        throw Exception('IMAP Zugangsdaten nicht konfiguriert.');
      }

      final password = await ImapService.getPassword();
      if (password.isEmpty) {
        throw Exception('Passwort konnte nicht entschlüsselt werden.');
      }

      final imported = await imapService.syncEmails(
        db,
        serverSetting.value,
        int.tryParse(portSetting.value) ?? 993,
        emailSetting.value,
        password,
      );
      
      await db.settingsDao.insertOrUpdateSetting(
        Setting(key: 'imapLastSync', value: DateTime.now().toIso8601String())
      );
      await db.settingsDao.insertOrUpdateSetting(
        Setting(key: 'imapLastImportCount', value: imported.toString())
      );
      ref.invalidate(imapLastSyncProvider);
      
      state = const AsyncValue.data(null);
      return imported;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final imapLastSyncProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  final db = ref.watch(databaseProvider);
  final setting = await db.settingsDao.getSettingByKey('imapLastSync');
  if (setting != null && setting.value.isNotEmpty) {
    return DateTime.tryParse(setting.value);
  }
  return null;
});

final imapSyncProvider = StateNotifierProvider<ImapSyncNotifier, AsyncValue<void>>((ref) {
  return ImapSyncNotifier(ref);
});

final applicationEmailsProvider = FutureProvider.family.autoDispose((ref, int applicationId) async {
  final db = ref.watch(databaseProvider);
  return db.emailsDao.getEmailsForApplication(applicationId);
});

