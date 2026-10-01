/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/router/app_router.dart';
import 'presentation/providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/providers/database_provider.dart';

class JobTrackerApp extends ConsumerStatefulWidget {
  const JobTrackerApp({super.key});

  @override
  ConsumerState<JobTrackerApp> createState() => _JobTrackerAppState();
}

class _JobTrackerAppState extends ConsumerState<JobTrackerApp> with WindowListener {
  
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Schließe die Datenbank sauber beim Beenden
    try {
      final db = ref.read(databaseProvider);
      await db.close();
    } catch (e, st) {
      log('Fehler beim Schließen der Datenbank: $e', error: e, stackTrace: st);
    } finally {
      // setPreventClose(true) ist aktiv – ohne destroy() ließe sich das
      // Fenster nicht mehr schließen.
      await windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appName ?? 'Career Center',
      routerConfig: appRouter,
      locale: locale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: buildLightColorScheme(themeState),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: buildDarkColorScheme(themeState),
      ),
      themeMode: themeState.themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
