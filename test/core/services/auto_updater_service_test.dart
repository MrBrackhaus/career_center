import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
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
    group('versionFromTag', () {
    test('entfernt nur ein führendes v', () {
      expect(versionFromTag('v1.2.3'), '1.2.3');
      expect(versionFromTag('V1.2.3'), '1.2.3');
      expect(versionFromTag('1.2.3'), '1.2.3');
      expect(versionFromTag('v1.2.3-dev'), '1.2.3-dev');
      expect(versionFromTag('v1.0.0-preview'), '1.0.0-preview');
    });
  });

  group('parseSha256Digest', () {
    final hex = 'a' * 64;
    test('akzeptiert sha256:<hex>', () {
      expect(parseSha256Digest('sha256:$hex'), hex);
      expect(parseSha256Digest('SHA256:${hex.toUpperCase()}'), hex);
    });
    test('lehnt fehlende oder ungültige Digests ab', () {
      expect(parseSha256Digest(null), isNull);
      expect(parseSha256Digest('sha512:$hex'), isNull);
      expect(parseSha256Digest('sha256:abc'), isNull);
      expect(parseSha256Digest(42), isNull);
    });
  });

  group('parseRelease', () {
    Map<String, dynamic> release({
      String tag = 'v1.2.0',
      List<Map<String, dynamic>>? assets,
    }) =>
        {
          'tag_name': tag,
          'body': 'Notes',
          'assets': assets ??
              [
                {
                  'name': 'CareerCenter.exe',
                  'browser_download_url': 'https://x/CareerCenter.exe',
                },
                {
                  'name': 'CareerCenter_Windows.zip',
                  'browser_download_url': 'https://x/CareerCenter_Windows.zip',
                  'digest': 'sha256:${'b' * 64}',
                },
              ],
        };

    test('liefert UpdateInfo für neuere Version und bevorzugt .zip', () {
      final info = parseRelease(release(), '1.0.0');
      expect(info, isNotNull);
      expect(info!.version, '1.2.0');
      expect(info.downloadUrl, 'https://x/CareerCenter_Windows.zip');
      expect(info.sha256, 'b' * 64);
      expect(info.releaseNotes, 'Notes');
    });

    test('null bei gleicher oder älterer Version', () {
      expect(parseRelease(release(tag: 'v1.0.0'), '1.0.0'), isNull);
      expect(parseRelease(release(tag: 'v0.9.0'), '1.0.0'), isNull);
    });

    test('null bei unparsebarem Tag', () {
      expect(parseRelease(release(tag: 'latest'), '1.0.0'), isNull);
    });

    test('ohne Digest ist sha256 null', () {
      final info = parseRelease(
        release(assets: [
          {'name': 'a.zip', 'browser_download_url': 'https://x/a.zip'},
        ]),
        '1.0.0',
      );
      expect(info, isNotNull);
      expect(info!.sha256, isNull);
    });

    test('null ohne passendes Asset', () {
      expect(parseRelease(release(assets: []), '1.0.0'), isNull);
    });
  });

  group('PowerShell-Skript', () {
    test('psQuote verdoppelt Apostrophe', () {
      expect(psQuote("C:\\Users\\O'Neil"), "'C:\\Users\\O''Neil'");
    });

    test('buildUpdateScript quotet Pfade und nutzt die PID', () {
      final script = buildUpdateScript(
        zipPath: "C:\\Users\\Jürgen O'Neil\\AppData\\Local\\Temp\\u.zip",
        appDir: 'C:\\Program Files\\Career Center',
        exePath: 'C:\\Program Files\\Career Center\\career_center.exe',
        pid: 4711,
      );
      expect(script, contains(r"$zip = 'C:\Users\Jürgen O''Neil\AppData\Local\Temp\u.zip'"));
      expect(script, contains(r'$appPid = 4711'));
      expect(script, contains('WaitForExit(60000)'));
      expect(script, contains('Expand-Archive -LiteralPath'));
      expect(script, contains(r'Remove-Item -LiteralPath $PSCommandPath'));
      expect(script, isNot(contains('\n\n')));
    });
  });

  group('sha256OfFile', () {
    test('berechnet den SHA-256 einer Datei', () async {
      final dir = Directory.systemTemp.createTempSync('sha_test');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/x.bin')..writeAsStringSync('hallo');
      expect(
        await sha256OfFile(file),
        sha256.convert(utf8.encode('hallo')).toString(),
      );
    });
  });
});
}
