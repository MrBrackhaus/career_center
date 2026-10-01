// Runs every workflow test in ONE app build/launch (much faster on desktop
// than `flutter test integration_test`, which builds per file):
//
//   flutter test integration_test/run_all_tests.dart -d windows
//
// Every test starts the app through helpers/test_app.dart with its own
// in-memory database, so tests are isolated and never touch real user data.
import 'package:integration_test/integration_test.dart';

import 'workflows/application_flow_test.dart' as application_flow;
import 'workflows/bulk_autofill_test.dart' as bulk_autofill;
import 'workflows/companion_autofill_test.dart' as companion_autofill;
import 'workflows/dashboard_test.dart' as dashboard;
import 'workflows/delete_test.dart' as delete;
import 'workflows/editor_extended_test.dart' as editor_extended;
import 'workflows/form_validation_test.dart' as form_validation;
import 'workflows/kanban_extended_test.dart' as kanban_extended;
import 'workflows/magic_autofill_test.dart' as magic_autofill;
import 'workflows/new_features_test.dart' as new_features;
import 'workflows/real_url_test.dart' as real_url;
import 'workflows/reports_test.dart' as reports;
import 'workflows/search_filter_test.dart' as search_filter;
import 'workflows/settings_test.dart' as settings;
import 'workflows/streak_test.dart' as streak;
import 'workflows/templates_test.dart' as templates;
import 'workflows/theme_test.dart' as theme;
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('application_flow', application_flow.main);
  group('bulk_autofill', bulk_autofill.main);
  group('companion_autofill', companion_autofill.main);
  group('dashboard', dashboard.main);
  group('delete', delete.main);
  group('editor_extended', editor_extended.main);
  group('form_validation', form_validation.main);
  group('kanban_extended', kanban_extended.main);
  group('magic_autofill', magic_autofill.main);
  group('new_features', new_features.main);
  group('real_url', real_url.main); // skipped unless RUN_NETWORK_TESTS=true
  group('reports', reports.main);
  group('search_filter', search_filter.main);
  group('settings', settings.main);
  group('streak', streak.main);
  group('templates', templates.main);
  group('theme', theme.main);
}
