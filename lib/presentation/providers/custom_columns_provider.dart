import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';

/// Tick dieser StateProvider hochzählen → customColumnsProvider wird neu geladen
/// Aktive Spalten aus den Settings lesen
final customColumnsProvider = FutureProvider<List<String>>((ref) async {
  final dao = ref.watch(databaseProvider).settingsDao;
  final setting = await dao.getSettingByKey('customColumns');
  if (setting == null || setting.value.isEmpty) return [];
  return setting.value
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
});

