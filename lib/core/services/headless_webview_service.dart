/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:developer' show log;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Service für das Rendern von JavaScript-lastigen Webseiten im Hintergrund.
///
/// Nutzt eine unsichtbare (headless) WebView, um SPAs (React, Angular, Vue)
/// und andere JS-gerenderte Seiten vollständig zu laden und das fertige DOM
/// als HTML-String zurückzugeben.
///
/// **Einschränkung:** Kann keine interaktiven Captchas lösen – dafür bleibt
/// der Companion-Server (Browser-Extension) erforderlich.
class HeadlessWebViewService {
  static final HeadlessWebViewService _instance =
      HeadlessWebViewService._internal();

  factory HeadlessWebViewService() => _instance;

  HeadlessWebViewService._internal();

  /// Lädt eine URL in einer unsichtbaren WebView, wartet auf JS-Rendering,
  /// und gibt das fertige HTML zurück.
  ///
  /// [url] – Die zu rendernde URL
  /// [timeout] – Maximale Wartezeit (Default: 15 Sekunden)
  ///
  /// Gibt `null` zurück bei Timeout oder Fehler.
  Future<String?> renderPage(
    String url, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final completer = Completer<String?>();
    HeadlessInAppWebView? headlessWebView;

    try {
      headlessWebView = HeadlessInAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          userAgent:
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          // Ressourcen sparen: keine Bilder/Medien laden
          blockNetworkImage: true,
          mediaPlaybackRequiresUserGesture: true,
        ),
        onLoadStop: (controller, loadedUrl) async {
          // Warte 2 Sekunden für nachträgliches JS-Rendering (SPA lazy loading)
          await Future.delayed(const Duration(seconds: 2));

          try {
            final html = await controller.evaluateJavascript(
              source: 'document.documentElement.outerHTML',
            );
            if (!completer.isCompleted) {
              completer.complete(html?.toString());
            }
          } catch (e) {
            log('HeadlessWebView JS evaluation error: $e',
                name: 'HeadlessWebViewService');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }
        },
        onLoadError: (controller, loadedUrl, code, message) {
          log('HeadlessWebView load error ($code): $message',
              name: 'HeadlessWebViewService');
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        onLoadHttpError: (controller, loadedUrl, statusCode, description) {
          log('HeadlessWebView HTTP error ($statusCode): $description',
              name: 'HeadlessWebViewService');
          // Manche Seiten geben 403 zurück, aber rendern trotzdem
          // → wir warten trotzdem auf onLoadStop
        },
      );

      await headlessWebView.run();

      // Timeout-Guard
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () {
          log('HeadlessWebView timeout after ${timeout.inSeconds}s',
              name: 'HeadlessWebViewService');
          return null;
        },
      );

      return result;
    } catch (e) {
      log('HeadlessWebView unexpected error: $e',
          name: 'HeadlessWebViewService');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    } finally {
      try {
        await headlessWebView?.dispose();
      } catch (_) {
        // Ignore dispose errors
      }
    }
  }
}
