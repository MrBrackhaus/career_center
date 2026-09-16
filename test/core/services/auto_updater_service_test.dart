import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:career_center/core/services/auto_updater_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoUpdaterService', () {
    setUp(() {
      PackageInfo.setMockInitialValues(
        appName: 'Career Center',
        packageName: 'com.example.career_center',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
    });

    test('checkForUpdates returned null bei Netzwerkfehler', () async {
      // Da wir in Testumgebungen ohne Mock HTTP Server echte Requests blocken sollten 
      // (oder sie schlagen fehl), sollte die Methode sicher null zurückgeben und nicht crashen.
      final service = AutoUpdaterService();
      
      final result = await service.checkForUpdates();
      
      // Ohne echtes Repo oder bei 404 (da es ein Beispielrepo MrBrackhaus/career_center ist, das ggf. privat ist)
      // erwarten wir, dass die Exception gefangen wird und null zurückkommt.
      expect(result, isNull);
    });
  });
}
