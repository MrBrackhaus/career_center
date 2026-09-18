import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'dart:developer';

class UpdateInfo {
  final String version;
  final String releaseNotes;
  final String downloadUrl;

  UpdateInfo({
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
  });
}

class AutoUpdaterService {
  final Dio _dio = Dio();
  final String repoOwner = 'MrBrackhaus';
  final String repoName = 'career_center';

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final tagName = data['tag_name'] as String;
        // GitHub tag is usually like "v1.2.3" or "1.2.3"
        final remoteVersionString = tagName.replaceAll('v', '');
        
        final packageInfo = await PackageInfo.fromPlatform();
        final localVersionString = packageInfo.version;

        try {
          final remoteVersion = Version.parse(remoteVersionString);
          final localVersion = Version.parse(localVersionString);

          if (remoteVersion > localVersion) {
            // Finde das .zip Asset (da Windows Releases als .zip gepackt werden)
            final assets = data['assets'] as List;
            String? downloadUrl;
            for (var asset in assets) {
              if (asset['name'].toString().toLowerCase().endsWith('.zip')) {
                downloadUrl = asset['browser_download_url'];
                break;
              }
            }

            // Fallback auf .exe falls in Zukunft doch InnoSetup genutzt wird
            if (downloadUrl == null) {
              for (var asset in assets) {
                if (asset['name'].toString().toLowerCase().endsWith('.exe')) {
                  downloadUrl = asset['browser_download_url'];
                  break;
                }
              }
            }

            if (downloadUrl != null) {
              return UpdateInfo(
                version: remoteVersionString,
                releaseNotes: data['body'] ?? 'Keine Release Notes vorhanden.',
                downloadUrl: downloadUrl,
              );
            }
          }
        } catch (e) {
          log('Fehler beim Versionsvergleich: $e');
        }
      }
    } catch (e) {
      log('Fehler beim Abrufen der Updates: $e');
    }
    return null;
  }

  Future<File?> downloadUpdate(String url, Function(double) onProgress) async {
    try {
      final tempDir = await getTemporaryDirectory();
      
      // Determine filename from URL
      final isZip = url.toLowerCase().endsWith('.zip');
      final fileName = isZip ? 'CareerCenter_Update.zip' : 'CareerCenter_Update.exe';
      final savePath = p.join(tempDir.path, fileName);

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );
      
      return File(savePath);
    } catch (e) {
      log('Fehler beim Download: $e');
      return null;
    }
  }

  Future<void> installAndRestart(File downloadedFile) async {
    try {
      if (downloadedFile.path.toLowerCase().endsWith('.exe')) {
        // Klassischer Installer
        await Process.start(
          downloadedFile.path,
          ['/SILENT'],
          mode: ProcessStartMode.detached,
        );
        exit(0);
      } else if (downloadedFile.path.toLowerCase().endsWith('.zip')) {
        // Portable ZIP Update
        final appExecutable = Platform.resolvedExecutable;
        final appDir = File(appExecutable).parent.path;
        
        final tempDir = downloadedFile.parent;
        final batFile = File(p.join(tempDir.path, 'update_career_center.bat'));
        
        final script = '''
@echo off
echo Warte auf Beendigung der App...
timeout /t 3 /nobreak > NUL

echo Entpacke Update...
powershell -Command "Expand-Archive -Path '${downloadedFile.path}' -DestinationPath '$appDir' -Force"

echo Starte App neu...
start "" "$appExecutable"

del "%~f0"
''';
        await batFile.writeAsString(script);

        // Führe BAT-Skript losgelöst aus
        await Process.start(
          'cmd',
          ['/c', batFile.path],
          mode: ProcessStartMode.detached,
        );
        
        // Flutter App beenden
        exit(0);
      }
    } catch (e) {
      log('Fehler beim Installieren: $e');
    }
  }
}
