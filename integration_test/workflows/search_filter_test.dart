import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Search and Filter Workflow - Create 3 apps and filter them', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Create first application (Apple)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    // Fill Firma
    await tester.enterText(find.byType(TextFormField).at(0), 'Apple Corp');
    // Fill Position
    await tester.enterText(find.byType(TextFormField).at(1), 'iOS Developer');
    
    // Save
    await tester.ensureVisible(find.byIcon(Icons.save));
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    
    // Go back to Dashboard
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();


    // 2. Create second application (Microsoft)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).at(0), 'Microsoft GmbH');
    await tester.enterText(find.byType(TextFormField).at(1), 'C# Developer');
    
    await tester.ensureVisible(find.byIcon(Icons.save));
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();


    // 3. Create third application (Google)
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextFormField).at(0), 'Google LLC');
    await tester.enterText(find.byType(TextFormField).at(1), 'Go Developer');
    
    await tester.ensureVisible(find.byIcon(Icons.save));
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 4. Navigate to Applications (Kanban) screen
    await tester.tap(find.byIcon(Icons.work_outline));
    await tester.pumpAndSettle();

    // Verify all 3 are visible
    expect(find.text('Apple Corp'), findsOneWidget);
    expect(find.text('Microsoft GmbH'), findsOneWidget);
    expect(find.text('Google LLC'), findsOneWidget);

    // 5. Search for Apple
    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, 'Apple');
    await tester.pumpAndSettle(const Duration(milliseconds: 500)); // Debounce?

    // Verify only Apple is visible
    expect(find.text('Apple Corp'), findsOneWidget);
    expect(find.text('Microsoft GmbH'), findsNothing);
    expect(find.text('Google LLC'), findsNothing);

    // 6. Search for Microsoft
    await tester.enterText(searchField, 'Microsoft');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('Apple Corp'), findsNothing);
    expect(find.text('Microsoft GmbH'), findsOneWidget);
    expect(find.text('Google LLC'), findsNothing);

    // 7. Search for a position (Go Developer)
    await tester.enterText(searchField, 'Go Developer');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    expect(find.text('Apple Corp'), findsNothing);
    expect(find.text('Microsoft GmbH'), findsNothing);
    expect(find.text('Google LLC'), findsOneWidget);
    
    // 8. Clean up (delete all 3)
    await tester.enterText(searchField, ''); // Clear search
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    
    // Delete Apple
    await tester.tap(find.text('Apple Corp'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();

    // Delete Microsoft
    await tester.tap(find.text('Microsoft GmbH'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();

    // Delete Google
    await tester.tap(find.text('Google LLC'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen').last);
    await tester.pumpAndSettle();

    print('✅ Search and Filter Workflow erfolgreich durchlaufen.');
  });
}
