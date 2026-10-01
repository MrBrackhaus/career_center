import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

Future<void> _openSettings(WidgetTester tester) async {
  await tapVisible(tester, find.byIcon(Icons.settings_outlined));
  await pumpUntilFound(tester, find.text('Profil & Kontakt'));
  await settle(tester);
}

String _fieldText(WidgetTester tester, String label) =>
    tester.widget<TextField>(fieldByLabel(label)).controller!.text;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile fields are loaded from the database', (tester) async {
    await pumpTestApp(tester, settings: {
      'userName': 'Erika Mustermann',
      'userEmail': 'erika@example.com',
      'userCity': 'Köln',
      'userZip': '50667',
    });
    await _openSettings(tester);

    expect(_fieldText(tester, 'Name'), 'Erika Mustermann');
    expect(_fieldText(tester, 'E-Mail'), 'erika@example.com');
    expect(_fieldText(tester, 'Stadt'), 'Köln');
    expect(_fieldText(tester, 'PLZ'), '50667');
  });

  testWidgets('editing the profile and pressing "Speichern" persists it',
      (tester) async {
    final t = await pumpTestApp(tester, settings: {
      'userName': 'Erika Mustermann',
      'userEmail': 'old@example.com',
    });
    await _openSettings(tester);

    await tester.enterText(fieldByLabel('E-Mail'), 'tester@example.com');
    await tester.enterText(fieldByLabel('Telefon'), '+49 221 123456');
    await tapVisible(
        tester, find.widgetWithText(ElevatedButton, 'Speichern').first);
    await pumpUntilFound(tester, find.text('✅ Einstellungen gespeichert'));

    expect(await tester.runAsync(() => t.setting('userEmail')),
        'tester@example.com');
    expect(await tester.runAsync(() => t.setting('userPhone')),
        '+49 221 123456');
    // Untouched values are kept.
    expect(await tester.runAsync(() => t.setting('userName')),
        'Erika Mustermann');
  });

  testWidgets('unsaved edits are not written', (tester) async {
    final t = await pumpTestApp(tester, settings: {'userEmail': 'keep@example.com'});
    await _openSettings(tester);

    await tester.enterText(fieldByLabel('E-Mail'), 'not-saved@example.com');
    await settle(tester);
    // Navigate away without saving.
    await tapVisible(tester, find.byIcon(Icons.work_outline));

    expect(await tester.runAsync(() => t.setting('userEmail')),
        'keep@example.com');
  });
}
