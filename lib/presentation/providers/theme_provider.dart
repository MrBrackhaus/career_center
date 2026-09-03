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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

enum ThemePreset {
  standard,
  obsidian,
}

class ThemeState {
  final ThemeMode themeMode;
  final Color seedColor;
  final ThemePreset preset;

  ThemeState({
    required this.themeMode,
    required this.seedColor,
    this.preset = ThemePreset.standard,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    ThemePreset? preset,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      preset: preset ?? this.preset,
    );
  }
}

// Builds a seed-based ColorScheme but forces neutral surfaces (no background tinting)
ColorScheme _neutralDarkScheme(Color seedColor) {
  final base = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
  return base.copyWith(
    surface: const Color(0xFF1C1C1C),
    surfaceContainerHighest: const Color(0xFF2A2A2A),
    surfaceContainer: const Color(0xFF242424),
    surfaceContainerHigh: const Color(0xFF272727),
    surfaceContainerLow: const Color(0xFF1F1F1F),
    surfaceContainerLowest: const Color(0xFF161616),
    onSurface: const Color(0xFFE0E0E0),
    onSurfaceVariant: const Color(0xFFB0B0B0),
    surfaceTint: Colors.transparent,
  );
}

ColorScheme _neutralLightScheme(Color seedColor) {
  final base = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
  return base.copyWith(
    surface: const Color(0xFFF5F5F5),
    surfaceContainerHighest: const Color(0xFFE8E8E8),
    surfaceTint: Colors.transparent,
  );
}

// Obsidian preset: matches real Obsidian default theme (neutral dark gray + purple accents)
const obsidianDarkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF7C6AF7),           // Soft purple accent (buttons, links)
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF3D3560),
  onPrimaryContainer: Color(0xFFD4CEFF),
  secondary: Color(0xFF9A8FD8),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF353050),
  onSecondaryContainer: Color(0xFFCCC5FF),
  tertiary: Color(0xFFBF85D6),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF45305A),
  onTertiaryContainer: Color(0xFFEECDFF),
  error: Color(0xFFCF6679),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFF4A2030),
  onErrorContainer: Color(0xFFFFB3BE),
  // Neutral dark gray background - matching actual Obsidian
  surface: Color(0xFF181818),
  onSurface: Color(0xFFDCDDDE),
  surfaceContainerHighest: Color(0xFF2A2A2A),
  surfaceContainer: Color(0xFF222222),
  surfaceContainerHigh: Color(0xFF252525),
  surfaceContainerLow: Color(0xFF1C1C1C),
  surfaceContainerLowest: Color(0xFF121212),
  onSurfaceVariant: Color(0xFFAAAAAA),
  outline: Color(0xFF555555),
  outlineVariant: Color(0xFF404040),
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: Color(0xFFDCDDDE),
  onInverseSurface: Color(0xFF181818),
  inversePrimary: Color(0xFF5B50C4),
  surfaceTint: Colors.transparent,
);

final obsidianLightScheme = _neutralLightScheme(const Color(0xFF7C6AF7));

class ThemeNotifier extends StateNotifier<ThemeState> {
  final AppDatabase db;

  ThemeNotifier(this.db) : super(ThemeState(themeMode: ThemeMode.system, seedColor: Colors.teal)) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final modeStr = await db.settingsDao.getSettingByKey('themeMode');
    final colorStr = await db.settingsDao.getSettingByKey('themeColor');
    final presetStr = await db.settingsDao.getSettingByKey('themePreset');

    ThemeMode mode = ThemeMode.system;
    if (modeStr != null) {
      if (modeStr.value == 'light') mode = ThemeMode.light;
      if (modeStr.value == 'dark') mode = ThemeMode.dark;
    }

    Color color = Colors.teal;
    if (colorStr != null && colorStr.value.isNotEmpty) {
      try { color = Color(int.parse(colorStr.value)); } catch (_) {}
    }

    ThemePreset preset = ThemePreset.standard;
    if (presetStr?.value == 'obsidian') preset = ThemePreset.obsidian;

    state = ThemeState(themeMode: mode, seedColor: color, preset: preset);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    await db.settingsDao.insertOrUpdateSetting(Setting(key: 'themeMode', value: modeString));
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color, preset: ThemePreset.standard);
    await db.settingsDao.insertOrUpdateSetting(Setting(key: 'themeColor', value: color.value.toString()));
    await db.settingsDao.insertOrUpdateSetting(Setting(key: 'themePreset', value: 'standard'));
  }

  Future<void> setPreset(ThemePreset preset) async {
    state = state.copyWith(preset: preset);
    await db.settingsDao.insertOrUpdateSetting(Setting(key: 'themePreset', value: preset.name));
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final db = ref.watch(databaseProvider);
  return ThemeNotifier(db);
});

// Helper exposed for use in app.dart
ColorScheme buildDarkColorScheme(ThemeState state) {
  if (state.preset == ThemePreset.obsidian) return obsidianDarkScheme;
  return _neutralDarkScheme(state.seedColor);
}

ColorScheme buildLightColorScheme(ThemeState state) {
  if (state.preset == ThemePreset.obsidian) return obsidianLightScheme;
  return _neutralLightScheme(state.seedColor);
}

