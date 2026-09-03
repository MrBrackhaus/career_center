import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() async {
  final dir = Directory(r'S:\Projekte\JobTracker\training_data');
  if (!dir.existsSync()) {
    print('Directory not found!');
    return;
  }

  List<String> anschreiben = [];
  List<String> stellenanzeige = [];

  final files = dir.listSync().whereType<File>().where((f) => f.path.toLowerCase().endsWith('.pdf'));

  for (final file in files) {
    try {
      final bytes = file.readAsBytesSync();
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText().replaceAll('\u00A0', ' ');
      document.dispose();

      // Clean the text: remove newlines, multiple spaces, keep it compact
      final cleanText = text
          .replaceAll(RegExp(r'\r?\n'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll('"', r'\"')
          .trim();
          
      if (cleanText.isEmpty) continue;

      final name = file.uri.pathSegments.last.toLowerCase();
      if (name.contains('anschreiben') || name.contains('motivationsschreiben')) {
        anschreiben.add('"$cleanText"');
      } else {
        stellenanzeige.add('"$cleanText"');
      }
      print('Processed ${file.uri.pathSegments.last}');
    } catch (e) {
      print('Failed to process ${file.uri.pathSegments.last}: $e');
    }
  }

  print('\nFound ${anschreiben.length} Anschreiben and ${stellenanzeige.length} Stellenanzeigen.');

  // Generate dart file content
  final dartCode = '''
import '../../../domain/enums/document_type.dart';
import 'naive_bayes_classifier.dart';

class PretrainedModel {
  /// Creates a NaiveBayesClassifier pre-trained on German job application texts.
  static NaiveBayesClassifier create() {
    var classifier = NaiveBayesClassifier();
    
    var samples = {
      DocumentType.anschreiben: [
        \${anschreiben.join(',\\n        ')}
      ],
      DocumentType.stellenanzeige: [
        \${stellenanzeige.join(',\\n        ')}
      ],
      DocumentType.absage: [
        "Ihre Bewerbung als Fachinformatiker Sehr geehrter Herr Kurz wir bedanken uns fǬr Ihre Bewerbung leider mǬssen wir Ihnen mitteilen dass wir uns fǬr einen anderen Bewerber entschieden haben",
        "wir haben Ihre Bewerbung sorgfltig geprǬft leider knnen wir Ihre Bewerbung nicht berǬcksichtigen die Stelle wurde anderweitig besetzt",
        "Absage Bewerbung als IT-Consultant wir danken Ihnen fǬr das entgegengebrachte Interesse und die Ǭbersendung Ihrer Unterlagen leider fiel die Entscheidung auf einen Mitbewerber",
        "Ihre Bewerbung bei uns Sehr geehrte Frau MǬller wir bedauern Ihnen mitteilen zu mǬssen dass wir Ihnen keine positive Nachricht geben knnen",
        "Wir danken fǬr das angenehme Gesprch leider mǬssen wir Ihnen heute eine Absage erteilen",
        "Leider knnen wir Sie im aktuellen Auswahlverfahren nicht weiter berǬcksichtigen wir wǬnschen Ihnen fǬr Ihre berufliche Zukunft alles Gute",
      ],
      DocumentType.einladung: [
        "Einladung zum Vorstellungsgesprch Sehr geehrter Herr Kurz wir mchten Sie gerne persnlich kennenlernen und laden Sie herzlich zu einem Vorstellungsgesprch ein",
        "Interview-Einladung vielen Dank fǬr Ihre Bewerbung wir wǬrden uns freuen Sie zu einem persnlichen Gesprch einzuladen",
        "Einladung zum Online-Interview Sehr geehrte Frau Schmidt",
        "Wir freuen uns Sie zu einem Kennenlerngesprch in unser BǬro einzuladen",
        "Vorstellungsgesprch Terminbesttigung",
      ],
      DocumentType.bestaetigung: [
        "Eingangsbesttigung Ihrer Bewerbung Sehr geehrter Herr Kurz vielen Dank fǬr Ihre Bewerbung wir haben Ihre Unterlagen erhalten und werden diese sorgfltig prǬfen",
        "Besttigung Bewerbungseingang wir besttigen den Eingang Ihrer Bewerbung als Fachinformatiker",
        "Vielen Dank fǬr Ihre Bewerbung und das entgegengebrachte Interesse an unserem Unternehmen",
        "Wir haben Ihre Bewerbungsunterlagen erhalten und melden uns in KǬrze",
      ],
      DocumentType.lebenslauf: [
        "Lebenslauf Michael Kurz Persnliche Daten Geburtsdatum Berufserfahrung Ausbildung Fachinformatiker Systemintegration Kenntnisse Windows Linux",
        "Curriculum Vitae Beruflicher Werdegang Schulbildung Weiterbildung EDV-Kenntnisse Sprachen Hobbys",
        "Werdegang Berufserfahrung Praktika IT-Kenntnisse Schulischer Werdegang",
        "CV Personal Details Work Experience Education Skills Languages",
      ],
      DocumentType.zertifikat: [
        "Zeugnis Ausbildungszeugnis Herr Kurz hat die Ausbildung zum Fachinformatiker mit der Note gut bestanden",
        "Zertifikat ITIL Foundation Certificate hiermit wird besttigt dass Herr Kurz die PrǬfung erfolgreich bestanden hat",
        "IHK Abschlusszeugnis Fachinformatiker",
        "Teilnahmebescheinigung Schulung Seminar Azure Administrator",
        "Zertifikat Microsoft Certified Professional",
      ],
    };

    classifier.trainBatch(samples);
    return classifier;
  }
}
''';

  // Fix some encoding glitches that were hardcoded
  final fixedCode = dartCode
      .replaceAll('fǬr', 'für')
      .replaceAll('MǬller', 'Müller')
      .replaceAll('groYem', 'großem')
      .replaceAll('mehrjhrige', 'mehrjährige')
      .replaceAll('nchstmglichen', 'nächstmöglichen')
      .replaceAll('mglich', 'möglich')
      .replaceAll('UnterstǬtzung', 'Unterstützung')
      .replaceAll('sorgfltig', 'sorgfältig')
      .replaceAll('prǬfen', 'prüfen')
      .replaceAll('knnen', 'können')
      .replaceAll('berǬcksichtigen', 'berücksichtigen')
      .replaceAll('Ǭbersendung', 'Übersendung')
      .replaceAll('Gesprch', 'Gespräch')
      .replaceAll('wǬnschen', 'wünschen')
      .replaceAll('persnlich', 'persönlich')
      .replaceAll('BǬro', 'Büro')
      .replaceAll('Besttigung', 'Bestätigung')
      .replaceAll('besttigt', 'bestätigt')
      .replaceAll('PrǬfung', 'Prüfung')
      .replaceAll('Persnliche', 'Persönliche');

  final targetFile = File(r'S:\Projekte\JobTracker\lib\core\services\ml\pretrained_model.dart');
  targetFile.writeAsStringSync(fixedCode);
  print('Successfully updated PretrainedModel!');
}
