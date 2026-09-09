import 'database_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/companion_server_service.dart';

class CompanionNotifier extends Notifier<CompanionEvent?> {
  late final CompanionServerService _service;

  @override
  CompanionEvent? build() {
    _service = CompanionServerService();
    _init();

    ref.onDispose(() {
      _service.stop();
    });

    return null;
  }

  void _init() {
    _service.onEvent = (event) {
      state = event;
    };
    // Wire up profile fetcher so /api/profile can read settings from the DB
    _service.database = ref.read(databaseProvider);
    _service.settingsFetcher = (String key) async {
      final db = ref.read(databaseProvider);
      final setting = await db.settingsDao.getSettingByKey(key);
      return setting?.value;
    };
    _service.start();
  }

  void clearEvent() {
    state = null;
  }
}

final companionProvider = NotifierProvider<CompanionNotifier, CompanionEvent?>(
  CompanionNotifier.new,
);
