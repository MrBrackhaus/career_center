// Live smoke test against arbeitsagentur.de. Needs internet and a job ad that
// still exists, so it is skipped by default. Run with:
//   flutter test integration_test/workflows/real_url_test.dart -d windows \
//     --dart-define=RUN_NETWORK_TESTS=true \
//     [--dart-define=REAL_JOB_URL=https://www.arbeitsagentur.de/jobsuche/jobdetail/...]
import 'package:career_center/presentation/providers/application_form_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

const _url = String.fromEnvironment(
  'REAL_JOB_URL',
  defaultValue:
      'https://www.arbeitsagentur.de/jobsuche/jobdetail/10000-1207359897-S',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live Arbeitsagentur URL yields company and position',
      (tester) async {
    installSandbox();
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.runAsync(() => container
        .read(applicationFormNotifierProvider.notifier)
        .extractFromUrl(_url));

    final state = container.read(applicationFormNotifierProvider);
    expect(state.error, isNull);
    expect(state.result, isNotNull);
    final company = state.result!.fields.company?.value;
    final position = state.result!.fields.position?.value;
    expect(company, isNotNull);
    expect(company, isNot(contains('<')));
    expect(company!.trim(), isNotEmpty);
    expect(position, isNotNull);
    expect(position, isNot(contains('<')));
    expect(position!.trim(), isNotEmpty);
  }, skip: kSkipNetworkTests); // needs network
}
