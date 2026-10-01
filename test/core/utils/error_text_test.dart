import 'dart:io';

import 'package:career_center/core/utils/error_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('entfernt Exception-Präfixe', () {
    expect(friendlyError(Exception('Speichern fehlgeschlagen')),
        'Speichern fehlgeschlagen');
    expect(friendlyError(Exception('KI-Fehler: Exception: kaputt')),
        'KI-Fehler: kaputt');
  });

  test('übersetzt Netzwerkfehler', () {
    expect(friendlyError(const SocketException('Connection refused')),
        contains('Server nicht erreichbar'));
  });
}
