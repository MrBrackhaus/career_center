import 'dart:io';
import 'package:enough_mail/enough_mail.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'imap_service.dart';

class SmtpService {
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
      throw Exception('Passwort konnte nicht entschlüsselt werden. Bitte in den Einstellungen neu eingeben.');
    }

    final client = SmtpClient('career_center', isLogEnabled: false);
    
    try {
      await client.connectToServer(server, port, isSecure: port == 465);
      await client.ehlo();
      await client.authenticate(userEmail, password, AuthMechanism.plain);

      final builder = MessageBuilder.prepareMultipartAlternativeMessage(
        plainText: bodyText,
        htmlText: '<p>${bodyText.replaceAll('\n', '<br>')}</p>',
      )
        ..from = [MailAddress(null, userEmail)]
        ..to = [MailAddress(null, recipientEmail)]
        ..subject = subject;

      for (final file in attachments) {
        if (await file.exists()) {
          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          final mimeParts = mimeType.split('/');
          
          final primaryType = MediaPrimaryType.values.firstWhere(
            (e) => e.name == mimeParts[0],
            orElse: () => MediaPrimaryType.application,
          );
          
          builder.addFile(
            file,
            MediaSubtype(primaryType, mimeParts[1]),
          );
        }
      }

      final mimeMessage = builder.buildMimeMessage();
      final sendResponse = await client.sendMessage(mimeMessage);
      
      if (!sendResponse.isOkStatus) {
        throw Exception('Server lehnte die E-Mail ab: ${sendResponse.toString()}');
      }
    } finally {
      await client.disconnect();
    }
  }
}
