import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/painting.dart' show Color, EdgeInsets;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_fonts.dart';

import '../themes/designs/document_design.dart';

/// Absender-/Empfängerdaten für den Briefkopf des Anschreiben-PDFs.
class CoverLetterPdfHeader {
  final String senderName;
  final String senderProfession;
  final String senderAddress;
  final String senderPhone;
  final String senderEmail;
  final String companyName;
  final String contactName;
  final String companyAddress;
  final String date;

  const CoverLetterPdfHeader({
    this.senderName = '',
    this.senderProfession = '',
    this.senderAddress = '',
    this.senderPhone = '',
    this.senderEmail = '',
    this.companyName = '',
    this.contactName = '',
    this.companyAddress = '',
    this.date = '',
  });
}

class _PdfFonts {
  final pw.Font regular;
  final pw.Font bold;
  final pw.Font italic;
  final pw.Font boldItalic;

  /// true, wenn nur die eingebauten Type1-Schriften (Latin-1) verfügbar sind.
  final bool latin1Only;

  const _PdfFonts(
    this.regular,
    this.bold,
    this.italic,
    this.boldItalic, {
    required this.latin1Only,
  });

  pw.ThemeData get theme => pw.ThemeData.withFont(
    base: regular,
    bold: bold,
    italic: italic,
    boldItalic: boldItalic,
  );
}

/// Erzeugt PDFs für Lebenslauf und Anschreiben – komplett offline.
///
/// Schriften: Unter Windows werden die System-TrueType-Schriften (Arial bzw.
/// Times New Roman) eingebettet, damit alle Unicode-Zeichen (inkl. €) korrekt
/// dargestellt werden. Fehlen diese, wird auf die eingebauten PDF-Schriften
/// Helvetica/Times zurückgefallen; diese decken nur Latin-1 ab (Umlaute ja,
/// € nein), weshalb Texte dann entsprechend ersetzt werden.
class PdfCvGenerator {
  static const double _pxToPt = 0.75; // 96 dpi (Flutter) -> 72 dpi (PDF)

  static final Map<bool, _PdfFonts> _fontCache = {};

  /// Wird während der Generierung gesetzt (Generierung ist synchron pro Aufruf).
  static bool _latin1Only = false;

  // ---------------------------------------------------------------------------
  // Schriften & Text
  // ---------------------------------------------------------------------------

  static Future<_PdfFonts> _loadFonts({required bool serif}) async {
    final cached = _fontCache[serif];
    if (cached != null) return cached;

    _PdfFonts? fonts;
    if (Platform.isWindows) {
      final dir =
          '${Platform.environment['WINDIR'] ?? r'C:\Windows'}\\Fonts\\';
      final names = serif
          ? ['times.ttf', 'timesbd.ttf', 'timesi.ttf', 'timesbi.ttf']
          : ['arial.ttf', 'arialbd.ttf', 'ariali.ttf', 'arialbi.ttf'];
      try {
        final loaded = <pw.Font>[];
        for (final n in names) {
          final bytes = await File('$dir$n').readAsBytes();
          loaded.add(pw.Font.ttf(ByteData.sublistView(bytes)));
        }
        fonts = _PdfFonts(
          loaded[0],
          loaded[1],
          loaded[2],
          loaded[3],
          latin1Only: false,
        );
      } catch (e) {
        debugPrint('PDF: Systemschriften nicht ladbar ($e), nutze Standardschrift.');
      }
    }

    // Gebündelte Unicode-Schrift (Noto Sans) statt Latin-1-Standardschriften,
    // damit €, „“ und nicht-lateinische Zeichen auch ohne Windows-Schriften gehen.
    if (fonts == null) {
      final bundled = await PdfFonts.load();
      if (bundled != null) {
        final regular = pw.Font.ttf(bundled.regular);
        final bold = pw.Font.ttf(bundled.bold);
        fonts = _PdfFonts(regular, bold, regular, bold, latin1Only: false);
      }
    }

    fonts ??= serif
        ? _PdfFonts(
            pw.Font.times(),
            pw.Font.timesBold(),
            pw.Font.timesItalic(),
            pw.Font.timesBoldItalic(),
            latin1Only: true,
          )
        : _PdfFonts(
            pw.Font.helvetica(),
            pw.Font.helveticaBold(),
            pw.Font.helveticaOblique(),
            pw.Font.helveticaBoldOblique(),
            latin1Only: true,
          );
    _fontCache[serif] = fonts;
    return fonts;
  }

