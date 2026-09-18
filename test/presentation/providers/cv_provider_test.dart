import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/providers/database_provider.dart';
import 'package:career_center/presentation/providers/cv_provider.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
    );
  });

  tearDown(() async {
    await database.close();
    container.dispose();
  });

  test('CvNotifier updates and retrieves customItems', () async {
    // Add custom item using the updated 7-arg method
    await container.read(cvNotifierProvider).addCustomItem(
      null, // applicationId
      'TestSection',
      'Test Title',
      'Test Subtitle',
      '2026-09',
      'Test Description',
      1,
    );

    // Read state
    final cvState = await container.read(cvProvider(null).future);
    expect(cvState.customItems.length, 1);
    
    final item = cvState.customItems.first;
    expect(item.sectionName, 'TestSection');
    expect(item.title, 'Test Title');
    expect(item.subtitle, 'Test Subtitle');
    expect(item.dateRange, '2026-09');
    expect(item.description, 'Test Description');
    expect(item.sortOrder, 1);

    // Update custom item using the patched 8-arg method
    await container.read(cvNotifierProvider).updateCustomItem(
      null,
      item.id,
      'UpdatedSection',
      'Updated Title',
      'Updated Subtitle',
      '2027-01',
      'Updated Description',
      2,
    );

    // Refresh state
    final updatedState = await container.read(cvProvider(null).future);
    expect(updatedState.customItems.length, 1);
    
    final updatedItem = updatedState.customItems.first;
    expect(updatedItem.sectionName, 'UpdatedSection');
    expect(updatedItem.title, 'Updated Title');
    expect(updatedItem.subtitle, 'Updated Subtitle');
    expect(updatedItem.dateRange, '2027-01');
    expect(updatedItem.description, 'Updated Description');
    expect(updatedItem.sortOrder, 2);
    
    // Delete custom item
    await container.read(cvNotifierProvider).deleteCustomItem(null, updatedItem.id);
    
    final finalState = await container.read(cvProvider(null).future);
    expect(finalState.customItems.isEmpty, true);
  });
}
