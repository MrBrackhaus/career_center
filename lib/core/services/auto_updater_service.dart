import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';

class UpdateInfo {
  final String version;
  final String releaseNotes;
  final String downloadUrl;

  /// Expected SHA-256 of the asset (lowercase hex), taken from the `digest`
  /// field of the GitHub releases API. `null` if GitHub did not provide one.
  final String? sha256;

  UpdateInfo({
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    this.sha256,
  });
}

/// Thrown when the downloaded update does not match the expected checksum.
class UpdateIntegrityException implements Exception {
  final String expected;
  final String actual;
  UpdateIntegrityException(this.expected, this.actual);

  @override
  String toString() =>
      'Prüfsumme des Updates stimmt nicht überein (erwartet $expected, erhalten $actual)';
}

/// Strips a single leading `v`/`V` from a git tag ("v1.2.3" -> "1.2.3").
String versionFromTag(String tagName) {
  final tag = tagName.trim();
  if (tag.startsWith('v') || tag.startsWith('V')) return tag.substring(1);
  return tag;
}

/// Parses a GitHub asset digest like `sha256:<64 hex chars>`.
/// Returns the lowercase hex digest, or `null` if missing/unsupported.
String? parseSha256Digest(Object? digest) {
  if (digest is! String) return null;
  const prefix = 'sha256:';
  if (!digest.toLowerCase().startsWith(prefix)) return null;
  final hex = digest.substring(prefix.length).trim().toLowerCase();
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hex)) return null;
  return hex;
}

/// Builds an [UpdateInfo] from a GitHub "latest release" JSON object if the
/// release is newer than [localVersion] and contains a usable asset.
UpdateInfo? parseRelease(Map<String, dynamic> data, String localVersion) {
  final tagName = data['tag_name'];
  if (tagName is! String) return null;
  final remoteVersionString = versionFromTag(tagName);

  final Version remoteVersion;
  final Version local;
  try {
    remoteVersion = Version.parse(remoteVersionString);
    local = Version.parse(localVersion);
  } on FormatException catch (e) {
    log('Fehler beim Versionsvergleich: $e', name: 'AutoUpdater');
    return null;
  }
  if (remoteVersion <= local) return null;

  final assets = (data['assets'] as List?) ?? const [];
  Map? asset;
  // Windows-Releases werden als .zip gepackt; .exe als Fallback (Installer).
  for (final ext in const ['.zip', '.exe']) {
    for (final a in assets) {
      if (a is Map && a['name'].toString().toLowerCase().endsWith(ext)) {
        asset = a;
        break;
      }
    }
    if (asset != null) break;
  }
  final downloadUrl = asset?['browser_download_url'];
  if (asset == null || downloadUrl is! String) return null;

  final sha = parseSha256Digest(asset['digest']);
  if (sha == null) {
    log('Release-Asset enthält keinen SHA-256-Digest – Integrität kann nicht geprüft werden.',
        name: 'AutoUpdater', level: 900);
  }

  return UpdateInfo(
    version: remoteVersionString,
    releaseNotes: (data['body'] as String?) ?? 'Keine Release Notes vorhanden.',
    downloadUrl: downloadUrl,
    sha256: sha,
  );
}

/// Quotes [value] as a single-quoted PowerShell string literal.
String psQuote(String value) => "'${value.replaceAll("'", "''")}'";

/// PowerShell script that waits for the app (by PID) to exit, extracts the
/// update into the app directory, restarts the app and cleans up after itself.
String buildUpdateScript({
  required String zipPath,
  required String appDir,
  required String exePath,
  required int pid,
  int waitTimeoutMs = 60000,
}) {
  final lines = <String>[
    r"$ErrorActionPreference = 'Stop'",
    '\$zip = ${psQuote(zipPath)}',
    '\$appDir = ${psQuote(appDir)}',
    '\$exe = ${psQuote(exePath)}',
    '\$appPid = $pid',
    r"$logFile = Join-Path $env:TEMP 'career_center_update.log'",
    r'try {',
    r'  $proc = Get-Process -Id $appPid -ErrorAction SilentlyContinue',
    r'  if ($proc) {',
    '    if (-not \$proc.WaitForExit($waitTimeoutMs)) {',
    r'      Stop-Process -Id $appPid -Force -ErrorAction SilentlyContinue',
    r'      Start-Sleep -Seconds 2',
    r'    }',
    r'  }',
    r'  $ok = $false',
    r'  for ($i = 0; ($i -lt 10) -and (-not $ok); $i++) {',
    r'    try {',
    r'      Expand-Archive -LiteralPath $zip -DestinationPath $appDir -Force',
    r'      $ok = $true',
    r'    } catch {',
    r'      $lastError = $_',
    r'      Start-Sleep -Seconds 1',
    r'    }',
    r'  }',
    r"  if (-not $ok) { throw $lastError }",
    r'} catch {',
    r'  ($_ | Out-String) | Out-File -FilePath $logFile -Append -Encoding utf8',
    r'}',
    r'Start-Process -FilePath $exe -WorkingDirectory $appDir',
    r'Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue',
    r'Remove-Item -LiteralPath $PSCommandPath -Force -ErrorAction SilentlyContinue',
  ];
  return '${lines.join('\r\n')}\r\n';
}

