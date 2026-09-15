import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../themes/designs/document_design.dart';

class PdfCvGenerator {
  static pw.Font? _fontRegular;
  static pw.Font? _fontBold;
  static pw.Font? _fontItalic;

  static pw.Font? _serifRegular;
  static pw.Font? _serifBold;
  static pw.Font? _serifItalic;

  static Future<Uint8List> generatePdf(
    CvData cvData,
    String designId,
    Color accentColor,
  ) async {
    final pdf = pw.Document();
    pw.MemoryImage? profileImage;
    if (cvData.profileImagePath != null && cvData.profileImagePath!.isNotEmpty) {
      try {
        final file = File(cvData.profileImagePath!);
        if (await file.exists()) {
          profileImage = pw.MemoryImage(await file.readAsBytes());
        }
      } catch (e) {}
    }

    final primaryColor = accentColor == const Color(0x00000000) 
        ? PdfColor.fromHex('#1E3A8A') 
        : PdfColor(accentColor.r, accentColor.g, accentColor.b, accentColor.a);

    pw.Font fontRegular;
    pw.Font fontBold;
    pw.Font fontItalic;

    try {
      _fontRegular ??= await PdfGoogleFonts.openSansRegular();
      _fontBold ??= await PdfGoogleFonts.openSansBold();
      _fontItalic ??= await PdfGoogleFonts.openSansItalic();
      fontRegular = _fontRegular!;
      fontBold = _fontBold!;
      fontItalic = _fontItalic!;
    } catch (e) {
      _fontRegular = pw.Font.helvetica();
      _fontBold = pw.Font.helveticaBold();
      _fontItalic = pw.Font.helvetica();
      fontRegular = _fontRegular!;
      fontBold = _fontBold!;
      fontItalic = _fontItalic!;
    }

    pw.ThemeData theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      italic: fontItalic,
    );

    if (designId == 'klassisch') {
      pw.Font serifRegular;
      pw.Font serifBold;
      pw.Font serifItalic;

      try {
        _serifRegular ??= await PdfGoogleFonts.tinosRegular();
        _serifBold ??= await PdfGoogleFonts.tinosBold();
        _serifItalic ??= await PdfGoogleFonts.tinosItalic();
        serifRegular = _serifRegular!;
        serifBold = _serifBold!;
        serifItalic = _serifItalic!;
      } catch (e) {
        _serifRegular = pw.Font.helvetica();
        _serifBold = pw.Font.helveticaBold();
        _serifItalic = pw.Font.helvetica();
        serifRegular = _serifRegular!;
        serifBold = _serifBold!;
        serifItalic = _serifItalic!;
      }
      theme = pw.ThemeData.withFont(
        base: serifRegular,
        bold: serifBold,
        italic: serifItalic,
      );
      _buildClassicDesign(pdf, theme, cvData, primaryColor, profileImage);
    } else if (designId == 'modern') {
      _buildModernDesign(pdf, theme, cvData, primaryColor, profileImage);
    } else {
      _buildMonogramDesign(pdf, theme, cvData, primaryColor, profileImage);
    }

