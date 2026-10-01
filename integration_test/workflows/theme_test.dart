import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

ThemeMode? _appThemeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('choosing "Dark" switches the app to dark mode and persists it',
      (tester) async {
    final t = await pumpTestApp(tester, settings: {'themeMode': 'light'});
    expect(_appThemeMode(tester), ThemeMode.light,
        reason: 'persisted theme is loaded on start');

    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tapVisible(tester, find.text('Bewerbungs-Setup'));

    await tapVisible(tester, find.byType(DropdownButton<ThemeMode>));
    await tapVisible(tester, find.text('Dark').last);

    expect(_appThemeMode(tester), ThemeMode.dark);
    final scaffoldContext = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(scaffoldContext).brightness, Brightness.dark);
    expect(await tester.runAsync(() => t.setting('themeMode')), 'dark');
  });
}
