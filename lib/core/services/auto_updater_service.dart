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
            // Finde das .exe Asset
            final assets = data['assets'] as List;
            String? downloadUrl;
            for (var asset in assets) {
              if (asset['name'].toString().toLowerCase().endsWith('.exe')) {
                downloadUrl = asset['browser_download_url'];
                break;
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
      final savePath = p.join(tempDir.path, 'CareerCenter_Update.exe');

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

  Future<void> installAndRestart(File installerFile) async {
    try {
      // Startet die .exe im Hintergrund und schließt die App
      await Process.start(
        installerFile.path,
        ['/SILENT'], // Falls Inno Setup oder NSIS genutzt wird
        mode: ProcessStartMode.detached,
      );
      
      // Die Flutter App wird sofort beendet
      exit(0);
    } catch (e) {
      log('Fehler beim Starten des Installers: $e');
    }
  }
}
