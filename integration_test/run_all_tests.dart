import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'workflows/application_flow_test.dart' as t1;
import 'workflows/companion_autofill_test.dart' as t2;
import 'workflows/comparison_test.dart' as t3;
import 'workflows/dashboard_test.dart' as t4;
import 'workflows/delete_test.dart' as t5;
import 'workflows/editor_extended_test.dart' as t6;
import 'workflows/form_validation_test.dart' as t7;
import 'workflows/kanban_extended_test.dart' as t8;
import 'workflows/magic_autofill_test.dart' as t9;
import 'workflows/real_url_test.dart' as t10;
import 'workflows/reports_test.dart' as t11;
import 'workflows/settings_test.dart' as t12;
import 'workflows/streak_test.dart' as t13;
import 'workflows/templates_test.dart' as t14;
import 'workflows/theme_test.dart' as t15;
import 'workflows/search_filter_test.dart' as t16;
import 'workflows/new_features_test.dart' as t17;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App E2E Test Suite', () {
    t1.main();
    t2.main();
    t3.main();
    t4.main();
    t5.main();
    t6.main();
    t7.main();
    t8.main();
    t9.main();
    t10.main();
    t11.main();
    t12.main();
    t13.main();
    t14.main();
    t15.main();
    t16.main();
    t17.main();
  });
}
