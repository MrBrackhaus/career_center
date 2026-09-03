import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../core/router/app_router.dart'; // for jobcenterModeProvider
import 'bug_report_dialog.dart';

class ResponsiveShell extends ConsumerWidget {
  Widget _buildAppLogo(BuildContext context, {double size = 32}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        isDark ? 'assets/images/logo_dark.jpg' : 'assets/images/logo_light.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final jobcenterMode = ref.watch(jobcenterModeProvider).valueOrNull ?? false;

    final loc = AppLocalizations.of(context);
    final String title = loc?.appName ?? 'Career Center';

    final navItems = [
      _NavItem(
        label: loc?.navApplications ?? 'Bewerbungen',
        icon: Icons.work_outline,
        selectedIcon: Icons.work,
        path: '/applications',
      ),
      if (jobcenterMode)
        _NavItem(
          label: loc?.navJobcenter ?? 'Jobcenter-Nachweis',
          icon: Icons.description_outlined,
          selectedIcon: Icons.description,
          path: '/report',
        ),
      _NavItem(
        label: 'Wochenbericht',
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        path: '/reports/weekly',
      ),
      _NavItem(
        label: loc?.navCalendar ?? 'Kalender',
        icon: Icons.calendar_today_outlined,
        selectedIcon: Icons.calendar_month,
        path: '/calendar',
      ),
      _NavItem(
        label: loc?.navDashboard ?? 'Dashboard',
        icon: Icons.bar_chart_outlined,
        selectedIcon: Icons.bar_chart,
        path: '/dashboard',
      ),
      _NavItem(
        label: loc?.navTemplates ?? 'Vorlagen',
        icon: Icons.file_copy_outlined,
        selectedIcon: Icons.file_copy,
        path: '/templates',
      ),
    ];

    int currentIndex = navItems.indexWhere(
      (item) => location.startsWith(item.path),
    );
    if (currentIndex == -1) currentIndex = 0; // Default

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          if (!kIsWeb &&
              (Platform.isWindows || Platform.isLinux || Platform.isMacOS))
            SizedBox(width: double.infinity, height: 32, child: WindowCaption(brightness: Theme.of(context).brightness, backgroundColor: Theme.of(context).colorScheme.surface, title: const Text(''))),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Mobile: Bottom Navigation Bar
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () => context.go('/settings'),
                          tooltip: loc?.navSettings ?? 'Einstellungen',
                        ),
                      ],
                    ),
                    body: child,
                    bottomNavigationBar: NavigationBar(
                      selectedIndex: currentIndex,
                      onDestinationSelected: (index) =>
                          context.go(navItems[index].path),
                      destinations: navItems.map((item) {
                        return NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        );
                      }).toList(),
                    ),
                  );
                } else if (constraints.maxWidth < 1000) {
                  // Tablet: Navigation Rail
                  return Scaffold(
                    body: Row(
                      children: [
                        NavigationRail(
                          selectedIndex: currentIndex,
                          onDestinationSelected: (index) =>
                              context.go(navItems[index].path),
                          labelType: NavigationRailLabelType.all,
                          leading: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Icon(Icons.work_history, size: 32),
                          ),
                          trailing: Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.bug_report_outlined),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => const BugReportDialog(),
                                        );
                                      },
                                      tooltip: 'Bug melden',
                                    ),
                                    const SizedBox(height: 8),
                                    IconButton(
                                      icon: const Icon(Icons.settings_outlined),
                                      onPressed: () => context.go('/settings'),
                                      tooltip: loc?.navSettings ?? 'Einstellungen',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          destinations: navItems.map((item) {
                            return NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(
                                item.label,
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }).toList(),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(child: child),
                      ],
                    ),
                  );
                } else {
                  // Desktop: Expanded Navigation Rail
                  return Scaffold(
                    body: Row(
                      children: [
                        NavigationRail(
                          extended: true,
                          selectedIndex: currentIndex,
                          onDestinationSelected: (index) =>
                              context.go(navItems[index].path),
                          leading: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                _buildAppLogo(context, size: 32),
                                const SizedBox(width: 12),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Expanded(
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => const BugReportDialog(),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 12.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.bug_report_outlined),
                                              const SizedBox(width: 12),
                                              const Text('Bug melden'),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () => context.go('/settings'),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0,
                                            vertical: 12.0,
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.settings_outlined),
                                              const SizedBox(width: 12),
                                              Text(
                                                loc?.navSettings ?? 'Einstellungen',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ),
                          destinations: navItems.map((item) {
                            return NavigationRailDestination(
                              icon: Icon(item.icon),
                              selectedIcon: Icon(item.selectedIcon),
                              label: Text(item.label),
                            );
                          }).toList(),
                        ),
                        const VerticalDivider(thickness: 1, width: 1),
                        Expanded(child: child),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}
