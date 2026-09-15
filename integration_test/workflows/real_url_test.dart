import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/presentation/providers/application_form_notifier.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Arbeitsagentur URL Extraction', (WidgetTester tester) async {
    final container = ProviderContainer();
    final notifier = container.read(applicationFormNotifierProvider.notifier);
    
    try {
      print('Starting extraction...');
      await notifier.extractFromUrl('https://www.arbeitsagentur.de/jobboerse/suche/details/10000-1191313495-S');
      
      final state = container.read(applicationFormNotifierProvider);
      print('--- Extraction Result ---');
      if (state.result != null) {
        final r = state.result!.fields;
        print('Company: ${r.company?.value}');
        print('Position: ${r.position?.value}');
        print('Email: ${r.contactEmail?.value}');
        print('Phone: ${r.contactPhone?.value}');
      } else {
        print('No result: ${state.error}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      container.dispose();
    }
  });
}
