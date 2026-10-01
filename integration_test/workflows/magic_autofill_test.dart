import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

String _fieldText(WidgetTester tester, String label) =>
    tester.widget<TextField>(fieldByLabel(label)).controller!.text;

/// Serves integration_test/mock_server/job.html on an ephemeral loopback
/// port – no external server (formerly expected on :8080) is required.
Future<HttpServer> _startJobServer(String html) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((req) {
    if (req.uri.path == '/job.html') {
      req.response.headers.contentType = ContentType.html;
      req.response.write(html);
    } else {
      req.response.statusCode = HttpStatus.notFound;
    }
    req.response.close();
  });
  return server;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Magic Auto-Fill: entering a job URL fills company, position and '
      'job link from the page', (tester) async {
    // flutter_test's widget binding mocks HttpClient (always 400); the
    // integration binding does not. Make sure real loopback HTTP works in both.
    final previousOverrides = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = previousOverrides);

    final fixture = File(fixturePath('job.html'));
    expect(fixture.existsSync(), isTrue,
        reason: 'fixture missing: ${fixture.path}');
    final server = (await tester.runAsync(
        () async => _startJobServer(await fixture.readAsString())))!;
    addTearDown(() => server.close(force: true));
    final url = 'http://127.0.0.1:${server.port}/job.html';

    await pumpTestApp(tester);
    await tapVisible(
        tester, find.widgetWithText(FilledButton, 'Neue Bewerbung').first);

    final urlField = find.ancestor(
        of: find.byIcon(Icons.link), matching: find.byType(TextField));
    await tester.enterText(urlField, url);
    await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Ausfüllen'));
    await pumpUntilFound(tester, find.text('Daten aus Webseite extrahiert'));

    expect(_fieldText(tester, 'Firma *'), 'Acme Corp');
    expect(_fieldText(tester, 'Position *'), 'Senior Flutter Developer');
    expect(_fieldText(tester, 'Link zur Stellenausschreibung'), url);
  });

  testWidgets('Magic Auto-Fill without URL shows a hint and changes nothing',
      (tester) async {
    await pumpTestApp(tester);
    await tapVisible(
        tester, find.widgetWithText(FilledButton, 'Neue Bewerbung').first);
    await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Ausfüllen'));

    expect(find.text('Bitte erst eine URL eingeben.'), findsOneWidget);
    expect(_fieldText(tester, 'Firma *'), isEmpty);
  });
}
