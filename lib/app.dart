import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/locale_provider.dart';

class JobTrackerApp extends ConsumerWidget {
  const JobTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)?.appName ?? 'Career Center',
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
      supportedLocales: const [
        Locale('de', 'DE'),
        Locale('en', 'US'),
      ],
    );
  }
}


