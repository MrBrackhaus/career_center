import 'package:pdfrx/pdfrx.dart';

class RegexCvParser {
  static Future<Map<String, dynamic>> parsePdf(String filePath) async {
    final document = await PdfDocument.openFile(filePath);
    final buffer = StringBuffer();
    try {
      for (final page in document.pages) {
        final text = await page.loadText();
        if (text != null) { buffer.write(text.fullText); }
        buffer.write('\n');
      }
    } finally {
      await document.dispose();
    }
    
    final fullText = buffer.toString();
    
    String email = '';
    String phone = '';
    
    final emailRegex = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    final matchEmail = emailRegex.firstMatch(fullText);
    if (matchEmail != null) {
      email = matchEmail.group(0) ?? '';
    }
    
    final phoneRegex = RegExp(r'(\+49|0)[1-9](\s?\d){8,11}');
    final matchPhone = phoneRegex.firstMatch(fullText);
    if (matchPhone != null) {
      phone = matchPhone.group(0) ?? '';
    }
    
    return {
      'rawText': fullText,
      'email': email,
      'phone': phone,
    };
  }
}

