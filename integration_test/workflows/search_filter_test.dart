import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;
import 'package:career_center/presentation/screens/applications/widgets/application_card.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Search and Filter Workflow - Create 3 apps and filter them', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final appleName = 'Apple Corp $timestamp';
    final msName = 'Microsoft GmbH $timestamp';
    final googleName = 'Google LLC $timestamp';

    // 1. Create first application (Apple)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    // Fill Firma
    await tester.enterText(find.byType(TextFormField).at(0), appleName);
    // Fill Position
    await tester.enterText(find.byType(TextFormField).at(3), 'iOS Developer');
    
    // Save (pops automatically)
    await tester.ensureVisible(find.byIcon(Icons.save));
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));


    // 2. Create second application (Microsoft)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).at(0), msName);
    await tester.enterText(find.byType(TextFormField).at(3), 'C# Developer');
    
    // Save (pops automatically)
    await tester.ensureVisible(find.byIcon(Icons.save));
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));


    // 3. Create third application (Google)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).at(0), googleName);
    await tester.enterText(find.byType(TextFormField).at(3), 'Go Developer');
    
    // Save (pops automatically)
    await tester.ensureVisible(find.byIcon(Icons.save));
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // 4. We are already on the Applications (Kanban) screen.
    // (Note: We skip expecting them to be immediately visible because there might be dummy data pushing them off-screen in the ListView)

    // 5. Search for "Apple"
    final searchField = find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.prefixIcon is Icon && (widget.decoration!.prefixIcon as Icon).icon == Icons.search
    );
    await tester.enterText(searchField.first, appleName);
    await tester.pumpAndSettle(const Duration(milliseconds: 500)); // Debounce?
    await tester.pumpAndSettle(); // extra wait
    
    // We expect 2 widgets: the text in the search box, and the text in the card
    expect(find.text(appleName), findsNWidgets(2));
    expect(find.text(msName), findsNothing);
    expect(find.text(googleName), findsNothing);

    // 6. Search for Microsoft
    await tester.enterText(searchField.first, msName);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    expect(find.text(appleName), findsNothing);
    expect(find.text(msName), findsNWidgets(2));
    expect(find.text(googleName), findsNothing);

    // 7. Search for Google
    await tester.enterText(searchField.first, googleName);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    expect(find.text(appleName), findsNothing);
    expect(find.text(msName), findsNothing);
    expect(find.text(googleName), findsNWidgets(2));
    
    // 8. Clean up (delete all 3)
    debugPrint('STARTING CLEANUP!');
    
    // Delete Apple
    await tester.tap(searchField.first);
    await tester.pumpAndSettle();
    await tester.enterText(searchField.first, appleName);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.tap(find.descendant(of: find.byType(ApplicationCard), matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // Delete Microsoft
    await tester.tap(searchField.first);
    await tester.pumpAndSettle();
    await tester.enterText(searchField.first, msName);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    try {
      expect(find.text(msName), findsWidgets, reason: 'Microsoft should be found before deleting');
    } catch (e) {
      debugPrint('WIDGET TREE WHEN MICROSOFT NOT FOUND:');
      debugPrint(tester.binding.renderViewElement?.toStringDeep());
      rethrow;
    }
    await tester.tap(find.descendant(of: find.byType(ApplicationCard), matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // Delete Google
    await tester.tap(searchField.first);
    await tester.pumpAndSettle();
    await tester.enterText(searchField.first, googleName);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.text(googleName), findsWidgets, reason: 'Google should be found before deleting');
    await tester.tap(find.descendant(of: find.byType(ApplicationCard), matching: find.byIcon(Icons.more_vert)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    print('✅ Search and Filter Workflow erfolgreich durchlaufen.');
  });
}
