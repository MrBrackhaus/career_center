import 'package:career_center/core/services/smtp_service.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('plainTextToHtml', () {
    test('escaped HTML-Sonderzeichen', () {
      final html = plainTextToHtml('<script>alert("x")</script> & Co');
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
      expect(html, contains('&amp; Co'));
    });

    test('wandelt Zeilenumbrüche in <br> um', () {
      expect(plainTextToHtml('a\nb\r\nc'), '<p>a<br>b<br>c</p>');
    });
  });

  group('chooseSmtpAuthMechanism', () {
    test('bevorzugt PLAIN vor LOGIN', () {
      expect(
        chooseSmtpAuthMechanism([AuthMechanism.login, AuthMechanism.plain]),
        AuthMechanism.plain,
      );
    });

    test('nutzt LOGIN, wenn PLAIN fehlt', () {
      expect(
        chooseSmtpAuthMechanism([AuthMechanism.login, AuthMechanism.xoauth2]),
        AuthMechanism.login,
      );
    });

    test('null bei nur XOAUTH2', () {
      expect(chooseSmtpAuthMechanism([AuthMechanism.xoauth2]), isNull);
    });

    test('PLAIN als Fallback, wenn nichts angekündigt', () {
      expect(chooseSmtpAuthMechanism([]), AuthMechanism.plain);
    });
  });
}
