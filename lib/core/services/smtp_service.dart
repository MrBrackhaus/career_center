import 'dart:convert';
import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:mime/mime.dart';

import 'imap_service.dart';

/// Wandelt einen Klartext-Body in sicheres HTML um: alle HTML-Sonderzeichen
/// werden escaped, Zeilenumbrüche werden zu `<br>`.
String plainTextToHtml(String bodyText) {
  final escaped = const HtmlEscape().convert(bodyText);
  final withBreaks = escaped
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll('\n', '<br>');
  return '<p>$withBreaks</p>';
}

/// Wählt den Authentifizierungsmechanismus anhand der vom Server
/// angekündigten Mechanismen. Bevorzugt PLAIN, dann LOGIN, dann CRAM-MD5.
/// Gibt `null` zurück, wenn kein unterstützter Passwort-Mechanismus
/// angeboten wird. Ist die Liste leer (Server kündigt nichts an), wird
/// PLAIN als Fallback verwendet.
AuthMechanism? chooseSmtpAuthMechanism(List<AuthMechanism> offered) {
  if (offered.isEmpty) return AuthMechanism.plain;
  const preference = [
    AuthMechanism.plain,
    AuthMechanism.login,
    AuthMechanism.cramMd5,
  ];
  for (final mechanism in preference) {
    if (offered.contains(mechanism)) return mechanism;
  }
  return null;
}

class SmtpService {
  static const Duration _timeout = Duration(seconds: 30);

  Future<void> sendEmail({
    required String server,
    required int port,
    required String userEmail,
    required String recipientEmail,
    required String subject,
    required String bodyText,
    List<File> attachments = const [],
  }) async {
    final password = await ImapService.getPassword();
    if (password.isEmpty) {
      throw Exception(
        'Passwort konnte nicht entschlüsselt werden. Bitte in den Einstellungen neu eingeben.',
      );
    }

    final client = SmtpClient('career_center', isLogEnabled: false);
    final implicitTls = port == 465;

    try {
      await client
          .connectToServer(server, port, isSecure: implicitTls)
          .timeout(_timeout);
      await client.ehlo().timeout(_timeout);

      if (!implicitTls) {
        // Niemals über eine unverschlüsselte Verbindung authentifizieren.
        if (!client.serverInfo.supportsStartTls) {
          throw Exception(
            'Der SMTP-Server bietet keine verschlüsselte Verbindung (STARTTLS) an. '
            'Aus Sicherheitsgründen wird das Passwort nicht unverschlüsselt übertragen. '
            'Bitte Port 465 (SSL/TLS) oder einen Server mit STARTTLS verwenden.',
          );
        }
        // Nach STARTTLS müssen die Fähigkeiten neu ermittelt werden.
        client.serverInfo.capabilities.clear();
        client.serverInfo.authMechanisms.clear();
        final tlsResponse = await client.startTls().timeout(_timeout);
        if (!tlsResponse.isOkStatus) {
          throw Exception(
            'Verschlüsselte Verbindung (STARTTLS) konnte nicht aufgebaut werden: '
            '${tlsResponse.message ?? tlsResponse}',
          );
        }
      }

      final mechanism = chooseSmtpAuthMechanism(
        client.serverInfo.authMechanisms,
      );
      if (mechanism == null) {
        throw Exception(
          'Der SMTP-Server unterstützt kein kompatibles Anmeldeverfahren '
          '(PLAIN, LOGIN oder CRAM-MD5).',
        );
      }
      await client
          .authenticate(userEmail, password, mechanism)
          .timeout(_timeout);

      final builder =
          MessageBuilder.prepareMultipartAlternativeMessage(
              plainText: bodyText,
              htmlText: plainTextToHtml(bodyText),
            )
            ..from = [MailAddress(null, userEmail)]
            ..to = [MailAddress(null, recipientEmail)]
            ..subject = subject;

      for (final file in attachments) {
        if (!await file.exists()) {
          throw Exception('Anhang nicht gefunden: ${file.path}');
        }
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        await builder.addFile(file, MediaType.fromText(mimeType));
      }

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client
          .sendMessage(mimeMessage)
          .timeout(const Duration(minutes: 2));

      if (!sendResponse.isOkStatus) {
        throw Exception(
          'Server lehnte die E-Mail ab: ${sendResponse.toString()}',
        );
      }
    } finally {
      try {
        await client.disconnect();
      } catch (_) {
        // Verbindung war evtl. nie aufgebaut – ignorieren.
      }
    }
  }
}
