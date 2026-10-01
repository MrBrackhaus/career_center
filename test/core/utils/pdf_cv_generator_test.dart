import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/themes/designs/document_design.dart';
import 'package:career_center/core/utils/pdf_cv_generator.dart';

void main() {
  // Viele lange Einträge: MultiPage muss umbrechen können, sonst wirft die
  // Generierung (TooManyPages / Widget passt nicht auf eine Seite).
  final longText = List.filled(60, 'Verantwortung für Projekte – Budget 5 € •').join(' ');
  final cvData = CvData(
    name: 'Erika Müller',
    title: 'Entwicklerin',
    introText: 'Kurzprofil mit Umlauten äöüß.',
    email: 'erika@example.com',
    birthdate: '01.01.1990',
    experiences: List.generate(
      25,
      (i) => CvTimelineItem(
        dateRange: '01/20$i - Heute',
        title: 'Position $i',
        subtitle: 'Firma $i',
        description: longText,
      ),
    ),
    educations: const [CvTimelineItem(dateRange: '2010', title: 'B.Sc.')],
  );

  for (final design in ['klassisch', 'kompakt', 'modern', 'monogram']) {
    test('Lebenslauf-PDF ($design) wird mehrseitig erzeugt', () async {
      final bytes = await PdfCvGenerator.generatePdf(
        cvData,
        design,
        const Color(0xFF0D47A1),
      );
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(1000));
    });
  }

  test('Anschreiben-PDF aus Quill-Delta', () async {
    final bytes = await PdfCvGenerator.generateCoverLetterPdf(
      header: const CoverLetterPdfHeader(
        senderName: 'Erika Müller',
        companyName: 'Firma GmbH',
        date: 'Berlin, 01.01.2026',
      ),
      deltaOps: [
        {'insert': 'Sehr geehrte Damen und Herren,\n\n'},
        {'insert': 'fett', 'attributes': {'bold': true}},
        {'insert': ' und normal – 100 €\n'},
        {'insert': 'Punkt'},
        {'insert': '\n', 'attributes': {'list': 'bullet'}},
      ],
      designId: 'monogram',
      accentColor: const Color(0xFF0D47A1),
      pageMargins: const EdgeInsets.all(75),
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('CvData.birthLine ohne hängendes " in "', () {
    expect(const CvData(birthdate: '01.01.1990').birthLine, '01.01.1990');
    expect(const CvData(birthplace: 'Berlin').birthLine, 'geboren in Berlin');
    expect(
      const CvData(birthdate: '01.01.1990', birthplace: 'Berlin').birthLine,
      '01.01.1990 in Berlin',
    );
    expect(const CvData().birthLine, '');
  });

  test('initialsFromName', () {
    expect(initialsFromName('  Erika   Müller '), 'EM');
    expect(initialsFromName(''), '');
  });
}
