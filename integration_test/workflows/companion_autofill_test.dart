import 'package:career_center/core/services/companion_server_service.dart';
import 'package:career_center/presentation/providers/companion_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

const _mockUrl =
    'https://www.arbeitsagentur.de/jobsuche/jobdetail/17560-e52311f57a34493-S';

// What the browser extension posts to /api/import after the user solved any
// captcha in the real browser.
const _mockHtml = '''
<html>
  <head><title>Stellenangebot: Fachinformatiker Systemintegration (m/w/d) bei AlphaConsult Premium KG</title></head>
  <body>
    <h1>Fachinformatiker Systemintegration (m/w/d)</h1>
    <h2>AlphaConsult Premium KG</h2>
    <p>Arbeitsort: Köln</p>
    <script type="application/ld+json">
    {
      "@context": "https://schema.org/",
      "@type": "JobPosting",
      "title": "Fachinformatiker Systemintegration (m/w/d)",
      "hiringOrganization": {"@type": "Organization", "name": "AlphaConsult Premium KG"},
      "jobLocation": {"@type": "Place", "address": {"addressLocality": "Köln"}}
    }
    </script>
  </body>
</html>
''';

String _fieldText(WidgetTester tester, String label) =>
    tester.widget<TextField>(fieldByLabel(label)).controller!.text;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('an "import" event from the browser extension opens a pre-filled '
      'new application form; saving stores it', (tester) async {
    final t = await pumpTestApp(tester);

    t.companion.emit(CompanionEvent('import', {'url': _mockUrl, 'html': _mockHtml}));
    await pumpUntilFound(
        tester, find.text('✅ Daten direkt aus dem Browser übernommen!'));

    // Routing: the new-application form was opened with the URL.
    expect(find.text('Neue Bewerbung'), findsWidgets);
    expect(_fieldText(tester, 'Link zur Stellenausschreibung'), _mockUrl);
    // Extraction: the page carries a schema.org JobPosting, so company and
    // position must be taken from it (not raw <title>/<html> markup).
    expect(_fieldText(tester, 'Firma *'), 'AlphaConsult Premium KG');
    expect(_fieldText(tester, 'Position *'),
        'Fachinformatiker Systemintegration (m/w/d)');

    // The event is consumed (cleared) so it does not fire again.
    expect(t.container.read(companionProvider), isNull);

    await tapVisible(tester, find.widgetWithIcon(ElevatedButton, Icons.save));
    final apps = await tester.runAsync(t.db.applicationsDao.getAllApplications);
    expect(apps, hasLength(1));
    expect(apps!.single.company, 'AlphaConsult Premium KG');
    expect(apps.single.jobUrl, _mockUrl);
  });

  testWidgets('events without URL are ignored', (tester) async {
    final t = await pumpTestApp(tester);
    t.companion.emit(CompanionEvent('import', {'html': _mockHtml}));
    await settle(tester);

    expect(find.text('Neue Bewerbung'), findsWidgets); // button on the list
    expect(find.byType(Form), findsNothing, reason: 'form was not opened');
  });
}
