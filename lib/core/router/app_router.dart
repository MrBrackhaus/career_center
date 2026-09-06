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
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/applications/applications_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/widgets/responsive_shell.dart';
import '../../presentation/screens/applications/application_form_screen.dart';
import '../../presentation/screens/editor/application_editor_screen.dart';
import '../../presentation/screens/reports/jobcenter_report_screen.dart';
import '../../presentation/screens/reports/weekly_report_screen.dart';
import '../../presentation/screens/templates/templates_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/messages/messages_screen.dart';
import '../../presentation/providers/database_provider.dart';
import '../../presentation/providers/companion_provider.dart';
import '../services/companion_server_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

// Provider to watch jobcenterMode setting
final jobcenterModeProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final setting = await db.settingsDao.getSettingByKey('jobcenterMode');
  return setting?.value == 'true';
});

CustomTransitionPage<void> _fadeTransitionPage(BuildContext context, GoRouterState state, Widget child) {
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
    GoRoute(
      path: '/',
      redirect: (context, state) => '/applications',
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithTopBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/applications',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const ApplicationsScreen()),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return ApplicationFormScreen(
                  initialUrl: extra?['url'] as String?,
                  initialHtml: extra?['html'] as String?,
                  initialScreenshotBase64: extra?['screenshot'] as String?,
                );
              },
            ),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ApplicationFormScreen(applicationId: id);
              },
            ),
            GoRoute(
              path: ':id/editor',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ApplicationEditorScreen(applicationId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/report',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const JobcenterReportScreen()),
        ),
        GoRoute(
          path: '/reports/weekly',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const WeeklyReportScreen()),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const CalendarScreen()),
        ),
        GoRoute(
          path: '/messages',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const MessagesScreen()),
        ),
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const DashboardScreen()),
        ),
        GoRoute(
          path: '/templates',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const TemplatesScreen()),
        ),
        GoRoute(
          path: '/editor',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const ApplicationEditorScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _fadeTransitionPage(context, state, const SettingsScreen()),
        ),
      ],
    ),
  ],
);

class ScaffoldWithTopBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithTopBar({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to Smart Clipboard events from Chrome Extension
    ref.listen<CompanionEvent?>(companionProvider, (previous, next) {
      if (next != null) {
        if (next.type == 'import') {
          final url = next.payload['url'] as String?;
          if (url != null) {
             // We can pass this to /applications/add via extra or we just route there
             // For now, let's just route to Add and show a snackbar!
             context.go('/applications/add', extra: {
               'url': url,
               'html': next.payload['html'],
               'screenshot': next.payload['screenshot'],
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

    final location = GoRouterState.of(context).uri.path;
    final jobcenterMode = ref.watch(jobcenterModeProvider).value ?? false;

    return ResponsiveShell(child: child);
  }

  Widget _buildNavButton(BuildContext context, String title, String route, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
          foregroundColor: isSelected ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => context.go(route),
        child: Text(title),
      ),
    );
  }
}











