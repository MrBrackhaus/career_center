import 'dart:typed_data';
import 'package:html/parser.dart' as html_parser;
import 'package:pdfrx/pdfrx.dart';

class DocumentSanitizerService {
  static Future<String> extractTextFromPdf(Uint8List bytes) async {
    try {
      final doc = await PdfDocument.openData(bytes);
      final StringBuffer textBuf = StringBuffer();
      for (var page in doc.pages) {
        final pageText = await page.loadText();
        if (pageText != null) {
          textBuf.writeln(pageText.fullText);
        }
      }
      doc.dispose();
      return textBuf.toString().replaceAll('\u00A0', ' ');
    } catch (e) {
      return '';
    }
  }

  static String sanitizeHtml(String input) {
    if (input.trim().startsWith('<') || input.contains('<!DOCTYPE')) {
      try {
        final doc = html_parser.parse(input);
        var text = doc.body?.text ?? doc.documentElement?.text ?? input;
        return text.replaceAll(RegExp(r'\s+'), ' ').trim();
      } catch (_) {
        return input;
      }
    }
    return input;
  }
}
