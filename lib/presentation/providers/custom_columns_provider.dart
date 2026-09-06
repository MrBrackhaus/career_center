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

