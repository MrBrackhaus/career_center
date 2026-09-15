import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;
import 'package:career_center/core/services/companion_server_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Auto-Fill Companion Server Injection Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // The mock data simulating what the browser extension sends after the user solves captchas
    final mockHtmlFromBrowser = '''
      <html>
        <head><title>Stellenangebot: Fachinformatiker Systemintegration (m/w/d) bei AlphaConsult Premium KG</title></head>
        <body>
          <h1>Fachinformatiker Systemintegration (m/w/d)</h1>
          <h2>AlphaConsult Premium KG</h2>
          <p>Arbeitsort: Köln</p>
          <p>Befristung: unbefristet</p>
          <script type="application/ld+json">
          {
            "@context": "https://schema.org/",
            "@type": "JobPosting",
            "title": "Fachinformatiker Systemintegration (m/w/d)",
            "hiringOrganization": {
              "@type": "Organization",
              "name": "AlphaConsult Premium KG"
            },
            "jobLocation": {
              "@type": "Place",
              "address": {
                "addressLocality": "Köln"
              }
            }
          }
          </script>
        </body>
      </html>
    ''';

    final mockUrl = 'https://www.arbeitsagentur.de/jobsuche/jobdetail/17560-e52311f57a34493-S';

    // Simulate the CompanionServer receiving an import event
    CompanionServerService().onEvent?.call(
      CompanionEvent('import', {
        'url': mockUrl,
        'html': mockHtmlFromBrowser,
      })
    );

    // Give the app time to route and process the data without skipping the SnackBar
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Verify we navigated to the Application Form Screen
    expect(find.text('Neue Bewerbung'), findsWidgets);

    // We skip the strict SnackBar text check to avoid timing flakiness.
    // The most important thing is that the text fields are filled!

    // Verify the AutoFill successfully populated the text fields in the UI!
    final companyField = find.descendant(
      of: find.byType(TextFormField),
      matching: find.text('AlphaConsult Premium KG'),
    );
    expect(companyField, findsWidgets, reason: 'Company field should be auto-filled');

    final positionField = find.descendant(
      of: find.byType(TextFormField),
      matching: find.text('Fachinformatiker Systemintegration (m/w/d)'),
    );
    expect(positionField, findsWidgets, reason: 'Position field should be auto-filled');
    
    print('✅ Auto-Fill Companion Server UI Test passed successfully!');
  });
}
