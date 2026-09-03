import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/companion_server_service.dart';
import '../providers/database_provider.dart';

class CompanionNotifier extends StateNotifier<CompanionEvent?> {
  final CompanionServerService _service;
  final Ref _ref;

  CompanionNotifier(this._ref) 
    : _service = CompanionServerService(), 
      super(null) {
    _init();
  }

  void _init() {
    _service.onEvent = (event) {
      state = event;
    };
    // Wire up profile fetcher so /api/profile can read settings from the DB
    _service.settingsFetcher = (String key) async {
      final db = _ref.read(databaseProvider);
      final setting = await db.settingsDao.getSettingByKey(key);
      return setting?.value;
    };
    _service.start();
  }
  
  void clearEvent() {
    state = null;
  }
  
  @override
  void dispose() {
    _service.stop();
    super.dispose();
  }
}

final companionProvider = StateNotifierProvider<CompanionNotifier, CompanionEvent?>((ref) {
  return CompanionNotifier(ref);
});
