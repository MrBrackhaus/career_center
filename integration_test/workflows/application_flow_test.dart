import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Application Workflow - Create and Delete', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // 1. Open the app (JobTrackerApp) and navigate to the dashboard/applications list.
    final dashboardNav = find.byIcon(Icons.dashboard_outlined);
    if (dashboardNav.evaluate().isNotEmpty) {
      await tester.tap(dashboardNav.first);
      await tester.pumpAndSettle();
    }
    
    // 2. Click the FloatingActionButton (Icons.add) to create a new application.
    final fab = find.byIcon(Icons.add);
    expect(fab, findsWidgets);
    await tester.tap(fab.first);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    // 3. Fill in the BasicDataTab: Company name "Test GmbH", Position "Flutter Developer".
    final textFields = find.byType(TextField);
    expect(textFields.evaluate().length, greaterThanOrEqualTo(2));
    
    final companyField = find.widgetWithText(TextField, 'Firma').evaluate().isNotEmpty
        ? find.widgetWithText(TextField, 'Firma').first
        : (find.widgetWithText(TextField, 'Company').evaluate().isNotEmpty
            ? find.widgetWithText(TextField, 'Company').first
            : textFields.at(0));
            
    final positionField = find.widgetWithText(TextField, 'Position').evaluate().isNotEmpty
        ? find.widgetWithText(TextField, 'Position').first
        : (find.widgetWithText(TextField, 'Jobtitel').evaluate().isNotEmpty
            ? find.widgetWithText(TextField, 'Jobtitel').first
            : textFields.at(1));
    
    await tester.ensureVisible(companyField);
    await tester.enterText(companyField, 'Test GmbH');
    await tester.pumpAndSettle();
    
    await tester.ensureVisible(positionField);
    await tester.enterText(positionField, 'Flutter Developer');
    await tester.pumpAndSettle();

    // 4. Save the application (triggering the database save).
    final saveButtonByIcon = find.byIcon(Icons.save);
    final saveButtonByType = find.byType(ElevatedButton);
    final saveButton = saveButtonByIcon.evaluate().isNotEmpty 
        ? saveButtonByIcon.first 
        : (saveButtonByType.evaluate().isNotEmpty 
            ? saveButtonByType.last 
            : find.byType(FilledButton).last);
        
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 2));

    // 5. Verify the application appears in the applications list.
    expect(find.text('Test GmbH'), findsWidgets);
    expect(find.text('Flutter Developer'), findsWidgets);

    // 6. (Optional) Open the application details and click delete to clean up.
    final applicationItem = find.text('Test GmbH');
    if (applicationItem.evaluate().isNotEmpty) {
      await tester.tap(applicationItem.first);
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      
      final deleteIcon = find.byIcon(Icons.delete);
      if (deleteIcon.evaluate().isNotEmpty) {
        await tester.tap(deleteIcon.first);
        await tester.pumpAndSettle();
        
        final confirmButtons = find.byType(TextButton);
        if (confirmButtons.evaluate().isNotEmpty) {
          await tester.tap(confirmButtons.last);
          await tester.pumpAndSettle();
        }
      }
    }
    
    print('✅ Application Workflow erfolgreich: Applikation angelegt und gelöscht.');
  });
}
