import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/imap_service.dart';

Mailbox _box(String path, {List<MailboxFlag>? flags, String sep = '/'}) {
  final name = path.split(sep).last;
  return Mailbox(
    encodedName: name,
    encodedPath: path,
    flags: flags ?? <MailboxFlag>[],
    pathSeparator: sep,
  );
}

void main() {
  group('ImapService.findSentMailbox', () {
    test('bevorzugt das \\Sent-Flag vor Namenstreffern', () {
      final boxes = [
        _box('INBOX'),
        _box('Sent'),
        _box('Archiv/Ausgang', flags: [MailboxFlag.sent]),
      ];
      expect(ImapService.findSentMailbox(boxes)?.path, 'Archiv/Ausgang');
    });

    test('findet bekannte Namen exakt', () {
      expect(
        ImapService.findSentMailbox([_box('INBOX'), _box('Gesendete Objekte')])
            ?.path,
        'Gesendete Objekte',
      );
      expect(
        ImapService.findSentMailbox([_box('[Gmail]/Sent Mail')])?.path,
        '[Gmail]/Sent Mail',
      );
      expect(
        ImapService.findSentMailbox([_box('INBOX.Gesendet', sep: '.')])?.path,
        'INBOX.Gesendet',
      );
    });

    test('ignoriert Ordner, die "sent" nur enthalten', () {
      final boxes = [
        _box('INBOX'),
        _box('Consent Forms'),
        _box('Unsent Drafts'),
        _box('Postausgang'),
        _box('Outbox'),
      ];
      expect(ImapService.findSentMailbox(boxes), isNull);
    });
  });
}