    return pdf.save();
  }

  static Future<Uint8List> generateCoverLetterPdf(
    CvData cvData,
    String designId,
    Color accentColor,
    pw.Widget quillContent,
    double marginTop,
    double marginBottom,
    double marginLeft,
    double marginRight,
  ) async {
    final pdf = pw.Document();
    pw.MemoryImage? profileImage;
    if (cvData.profileImagePath != null && cvData.profileImagePath!.isNotEmpty) {
      try {
        final file = File(cvData.profileImagePath!);
        if (await file.exists()) {
          profileImage = pw.MemoryImage(await file.readAsBytes());
        }
      } catch (e) {
        // ignore
      }
    }

    final primaryColor = accentColor == const Color(0x00000000) 
        ? PdfColor.fromHex('#1E3A8A') 
        : PdfColor(accentColor.r, accentColor.g, accentColor.b, accentColor.a);

    pw.Font fontRegular;
    pw.Font fontBold;
    pw.Font fontItalic;

    try {
      _fontRegular ??= await PdfGoogleFonts.openSansRegular();
      _fontBold ??= await PdfGoogleFonts.openSansBold();
      _fontItalic ??= await PdfGoogleFonts.openSansItalic();
      fontRegular = _fontRegular!;
      fontBold = _fontBold!;
      fontItalic = _fontItalic!;
    } catch (e) {
      _fontRegular = pw.Font.helvetica();
      _fontBold = pw.Font.helveticaBold();
      _fontItalic = pw.Font.helvetica();
      fontRegular = _fontRegular!;
      fontBold = _fontBold!;
      fontItalic = _fontItalic!;
    }

    pw.ThemeData theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
      italic: fontItalic,
    );

    if (designId == 'klassisch') {
      pw.Font serifRegular;
      pw.Font serifBold;
      pw.Font serifItalic;

      try {
        _serifRegular ??= await PdfGoogleFonts.tinosRegular();
        _serifBold ??= await PdfGoogleFonts.tinosBold();
        _serifItalic ??= await PdfGoogleFonts.tinosItalic();
        serifRegular = _serifRegular!;
        serifBold = _serifBold!;
        serifItalic = _serifItalic!;
      } catch (e) {
        _serifRegular = pw.Font.helvetica();
        _serifBold = pw.Font.helveticaBold();
        _serifItalic = pw.Font.helvetica();
        serifRegular = _serifRegular!;
        serifBold = _serifBold!;
        serifItalic = _serifItalic!;
      }
      theme = pw.ThemeData.withFont(
        base: serifRegular,
        bold: serifBold,
        italic: serifItalic,
      );
    }

    // Convert pixel margins from Flutter to points in PDF. 
    // 96 DPI to 72 DPI (PDF points) is approximately * 0.75
    // But since the quill to pdf generator does its own things, we can just use the provided values as pw.EdgeInsets.
    final margins = pw.EdgeInsets.only(
      top: marginTop * 0.75,
      bottom: marginBottom * 0.75,
      left: marginLeft * 0.75,
      right: marginRight * 0.75,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: margins,
        build: (context) {
          final List<pw.Widget> elements = [];

          if (designId == 'monogram') {
            elements.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: primaryColor, width: 4),
                        bottom: pw.BorderSide(color: primaryColor, width: 4),
                      ),
                    ),
                    padding: const pw.EdgeInsets.only(left: 8, bottom: 4, right: 12, top: 4),
                    child: pw.Text(
                      cvData.initials.isNotEmpty ? cvData.initials : 'MK',
                      style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                    ),
                  ),
                  pw.SizedBox(width: 24),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(cvData.name, style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                        pw.SizedBox(height: 4),
                        pw.Text(cvData.title, style: pw.TextStyle(fontSize: 14, color: primaryColor, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            );
            elements.add(pw.SizedBox(height: 32));
          }

          elements.add(quillContent);

          return elements;
        },
      ),
    );

    return pdf.save();
  }

  // --- KLASSISCHES DESIGN ---
  static void _buildClassicDesign(pw.Document pdf, pw.ThemeData theme, CvData cvData, PdfColor primaryColor, pw.MemoryImage? profileImage) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(48),
        build: (context) {
          return [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(cvData.name, style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(cvData.title, style: pw.TextStyle(fontSize: 16, color: primaryColor)),
                  pw.SizedBox(height: 16),
                  pw.Text('${cvData.address} | ${cvData.phone} | ${cvData.email}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 32),
            ..._buildTimelineSection('BERUFSERFAHRUNG', cvData.experiences, primaryColor),
            ..._buildTimelineSection('AUSBILDUNG', cvData.educations, primaryColor),
          ];
        },
      ),
    );
  }

  static List<pw.Widget> _buildTimelineSection(String title, List<CvTimelineItem> items, PdfColor primaryColor) {
    if (items.isEmpty) return [];
    return [
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor, letterSpacing: 1.2)),
            pw.Divider(thickness: 1, height: 16, color: PdfColors.grey400),
            pw.SizedBox(height: 8),
            ...items.map((item) => _buildClassicTimelineItem(item)),
          ],
        ),
      ),
    ];
  }

  static pw.Widget _buildClassicTimelineItem(CvTimelineItem item) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(item.dateRange, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                if (item.subtitle.isNotEmpty) pw.Text(item.subtitle, style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
                if (item.description.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(item.description, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODERN SIDEBAR DESIGN ---
  static void _buildModernDesign(pw.Document pdf, pw.ThemeData theme, CvData cvData, PdfColor primaryColor, pw.MemoryImage? profileImage) {
    // Custom MultiPage for sidebar
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: pw.EdgeInsets.zero, // No margin, we handle it in partitions
        build: (context) {
          return [
            pw.Partitions(
              children: [
                pw.Partition(
                  width: 220,
                  child: pw.Container(
                    color: primaryColor,
                    padding: const pw.EdgeInsets.all(32),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (profileImage != null) ...[
                          pw.Container(
                            width: 100,
                            height: 100,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              image: pw.DecorationImage(image: profileImage, fit: pw.BoxFit.cover),
                            ),
                          ),
                          pw.SizedBox(height: 32),
                        ],
                        pw.Text(cvData.name, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                        pw.SizedBox(height: 8),
                        pw.Text(cvData.title, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey200)),
                        pw.SizedBox(height: 32),
                        _buildModernContact(cvData.email),
                        _buildModernContact(cvData.phone),
                        _buildModernContact(cvData.address),
                        _buildModernContact('${cvData.birthdate} in ${cvData.birthplace}'),
                      ],
                    ),
                  ),
                ),
                pw.Partition(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        ..._buildModernTimelineSection('BERUFSERFAHRUNG', cvData.experiences, primaryColor),
                        ..._buildModernTimelineSection('AUSBILDUNG', cvData.educations, primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );
  }

  static pw.Widget _buildModernContact(String text) {
    if (text.isEmpty) return pw.SizedBox.shrink();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
    );
  }

  static List<pw.Widget> _buildModernTimelineSection(String title, List<CvTimelineItem> items, PdfColor primaryColor) {
    if (items.isEmpty) return [];
    return [
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Container(width: 4, height: 16, color: primaryColor),
                pw.SizedBox(width: 8),
                pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              ],
            ),
            pw.SizedBox(height: 16),
            ...items.map((item) => _buildModernTimelineItem(item, primaryColor)),
          ],
        ),
      ),
    ];
  }

  static pw.Widget _buildModernTimelineItem(CvTimelineItem item, PdfColor primaryColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(item.dateRange, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                if (item.subtitle.isNotEmpty) pw.Text(item.subtitle, style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                if (item.description.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(item.description, style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MONOGRAM DESIGN ---
  static void _buildMonogramDesign(pw.Document pdf, pw.ThemeData theme, CvData cvData, PdfColor primaryColor, pw.MemoryImage? profileImage) {
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return [
            // HEADER
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: primaryColor, width: 4),
                      bottom: pw.BorderSide(color: primaryColor, width: 4),
                    ),
                  ),
                  padding: const pw.EdgeInsets.only(left: 8, bottom: 4, right: 12, top: 4),
                  child: pw.Text(
                    cvData.initials.isNotEmpty ? cvData.initials : 'MK',
                    style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
                  ),
                ),
                pw.SizedBox(width: 24),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(cvData.name, style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                      pw.SizedBox(height: 4),
                      pw.Text(cvData.title, style: pw.TextStyle(fontSize: 14, color: primaryColor, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 12),
                      pw.Text(cvData.introText, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700, lineSpacing: 1.4)),
                    ],
                  ),
                ),
                if (profileImage != null) ...[
                  pw.SizedBox(width: 24),
                  pw.ClipOval(
                    child: pw.Image(profileImage, width: 80, height: 80, fit: pw.BoxFit.cover),
                  ),
                ],
              ],
            ),
            pw.SizedBox(height: 24),
            // INFO BAR
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: primaryColor, width: 2),
                  bottom: pw.BorderSide(color: primaryColor, width: 2),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(vertical: 16),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(child: _buildMonogramInfo('KONTAKT:', '${cvData.email}\n${cvData.phone}\n${cvData.address}', primaryColor)),
                  pw.Expanded(child: _buildMonogramInfo('GEBURTSORT:', cvData.birthplace, primaryColor)),
                  pw.Expanded(child: _buildMonogramInfo('GEBURTSDATUM:', cvData.birthdate, primaryColor)),
                ],
              ),
            ),
            pw.SizedBox(height: 24),
            ..._buildMonogramTimelineSection('BERUFSERFAHRUNG', cvData.experiences, primaryColor),
            ..._buildMonogramTimelineSection('AUSBILDUNG', cvData.educations, primaryColor),
          ];
        },
      ),
    );
  }

  static pw.Widget _buildMonogramInfo(String label, String value, PdfColor primaryColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
        pw.SizedBox(height: 4),
        pw.Text(value.isNotEmpty ? value : '-', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
      ],
    );
  }

  static List<pw.Widget> _buildMonogramTimelineSection(String title, List<CvTimelineItem> items, PdfColor primaryColor) {
    if (items.isEmpty) return [];
    return [
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 24),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: primaryColor)),
            pw.SizedBox(height: 4),
            pw.Container(height: 1, color: primaryColor),
            pw.SizedBox(height: 16),
            ...List.generate(items.length, (i) => _buildMonogramTimelineItem(items[i], primaryColor, isLast: i == items.length - 1)),
          ],
        ),
      ),
    ];
  }

  static pw.Widget _buildMonogramTimelineItem(CvTimelineItem item, PdfColor primaryColor, {bool isLast = false}) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 1),
            child: pw.Text(item.dateRange, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800), textAlign: pw.TextAlign.right),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Container(
            decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: primaryColor, width: 2))),
            padding: pw.EdgeInsets.only(left: 12, bottom: isLast ? 0 : 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                if (item.subtitle.isNotEmpty) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(item.subtitle, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                ],
                if (item.description.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(item.description, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.4, color: PdfColors.grey800)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