/// Computes the lowercase hex SHA-256 of [file] without loading it fully.
Future<String> sha256OfFile(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
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

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final packageInfo = await PackageInfo.fromPlatform();
        return parseRelease(
          response.data as Map<String, dynamic>,
          packageInfo.version,
        );
      }
    } catch (e) {
      log('Fehler beim Abrufen der Updates: $e', name: 'AutoUpdater');
    }
    return null;
  }

  /// Downloads the update. If [expectedSha256] is given, the file's SHA-256
  /// is verified and an [UpdateIntegrityException] is thrown on mismatch
  /// (the file is deleted). Returns `null` on network errors.
  Future<File?> downloadUpdate(
    String url,
    Function(double) onProgress, {
    String? expectedSha256,
  }) async {
    final File file;
    try {
      final tempDir = await getTemporaryDirectory();

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
      file = File(savePath);
    } catch (e) {
      log('Fehler beim Download: $e', name: 'AutoUpdater');
      return null;
    }

    if (expectedSha256 == null) {
      log('Kein SHA-256-Digest vorhanden – Download wird ungeprüft verwendet.',
          name: 'AutoUpdater', level: 900);
      return file;
    }
    final actual = await sha256OfFile(file);
    if (actual != expectedSha256.toLowerCase()) {
      try {
        await file.delete();
      } catch (_) {}
      throw UpdateIntegrityException(expectedSha256, actual);
    }
    return file;
  }

  /// Installs the update and terminates the app. [beforeExit] runs right
  /// before `exit(0)` (e.g. to close the database cleanly).
  Future<void> installAndRestart(
    File downloadedFile, {
    Future<void> Function()? beforeExit,
  }) async {
    final lower = downloadedFile.path.toLowerCase();
    try {
      if (lower.endsWith('.exe')) {
        // Klassischer Installer
        await Process.start(
          downloadedFile.path,
          ['/SILENT'],
          mode: ProcessStartMode.detached,
        );
      } else if (lower.endsWith('.zip')) {
        // Portable ZIP Update
        final appExecutable = Platform.resolvedExecutable;
        final appDir = File(appExecutable).parent.path;
        final scriptFile =
            File(p.join(downloadedFile.parent.path, 'update_career_center.ps1'));

        final script = buildUpdateScript(
          zipPath: downloadedFile.path,
          appDir: appDir,
          exePath: appExecutable,
          pid: pid,
        );
        // UTF-8 mit BOM, damit Windows PowerShell 5.1 Umlaute korrekt liest.
        await scriptFile.writeAsBytes(
          [0xEF, 0xBB, 0xBF, ...utf8.encode(script)],
          flush: true,
        );

        await Process.start(
          'powershell.exe',
          [
            '-NoProfile',
            '-ExecutionPolicy',
            'Bypass',
            '-WindowStyle',
            'Hidden',
            '-File',
            scriptFile.path,
          ],
          mode: ProcessStartMode.detached,
        );
      } else {
        log('Unbekannter Update-Dateityp: ${downloadedFile.path}',
            name: 'AutoUpdater', level: 1000);
        return;
      }
    } catch (e) {
      log('Fehler beim Installieren: $e', name: 'AutoUpdater', level: 1000);
      rethrow;
    }

    if (beforeExit != null) {
      try {
        await beforeExit();
      } catch (e) {
        log('Fehler vor dem Beenden: $e', name: 'AutoUpdater', level: 900);
      }
    }
    exit(0);
  }
}
