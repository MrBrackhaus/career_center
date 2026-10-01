/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:developer' show log;

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Rohdaten der gebündelten Unicode-Schrift (Noto Sans, SIL OFL 1.1, siehe
/// `assets/fonts/OFL.txt`).
///
/// Die Standard-PDF-Schriften (Type1 Helvetica) können nur Latin-1 darstellen,
/// also z.B. kein €, –, „“ oder polnische/türkische/kyrillische Zeichen.
///
/// [ByteData] lässt sich an Isolates (z.B. `compute`) übergeben; die
/// [pw.Font]-Objekte werden erst mit [toTheme] im jeweiligen Isolate erzeugt.
class PdfFontData {
  final ByteData regular;
  final ByteData bold;

  const PdfFontData({required this.regular, required this.bold});

  /// Erzeugt ein [pw.ThemeData] mit Noto Sans. Kursiv nutzt mangels eigener
  /// Kursiv-Datei die normale bzw. fette Variante.
  pw.ThemeData toTheme() {
    final base = pw.Font.ttf(regular);
    final boldFont = pw.Font.ttf(bold);
    return pw.ThemeData.withFont(
      base: base,
      bold: boldFont,
      italic: base,
      boldItalic: boldFont,
    );
  }
}

/// Lädt und cached die gebündelten PDF-Schriften.
class PdfFonts {
  PdfFonts._();

  static const String regularAsset = 'assets/fonts/NotoSans-Regular.ttf';
  static const String boldAsset = 'assets/fonts/NotoSans-Bold.ttf';

  static PdfFontData? _cache;

  /// Lädt die Schriftdaten aus dem Asset-Bundle. Gibt `null` zurück, wenn sie
  /// nicht geladen werden können (dann wird auf Helvetica zurückgefallen).
  static Future<PdfFontData?> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    try {
      final regular = await rootBundle.load(regularAsset);
      final bold = await rootBundle.load(boldAsset);
      return _cache = PdfFontData(regular: regular, bold: bold);
    } catch (e, st) {
      log('PDF-Schriften konnten nicht geladen werden: $e',
          name: 'PdfFonts', error: e, stackTrace: st);
      return null;
    }
  }

  /// Theme mit Unicode-Schrift, bei fehlenden Daten Helvetica als Fallback.
  static pw.ThemeData themeFrom(PdfFontData? data) {
    if (data != null) return data.toTheme();
    return pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      italic: pw.Font.helveticaOblique(),
      boldItalic: pw.Font.helveticaBoldOblique(),
    );
  }

  /// Bequemer Einstieg für Code im Haupt-Isolate.
  static Future<pw.ThemeData> loadTheme() async => themeFrom(await load());
}
