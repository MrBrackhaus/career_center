import 'package:career_center/presentation/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('localeFromStoredValue', () {
    test('erster Start (kein Eintrag) → Deutsch', () {
      expect(localeFromStoredValue(null), const Locale('de'));
    });

    test('"system" und Altwert "" → Systemsprache (null)', () {
      expect(localeFromStoredValue(kSystemLocaleSentinel), isNull);
      expect(localeFromStoredValue(''), isNull);
    });

    test('gespeicherte Sprache bleibt erhalten', () {
      expect(localeFromStoredValue('en'), const Locale('en'));
      expect(localeFromStoredValue('de'), const Locale('de'));
    });
  });
}
