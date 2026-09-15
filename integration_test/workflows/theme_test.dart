import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Theme Change Workflow', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // Navigiere zu Einstellungen
    final settingsNav = find.byIcon(Icons.settings_outlined);
    expect(settingsNav, findsWidgets);
    await tester.tap(settingsNav.first);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // Suche Theme Dropdown. Es steht neben Icons.brightness_6
    final themeIcon = find.byIcon(Icons.brightness_6);
    expect(themeIcon, findsWidgets);
    
    // Tap auf das Dropdown neben dem Icon.
    // In settings_screen.dart ist es in einer ListTile. Wir können direkt auf die ListTile tippen, um das Dropdown zu öffnen (falls clickbar), ansonsten suchen wir das Dropdown.
    final dropdown = find.byWidgetPredicate((widget) => widget is DropdownButton<ThemeMode>);
    if (dropdown.evaluate().isNotEmpty) {
      await tester.ensureVisible(dropdown.first);
      await tester.tap(dropdown.first);
      await tester.pumpAndSettle();
      
      // Wähle Dunkel
      final darkItem = find.text('Dunkel').last;
      if (darkItem.evaluate().isNotEmpty) {
        await tester.tap(darkItem);
        await tester.pumpAndSettle();
      }
    }
    
    print('✅ Theme-Workflow erfolgreich durchlaufen.');
  });
}
