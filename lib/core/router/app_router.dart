/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/applications/applications_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/widgets/responsive_shell.dart';
import '../../presentation/screens/applications/application_form_screen.dart';
import '../../presentation/screens/applications/widgets/mock_interview_screen.dart';
import '../../presentation/screens/editor/application_editor_screen.dart';
import '../../domain/entities/application_entity.dart';
import '../../presentation/screens/reports/jobcenter_report_screen.dart';
import '../../presentation/screens/reports/weekly_report_screen.dart';
import '../../presentation/screens/templates/templates_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/messages/messages_screen.dart';
import '../../presentation/providers/database_provider.dart';
import '../../presentation/providers/companion_provider.dart';
import '../services/companion_server_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

// Provider to watch jobcenterMode setting
final jobcenterModeProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final setting = await db.settingsDao.getSettingByKey('jobcenterMode');
  return setting?.value == 'true';
});

CustomTransitionPage<void> _fadeTransitionPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/applications',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/applications'),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithTopBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/applications',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context, state, const ApplicationsScreen()),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) {
                final extra = state.extra is Map ? state.extra as Map : null;
                String? str(String key) {
                  final v = extra?[key];
                  return v is String ? v : null;
                }

                return ApplicationFormScreen(
                  initialUrl: str('url'),
                  initialHtml: str('html'),
                  initialScreenshotBase64: str('screenshot'),
                );
              },
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) return const Scaffold(body: Center(child: Text('Ungültige ID')));
                return ApplicationFormScreen(applicationId: id);
              },
            ),
            GoRoute(
              path: ':id/editor',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) return const Scaffold(body: Center(child: Text('Ungültige ID')));
                return ApplicationEditorScreen(applicationId: id);
              },
            ),
            GoRoute(
              path: ':id/interview',
              builder: (context, state) {
                final extra = state.extra;
                final app = extra is ApplicationEntity ? extra : null;
                if (app == null) return const Scaffold(body: Center(child: Text('App fehlt')));
                return MockInterviewScreen(application: app);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/report',
          pageBuilder: (context, state) => _fadeTransitionPage(
            context,
            state,
            const JobcenterReportScreen(),
          ),
        ),
        GoRoute(
          path: '/reports/weekly',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context, state, const WeeklyReportScreen()),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context, state, const CalendarScreen()),
        ),
        GoRoute(
          path: '/messages',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context, state, const MessagesScreen()),
        ),
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context, state, const DashboardScreen()),
        ),
        GoRoute(
          path: '/templates',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context, state, const TemplatesScreen()),
        ),
        GoRoute(
          path: '/editor',
          pageBuilder: (context, state) => _fadeTransitionPage(
            context,
            state,
            const ApplicationEditorScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              _fadeTransitionPage(context, state, const SettingsScreen()),
        ),
      ],
    ),
  ],
);

class ScaffoldWithTopBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithTopBar({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to Smart Clipboard events from Chrome Extension
    ref.listen<CompanionEvent?>(companionProvider, (previous, next) {
      if (next != null) {
        if (next.type == 'import') {
          final rawUrl = next.payload['url'];
          final url = rawUrl is String && rawUrl.isNotEmpty ? rawUrl : null;
          if (url != null) {
            final rawHtml = next.payload['html'];
            final rawShot = next.payload['screenshot'];
            _handleImport(context, {
              'url': url,
              if (rawHtml is String) 'html': rawHtml,
              if (rawShot is String) 'screenshot': rawShot,
            });
          }
        } else if (next.type == 'autofill_request') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎯 Formular-Modus aktiv (Overlay)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        ref.read(companionProvider.notifier).clearEvent();
      }
    });

    
    

    return ResponsiveShell(child: child);
  }

  /// Ist gerade ein Formular (Neu/Bearbeiten/Editor) geöffnet, dessen
  /// ungespeicherte Eingaben bei einer Navigation verloren gingen?
  static bool _isOnForm(String path) =>
      path == '/applications/add' ||
      path.startsWith('/applications/edit/') ||
      path.endsWith('/editor') ||
      path == '/editor';

  static Future<void> _handleImport(
    BuildContext context,
    Map<String, String> extra,
  ) async {
    final currentPath = appRouter.routerDelegate.currentConfiguration.uri.path;

    if (_isOnForm(currentPath)) {
      final dialogContext = _rootNavigatorKey.currentContext ?? context;
      final confirmed = await showDialog<bool>(
        context: dialogContext,
        builder: (ctx) => AlertDialog(
          title: const Text('Stellenanzeige importieren?'),
          content: const Text(
            'Es ist gerade ein Formular geöffnet. Nicht gespeicherte Eingaben '
            'gehen verloren, wenn du die importierte Stelle jetzt öffnest.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Verwerfen und öffnen'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (currentPath == '/applications/add') {
      // Gleiche Route: erst verlassen, damit das Formular mit den neuen
      // Importdaten frisch aufgebaut wird.
      appRouter.go('/applications');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appRouter.go('/applications/add', extra: extra);
      });
    } else {
      appRouter.go('/applications/add', extra: extra);
    }
  }
}