  static const Map<String, String> _latin1Replacements = {
    '\u2022': '\u00B7', // •
    '\u2013': '-', // –
    '\u2014': '-', // —
    '\u20AC': 'EUR', // €
    '\u201E': '"', // „
    '\u201C': '"', // “
    '\u201D': '"', // ”
    '\u201A': "'", // ‚
    '\u2018': "'", // ‘
    '\u2019': "'", // ’
    '\u2026': '...', // …
    '\u00A0': ' ',
    '\uFFFC': '',
  };

  /// Macht Text für die eingebauten PDF-Schriften (Latin-1) darstellbar.
  static String _t(String s) {
    if (!_latin1Only) return s;
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final replacement = _latin1Replacements[ch];
      if (replacement != null) {
        buffer.write(replacement);
      } else if (rune <= 0xFF) {
        buffer.write(ch);
      } else {
        buffer.write('?');
      }
    }
    return buffer.toString();
  }

  static PdfColor _pdfColor(Color c) => PdfColor(c.r, c.g, c.b, c.a);

  static PdfColor _primary(Color accentColor) =>
      accentColor == const Color(0x00000000)
      ? PdfColor.fromHex('#1E3A8A')
      : _pdfColor(accentColor);

  static Future<pw.MemoryImage?> _loadProfileImage(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      if (await file.exists()) {
        return pw.MemoryImage(await file.readAsBytes());
      }
    } catch (e) {
      debugPrint('PDF: Profilbild nicht ladbar: $e');
    }
    return null;
  }

  static pw.EdgeInsets _margins(EdgeInsets px) => pw.EdgeInsets.only(
    left: px.left * _pxToPt,
    top: px.top * _pxToPt,
    right: px.right * _pxToPt,
    bottom: px.bottom * _pxToPt,
  );

  static String _birthLine(CvData d) {
    final date = d.birthdate.trim();
    final place = d.birthplace.trim();
    if (date.isNotEmpty && place.isNotEmpty) return '$date in $place';
    if (date.isNotEmpty) return date;
    if (place.isNotEmpty) return 'geboren in $place';
    return '';
  }

  static String _initials(CvData d) {
    if (d.initials.isNotEmpty) return d.initials;
    return initialsFromName(d.name);
  }

  static String _languageLabel(dynamic l) {
    final level = l.level?.toString() ?? '';
    return level.isNotEmpty ? '${l.name} ($level)' : l.name.toString();
  }

  /// Gruppiert eigene Abschnitte nach Abschnittsname (Reihenfolge bleibt).
  static Map<String, List<CvTimelineItem>> _groupCustomItems(
    List<dynamic> items,
  ) {
    final grouped = <String, List<CvTimelineItem>>{};
    for (final item in items) {
      grouped
          .putIfAbsent(item.sectionName as String, () => [])
          .add(
            CvTimelineItem(
              dateRange: item.dateRange ?? '',
              title: item.title,
              subtitle: item.subtitle ?? '',
              description: item.description ?? '',
            ),
          );
    }
    return grouped;
  }

  // ---------------------------------------------------------------------------
  // Lebenslauf
  // ---------------------------------------------------------------------------

  /// Erzeugt den Lebenslauf als PDF. [designId]: klassisch | kompakt | modern
  /// | monogram (Standard).
  static Future<Uint8List> generatePdf(
    CvData cvData,
    String designId,
    Color accentColor,
  ) async {
    final serif = designId == 'klassisch';
    final fonts = await _loadFonts(serif: serif);
    final profileImage = await _loadProfileImage(cvData.profileImagePath);
    final primary = _primary(accentColor);
    final text = _pdfColor(cvData.textColor);

    _latin1Only = fonts.latin1Only;
    final pdf = pw.Document(title: _t(cvData.name.isEmpty ? 'Lebenslauf' : 'Lebenslauf ${cvData.name}'));
    switch (designId) {
      case 'klassisch':
      case 'kompakt':
        _buildClassic(pdf, fonts.theme, cvData, primary, text, profileImage);
      case 'modern':
        _buildModern(pdf, fonts.theme, cvData, primary, text, profileImage);
      default:
        _buildMonogram(pdf, fonts.theme, cvData, primary, text, profileImage);
    }
    return pdf.save();
  }

  /// Abschnittstitel + einzelne Einträge als eigenständige Widgets, damit
  /// MultiPage zwischen (und innerhalb langer Beschreibungen) umbrechen kann.
  static List<pw.Widget> _timelineSection(
    String title,
    List<CvTimelineItem> items, {
    required PdfColor accent,
    required PdfColor text,
    double dateWidth = 90,
  }) {
    if (items.isEmpty) return [];
    return [
      _sectionHeader(title, accent),
      for (final item in items) ..._timelineItem(item, accent, text, dateWidth),
      pw.SizedBox(height: 10),
    ];
  }

  static pw.Widget _sectionHeader(String title, PdfColor accent) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _t(title.toUpperCase()),
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: accent,
              letterSpacing: 1,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Container(height: 0.8, color: accent),
        ],
      ),
    );
  }

  static List<pw.Widget> _timelineItem(
    CvTimelineItem item,
    PdfColor accent,
    PdfColor text,
    double dateWidth,
  ) {
    const gap = 10.0;
    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: dateWidth,
            child: pw.Text(
              _t(item.dateRange),
              style: pw.TextStyle(fontSize: 8.5, color: accent),
            ),
          ),
          pw.SizedBox(width: gap),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  _t(item.title),
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    fontWeight: pw.FontWeight.bold,
                    color: text,
                  ),
                ),
                if (item.subtitle.isNotEmpty)
                  pw.Text(
                    _t(item.subtitle),
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontStyle: pw.FontStyle.italic,
                      color: text,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      if (item.description.isNotEmpty)
        pw.Padding(
          padding: pw.EdgeInsets.only(left: dateWidth + gap, top: 3),
          child: pw.Text(
            _t(item.description),
            style: pw.TextStyle(fontSize: 8.5, color: text, lineSpacing: 2),
          ),
        ),
      pw.SizedBox(height: 9),
    ];
  }

  static List<pw.Widget> _bulletSection(
    String title,
    List<String> entries, {
    required PdfColor accent,
    required PdfColor text,
  }) {
    if (entries.isEmpty) return [];
    return [
      _sectionHeader(title, accent),
      for (final e in entries)
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(_t('\u2022 '), style: pw.TextStyle(fontSize: 9, color: accent)),
              pw.Expanded(
                child: pw.Text(_t(e), style: pw.TextStyle(fontSize: 9, color: text)),
              ),
            ],
          ),
        ),
      pw.SizedBox(height: 10),
    ];
  }

  static List<pw.Widget> _mainSections(
    CvData cvData,
    PdfColor accent,
    PdfColor text, {
    bool includeSkillsAndLanguages = true,
  }) {
    return [
      ..._timelineSection('Berufserfahrung', cvData.experiences, accent: accent, text: text),
      ..._timelineSection('Ausbildung', cvData.educations, accent: accent, text: text),
      for (final entry in _groupCustomItems(cvData.customItems).entries)
        ..._timelineSection(entry.key, entry.value, accent: accent, text: text),
      if (includeSkillsAndLanguages) ...[
        ..._bulletSection(
          'Fähigkeiten',
          cvData.skills.map<String>((s) => s.name.toString()).toList(),
          accent: accent,
          text: text,
        ),
        ..._bulletSection(
          'Sprachen',
          cvData.languages.map<String>(_languageLabel).toList(),
          accent: accent,
          text: text,
        ),
      ],
    ];
  }

  // --- KLASSISCH / KOMPAKT ---
  static void _buildClassic(
    pw.Document pdf,
    pw.ThemeData theme,
    CvData cvData,
    PdfColor primary,
    PdfColor text,
    pw.MemoryImage? profileImage,
  ) {
    final contactLine = [cvData.address, cvData.phone, cvData.email]
        .where((e) => e.trim().isNotEmpty)
        .join('  \u2022  ');
    final birth = _birthLine(cvData);
    final personalLine = [
      if (birth.isNotEmpty) 'Geboren: $birth',
      if (cvData.maritalStatus.trim().isNotEmpty) cvData.maritalStatus.trim(),
    ].join('  \u2022  ');

    final header = pw.Column(
      children: [
        pw.Text(
          _t(cvData.name.toUpperCase()),
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5, color: text),
        ),
        if (cvData.title.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(_t(cvData.title), textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 10, color: primary)),
        ],
        if (contactLine.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Text(_t(contactLine), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ],
        if (personalLine.isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(_t(personalLine), textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ],
      ],
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: _margins(cvData.pageMargins),
        build: (context) => [
          if (profileImage == null)
            pw.Center(child: header)
          else
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 80),
                pw.Expanded(child: header),
                pw.Image(profileImage, width: 68, height: 90, fit: pw.BoxFit.cover),
              ],
            ),
          pw.SizedBox(height: 10),
          pw.Divider(thickness: 0.6, color: PdfColors.grey400),
          pw.SizedBox(height: 12),
          if (cvData.introText.isNotEmpty) ...[
            pw.Text(_t(cvData.introText), style: pw.TextStyle(fontSize: 9, color: text, lineSpacing: 2)),
            pw.SizedBox(height: 16),
          ],
          ..._mainSections(cvData, primary, text),
        ],
      ),
    );
  }

  // --- MODERN (Seitenleiste) ---
  static void _buildModern(
    pw.Document pdf,
    pw.ThemeData theme,
    CvData cvData,
    PdfColor primary,
    PdfColor text,
    pw.MemoryImage? profileImage,
  ) {
    const sidebarWidth = 165.0; // 220 px
    final isLight = primary.luminance > 0.5;
    final sideText = isLight ? PdfColors.black : PdfColors.white;
    final sideDim = isLight ? PdfColors.grey800 : PdfColors.grey200;
    final margins = _margins(cvData.pageMargins);
    final birth = _birthLine(cvData);

    pw.Widget sideTitle(String t) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
      child: pw.Text(_t(t), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: sideText, letterSpacing: 1)),
    );
    pw.Widget sideItem(String t) => t.trim().isEmpty
        ? pw.SizedBox()
        : pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(_t(t), style: pw.TextStyle(fontSize: 8, color: sideDim)),
          );

    // Seitenleiste mit Inhalten nur auf Seite 1, auf Folgeseiten nur die Farbfläche.
    pw.Widget sidebar(bool withContent) => pw.Container(
      width: sidebarWidth,
      color: primary,
      padding: pw.EdgeInsets.only(left: 18, right: 18, top: margins.top, bottom: margins.bottom),
      child: !withContent
          ? null
          : pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (profileImage != null) ...[
                  pw.Image(profileImage, width: 82, height: 105, fit: pw.BoxFit.cover),
                  pw.SizedBox(height: 14),
                ],
                pw.Text(_t(cvData.name), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: sideText)),
                if (cvData.title.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(_t(cvData.title), style: pw.TextStyle(fontSize: 8, color: sideDim)),
                ],
                sideTitle('KONTAKT'),
                sideItem(cvData.email),
                sideItem(cvData.phone),
                sideItem(cvData.address),
                sideItem(birth),
                sideItem(cvData.maritalStatus),
                if (cvData.skills.isNotEmpty) ...[
                  sideTitle('FÄHIGKEITEN'),
                  ...cvData.skills.map<pw.Widget>((s) => sideItem(s.name.toString())),
                ],
                if (cvData.languages.isNotEmpty) ...[
                  sideTitle('SPRACHEN'),
                  ...cvData.languages.map<pw.Widget>((l) => sideItem(_languageLabel(l))),
                ],
              ],
            ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: theme,
          margin: pw.EdgeInsets.only(
            left: sidebarWidth + 24,
            right: margins.right,
            top: margins.top,
            bottom: margins.bottom,
          ),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [sidebar(context.pageNumber == 1)],
            ),
          ),
        ),
        build: (context) => [
          if (cvData.introText.isNotEmpty) ...[
            _sectionHeader('Profil', primary),
            pw.Text(_t(cvData.introText), style: pw.TextStyle(fontSize: 9, color: text, lineSpacing: 2)),
            pw.SizedBox(height: 16),
          ],
          ..._mainSections(cvData, primary, text, includeSkillsAndLanguages: false),
        ],
      ),
    );
  }

  // --- MONOGRAM ---
  static void _buildMonogram(
    pw.Document pdf,
    pw.ThemeData theme,
    CvData cvData,
    PdfColor primary,
    PdfColor text,
    pw.MemoryImage? profileImage,
  ) {
    final initials = _initials(cvData);
    final info = <MapEntry<String, String>>[
      MapEntry('E-MAIL', cvData.email),
      MapEntry('ANSCHRIFT', cvData.address),
      MapEntry('TELEFON', cvData.phone),
      MapEntry('FAMILIENSTAND', cvData.maritalStatus),
      MapEntry('GEBURTSORT', cvData.birthplace),
      MapEntry('GEBURTSDATUM', cvData.birthdate),
    ].where((e) => e.value.trim().isNotEmpty).toList();

    pw.Widget infoBlock(MapEntry<String, String> e) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8, right: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(_t('${e.key}:'), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 2),
          pw.Text(_t(e.value), style: pw.TextStyle(fontSize: 8, color: text)),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: _margins(cvData.pageMargins),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (initials.isNotEmpty) ...[
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: primary, width: 3),
                      bottom: pw.BorderSide(color: primary, width: 3),
                    ),
                  ),
                  padding: const pw.EdgeInsets.only(left: 6, bottom: 3, right: 9, top: 3),
                  child: pw.Text(_t(initials), style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: text)),
                ),
                pw.SizedBox(width: 16),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(_t(cvData.name), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: text)),
                    if (cvData.title.isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(_t(cvData.title.toUpperCase()), style: const pw.TextStyle(fontSize: 9, letterSpacing: 1, color: PdfColors.grey700)),
                    ],
                  ],
                ),
              ),
              if (profileImage != null)
                pw.Image(profileImage, width: 68, height: 90, fit: pw.BoxFit.cover),
            ],
          ),
          pw.SizedBox(height: 16),
          if (cvData.introText.isNotEmpty) ...[
            pw.Text(_t(cvData.introText), style: pw.TextStyle(fontSize: 8.5, color: text, lineSpacing: 2)),
            pw.SizedBox(height: 16),
          ],
          if (info.isNotEmpty) ...[
            _sectionHeader('Persönliche Daten', primary),
            pw.Wrap(
              children: [
                for (final e in info)
                  pw.SizedBox(width: 150, child: infoBlock(e)),
              ],
            ),
            pw.SizedBox(height: 12),
          ],
          ..._mainSections(cvData, primary, text),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Anschreiben
  // ---------------------------------------------------------------------------

  /// Erzeugt das Anschreiben als PDF: Briefkopf aus [header] und der
  /// Fließtext aus den Quill-Delta-Operationen [deltaOps] (fett, kursiv,
  /// unterstrichen, Schriftgröße, Ausrichtung, Listen und Bilder wie die
  /// Unterschrift werden übernommen).
  static Future<Uint8List> generateCoverLetterPdf({
    required CoverLetterPdfHeader header,
    required List<dynamic> deltaOps,
    required String designId,
    required Color accentColor,
    required EdgeInsets pageMargins,
    double fontSizePx = 14,
    double lineHeight = 1.5,
    Color textColor = const Color(0xFF000000),
  }) async {
    final fonts = await _loadFonts(serif: designId == 'klassisch');
    _latin1Only = fonts.latin1Only;
    final primary = _primary(accentColor);
    final text = _pdfColor(textColor);
    final baseSize = fontSizePx * _pxToPt;

    final pdf = pw.Document(title: _t('Anschreiben ${header.companyName}'.trim()));
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: fonts.theme,
        margin: _margins(pageMargins),
        build: (context) => [
          _coverLetterHeader(header, designId, primary, text),
          pw.SizedBox(height: 24),
          ..._deltaToWidgets(deltaOps, baseSize, lineHeight, text),
        ],
      ),
    );
    return pdf.save();
  }

  static pw.Widget _coverLetterHeader(
    CoverLetterPdfHeader h,
    String designId,
    PdfColor primary,
    PdfColor text,
  ) {
    final contact = [h.senderAddress.replaceAll('\n', ', '), h.senderPhone, h.senderEmail]
        .where((e) => e.trim().isNotEmpty)
        .join('  \u2022  ');
    final initials = initialsFromName(h.senderName);

    final senderBlock = switch (designId) {
      'monogram' => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (initials.isNotEmpty) ...[
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: primary, width: 2.5),
                  bottom: pw.BorderSide(color: primary, width: 2.5),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: pw.Text(_t(initials), style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: text)),
            ),
            pw.SizedBox(width: 16),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_t(h.senderName), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: text)),
                if (h.senderProfession.isNotEmpty)
                  pw.Text(_t(h.senderProfession), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                if (contact.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(_t(contact), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                ],
              ],
            ),
          ),
        ],
      ),
      'modern' => pw.Container(
        width: double.infinity,
        decoration: pw.BoxDecoration(
          border: pw.Border(left: pw.BorderSide(color: primary, width: 3)),
        ),
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_t(h.senderName), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: primary)),
            if (contact.isNotEmpty) ...[
              pw.SizedBox(height: 3),
              pw.Text(_t(contact), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ],
          ],
        ),
      ),
      _ => pw.Column(
        children: [
          pw.Center(
            child: pw.Text(_t(h.senderName.toUpperCase()), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5, color: text)),
          ),
          if (contact.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Center(child: pw.Text(_t(contact), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700))),
          ],
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 0.6, color: PdfColors.grey400),
        ],
      ),
    };

    final recipient = [h.companyName, h.contactName, h.companyAddress]
        .where((e) => e.trim().isNotEmpty)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        senderBlock,
        pw.SizedBox(height: 24),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  for (final line in recipient)
                    pw.Text(_t(line), style: pw.TextStyle(fontSize: 9, color: text)),
                ],
              ),
            ),
            if (h.date.isNotEmpty)
              pw.Text(_t(h.date), style: pw.TextStyle(fontSize: 9, color: text)),
          ],
        ),
      ],
    );
  }

  /// Wandelt Quill-Delta-Operationen in PDF-Absätze um. Jeder Absatz ist ein
  /// eigenständiges Widget, damit lange Briefe sauber umbrechen.
  static List<pw.Widget> _deltaToWidgets(
    List<dynamic> ops,
    double baseSize,
    double lineHeight,
    PdfColor textColor,
  ) {
    final widgets = <pw.Widget>[];
    var spans = <pw.InlineSpan>[];
    var orderedIndex = 0;

    pw.TextStyle styleFor(Map<String, dynamic>? attrs) {
      var size = baseSize;
      final rawSize = attrs?['size'];
      final parsed = rawSize == null ? null : double.tryParse(rawSize.toString());
      if (parsed != null && parsed > 0) size = parsed * _pxToPt;
      final decorations = [
        if (attrs?['underline'] == true) pw.TextDecoration.underline,
        if (attrs?['strike'] == true) pw.TextDecoration.lineThrough,
      ];
      return pw.TextStyle(
        fontSize: size,
        color: textColor,
        fontWeight: attrs?['bold'] == true ? pw.FontWeight.bold : null,
        fontStyle: attrs?['italic'] == true ? pw.FontStyle.italic : null,
        decoration: decorations.isEmpty
            ? null
            : pw.TextDecoration.combine(decorations),
      );
    }

    void endLine(Map<String, dynamic>? lineAttrs) {
      final align = switch (lineAttrs?['align']) {
        'center' => pw.TextAlign.center,
        'right' => pw.TextAlign.right,
        'justify' => pw.TextAlign.justify,
        _ => pw.TextAlign.left,
      };
      final list = lineAttrs?['list'];
      if (list == 'ordered') {
        orderedIndex++;
      } else {
        orderedIndex = 0;
      }
      final prefix = list == 'bullet'
          ? '\u2022 '
          : list == 'ordered'
          ? '$orderedIndex. '
          : '';
      final indent = (lineAttrs?['indent'] is int ? lineAttrs!['indent'] as int : 0) * 18.0 +
          (prefix.isNotEmpty ? 12.0 : 0);

      final children = [
        if (prefix.isNotEmpty) pw.TextSpan(text: _t(prefix), style: styleFor(null)),
        ...spans,
      ];
      widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(left: indent),
          child: pw.RichText(
            textAlign: align,
            text: pw.TextSpan(
              // Leere Zeilen behalten ihre Höhe.
              text: children.isEmpty ? ' ' : null,
              style: styleFor(null).copyWith(lineSpacing: (lineHeight - 1) * baseSize),
              children: children,
            ),
          ),
        ),
      );
      spans = <pw.InlineSpan>[];
    }

    for (final op in ops) {
      if (op is! Map) continue;
      final insert = op['insert'];
      final attrs = op['attributes'] is Map
          ? Map<String, dynamic>.from(op['attributes'] as Map)
          : null;

      if (insert is String) {
        final parts = insert.split('\n');
        for (var i = 0; i < parts.length; i++) {
          if (parts[i].isNotEmpty) {
            spans.add(pw.TextSpan(text: _t(parts[i]), style: styleFor(attrs)));
          }
          if (i < parts.length - 1) endLine(attrs);
        }
      } else if (insert is Map) {
        final image = insert['image'];
        if (image is String) {
          final bytes = _decodeImage(image);
          if (bytes != null) {
            if (spans.isNotEmpty) endLine(null);
            widgets.add(
              pw.Container(
                alignment: pw.Alignment.centerLeft,
                height: 50,
                child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
              ),
            );
          }
        }
      }
    }
    if (spans.isNotEmpty) endLine(null);
    return widgets;
  }

  static Uint8List? _decodeImage(String source) {
    try {
      if (source.startsWith('data:')) {
        final comma = source.indexOf(',');
        if (comma < 0) return null;
        return base64Decode(source.substring(comma + 1));
      }
      final file = File(source.startsWith('file://') ? Uri.parse(source).toFilePath() : source);
      if (file.existsSync()) return file.readAsBytesSync();
    } catch (e) {
      debugPrint('PDF: Bild im Anschreiben nicht ladbar: $e');
    }
    return null;
  }
}
