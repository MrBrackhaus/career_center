import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:career_center/data/database/app_database.dart';
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Reset Data', (WidgetTester tester) async {
    print('Starte Cleanup...');
    final db = AppDatabase();
    
    try {
      print('Lösche alle Bewerbungen...');
      final deleted = await db.delete(db.applications).go();
      print('$deleted Bewerbungen gelöscht.');

      print('Setze Sprache auf Deutsch (de)...');
      await db.settingsDao.insertOrUpdateSetting(
        const Setting(key: 'app_language', value: 'de'),
      );
      print('Sprache erfolgreich zurückgesetzt.');
      
    } catch (e, st) {
      print('Fehler beim Cleanup: $e');
      print(st);
    } finally {
      await db.close();
      print('Cleanup beendet.');
    }
  });
}
