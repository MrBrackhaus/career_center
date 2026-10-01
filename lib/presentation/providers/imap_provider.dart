/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/imap_service.dart';
import '../../core/services/extractors/ai_email_extractor_service.dart';
import 'database_provider.dart';
import '../../domain/entities/setting_entity.dart';

final imapServiceProvider = Provider((ref) => ImapService());

class ImapSyncStatusNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void updateStatus(String? status) {
    state = status;
  }
}

final imapSyncStatusProvider = NotifierProvider<ImapSyncStatusNotifier, String?>(
  ImapSyncStatusNotifier.new,
);

class ImapSyncNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<int> syncEmails() async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(databaseProvider);
      final imapService = ref.read(imapServiceProvider);

      final serverSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('imapServer');
      final portSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('imapPort');
      final emailSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('imapEmail');
      final passSetting = await ref.read(settingsRepositoryProvider).getSettingByKey('imapPassword');

      if (serverSetting == null ||
          serverSetting.value.isEmpty ||
          portSetting == null ||
          portSetting.value.isEmpty ||
          emailSetting == null ||
          emailSetting.value.isEmpty ||
          passSetting == null ||
          passSetting.value.isEmpty) {
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
        aiExtractor: ref.read(aiEmailExtractorProvider),
        onProgress: (msg) {
          ref.read(imapSyncStatusProvider.notifier).updateStatus(msg);
        },
      );

      ref.read(imapSyncStatusProvider.notifier).updateStatus(null);

      await ref.read(settingsRepositoryProvider).insertOrUpdateSetting(
        SettingEntity(key: 'imapLastSync', value: DateTime.now().toIso8601String()),
      );
      await ref.read(settingsRepositoryProvider).insertOrUpdateSetting(
        SettingEntity(key: 'imapLastImportCount', value: imported.toString()),
      );
      ref.invalidate(imapLastSyncProvider);

      state = const AsyncValue.data(null);
      return imported;
    } catch (e, st) {
      ref.read(imapSyncStatusProvider.notifier).updateStatus(null);
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final imapLastSyncProvider = FutureProvider.autoDispose<DateTime?>((ref) async {
  final setting = await ref.read(settingsRepositoryProvider).getSettingByKey('imapLastSync');
  if (setting != null && setting.value.isNotEmpty) {
    return DateTime.tryParse(setting.value);
  }
  return null;
});

final imapSyncProvider = NotifierProvider<ImapSyncNotifier, AsyncValue<void>>(
  ImapSyncNotifier.new,
);

final applicationEmailsProvider = FutureProvider.family.autoDispose((
  ref,
  int applicationId,
) async {
  return ref.read(emailsRepositoryProvider).getEmailsForApplication(applicationId);
});
