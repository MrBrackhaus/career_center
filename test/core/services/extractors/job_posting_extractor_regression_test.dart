import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/extractors/job_posting_extractor.dart';

void main() {
  group('JobPostingExtractor - JSON-LD', () {
    test('Gehalt aus QuantitativeValue mit min/max und Währung', () {
      const html = '''
<html><head>
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "JobPosting",
  "title": "Sachbearbeiter Buchhaltung (m/w/d)",
  "hiringOrganization": {"@type": "Organization", "name": "Stadtwerke Musterstadt GmbH"},
  "baseSalary": {
    "@type": "MonetaryAmount",
    "currency": "EUR",
    "value": {"@type": "QuantitativeValue", "minValue": 42000, "maxValue": 51000, "unitText": "YEAR"}
  }
}
</script></head><body><p>Text</p></body></html>
''';
      final result = JobPostingExtractor.extractFromHtml(html);
      expect(result.position?.value, 'Sachbearbeiter Buchhaltung (m/w/d)');
      expect(result.company?.value, 'Stadtwerke Musterstadt GmbH');
      expect(result.salaryInfo?.value, '42.000 - 51.000 EUR pro Jahr');
    });

    test('Gehalt mit Einzelwert und Monatsangabe', () {
      const html = '''
<script type="application/ld+json">
{"@type": "JobPosting", "title": "Pflegefachkraft",
 "baseSalary": {"currency": "EUR", "value": {"value": 3850, "unitText": "MONTH"}}}
</script>
''';
      final result = JobPostingExtractor.extractFromHtml(html);
      expect(result.salaryInfo?.value, '3.850 EUR pro Monat');
    });

    test('JobPosting in @graph und mit @type als Liste', () {
      const html = '''
<script type="application/ld+json">
{"@context": "https://schema.org", "@graph": [
  {"@type": "WebPage", "name": "Karriere"},
  {"@type": ["JobPosting"], "title": "Lagerist (m/w/d)",
   "hiringOrganization": "Logistik Nord GmbH"}
]}
</script>
''';
      final result = JobPostingExtractor.extractFromHtml(html);
      expect(result.position?.value, 'Lagerist (m/w/d)');
      expect(result.company?.value, 'Logistik Nord GmbH');
    });

    test('Unerwartete JSON-LD-Struktur fällt auf sichtbaren Text zurück, nicht auf rohes HTML', () {
      const html = '''
<html><head>
<style>body { color: red; }</style>
<script type="application/ld+json">["JobPosting", 42, {"@type": "JobPosting", "jobLocation": [17]}]</script>
<script>var tracking = "Gehalt 9999 €";</script>
</head>
<body>
<h1>Elektroniker für Betriebstechnik (m/w/d)</h1>
<noscript>Bitte JavaScript aktivieren</noscript>
<p>Wir bieten ein Gehalt von 3.500 EUR brutto.</p>
</body></html>
''';
      final result = JobPostingExtractor.extractFromHtml(html);
      expect(result.position?.value, isNot(contains('<')));
      expect(result.position?.value, isNot(contains('color')));
      expect(result.salaryInfo?.value, isNot(contains('9999')));
    });

    test('Fallback ohne JSON-LD ignoriert script/style-Inhalte', () {
      const html = '''
<html><head><script>window.dataLayer = [];</script><style>.x{}</style></head>
<body><script>console.log("Muster AG");</script>
<p>Elektroniker (m/w/d)</p>
</body></html>
''';
      final result = JobPostingExtractor.extractFromHtml(html);
      expect(result.position?.value, 'Elektroniker (m/w/d)');
      expect(result.company, isNull);
    });
  });

  group('JobPostingExtractor - Titel', () {
    test('Sehr lange Zeile ohne Gender-Muster ist schnell', () {
      final longLine = 'a' * 200000;
      final sw = Stopwatch()..start();
      JobPostingExtractor.extract('$longLine\nKaufmann im Einzelhandel (m/w/d)');
      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(2000));
    });

    test('Erkennt Gender-Muster mit Leerzeichen und anderer Reihenfolge', () {
      final result =
          JobPostingExtractor.extract('Über uns\nMechatroniker ( w / m / d )\n');
      expect(result.position?.value, 'Mechatroniker ( w / m / d )');
      expect(result.position?.source, 'title_with_gender');
    });
  });

  group('JobPostingExtractor - Firma', () {
    test('Wort mit Endung "se"/"ag" ist keine Rechtsform', () {
      const text = '''
Softwareentwickler (m/w/d)
Ihr Profil
Gute Deutschkenntnisse
Teamfähigkeit und Lernbereitschaft auf jeden Tag
Muster Software AG
''';
      final result = JobPostingExtractor.extract(text);
      expect(result.company?.value, 'Muster Software AG');
    });

    test('GmbH & Co. KG wird erkannt', () {
      final result = JobPostingExtractor.extract(
        'Lagerhelfer (m/w/d)\nGute Kenntnisse\nSpedition Meier GmbH & Co. KG\n',
      );
      expect(result.company?.value, 'Spedition Meier GmbH & Co. KG');
    });
  });

  group('JobPostingExtractor - Gehalt', () {
    test('"Ingenieur" ist keine Gehaltsangabe', () {
      const text = '''
Ingenieur Elektrotechnik (m/w/d)
Wir suchen einen Ingenieur für unser Team.
Bewerben Sie sich jetzt.
''';
      final result = JobPostingExtractor.extract(text);
      expect(result.salaryInfo, isNull);
    });

    test('Betrag mit EUR wird als Gehalt erkannt', () {
      const text = '''
Ingenieur Elektrotechnik (m/w/d)
Bis zu 65.000 EUR brutto im Jahr
''';
      final result = JobPostingExtractor.extract(text);
      expect(result.salaryInfo?.value, 'Bis zu 65.000 EUR brutto im Jahr');
    });

    test('Betrag mit €-Zeichen wird als Gehalt erkannt', () {
      final result =
          JobPostingExtractor.extract('Koch (m/w/d)\nStundenlohn ab 16,50 €\n');
      expect(result.salaryInfo?.value, 'Stundenlohn ab 16,50 €');
    });
  });

  group('JobPostingExtractor - Kontakt', () {
    test('Kleingeschriebene Satzwörter nach "Kontakt" sind kein Name', () {
      const text = '''
Verkäufer (m/w/d)
Ihr Kontakt zu uns ist jederzeit möglich.
Recruiter in unserem Team helfen gerne.
''';
      final result = JobPostingExtractor.extract(text);
      expect(result.contactName, isNull);
    });

    test('Kleingeschriebenes Schlüsselwort mit echtem Namen wird erkannt', () {
      final result = JobPostingExtractor.extract(
        'Verkäufer (m/w/d)\nFragen? ihre Ansprechpartnerin: Frau Lena Krüger\n',
      );
      expect(result.contactName?.value, 'Lena Krüger');
    });
  });

  group('JobPostingExtractor - Telefon', () {
    test('Geburtsdatum ist keine Telefonnummer', () {
      const text = '''
Bürokaufmann (m/w/d)
Geboren am 15.03.1990 in Hamburg
''';
      final result = JobPostingExtractor.extract(text);
      expect(result.contactPhone, isNull);
    });

    test('Telefonnummer mit Kontext wird erkannt und endet an der Zeile', () {
      const text = '''
Bürokaufmann (m/w/d)
Telefon: 040 / 123 456 78
22767 Hamburg
''';
      final result = JobPostingExtractor.extract(text);
      expect(result.contactPhone?.value, '040 / 123 456 78');
    });

    test('Mobilnummer ohne Kontext wird erkannt', () {
      final result = JobPostingExtractor.extract(
        'Fahrer (m/w/d)\nRuf an: 0176 12345678\n',
      );
      expect(result.contactPhone?.value, '0176 12345678');
    });

    test('Postleitzahl allein ist keine Telefonnummer', () {
      final result =
          JobPostingExtractor.extract('Fahrer (m/w/d)\n01067 Dresden\n');
      expect(result.contactPhone, isNull);
    });
  });

  group('JobPostingExtractor - Adresse', () {
    test('Fallback PLZ/Ort behält die Stadt', () {
      final result =
          JobPostingExtractor.extract('Fahrer (m/w/d)\nEinsatzort: 50667 Köln\n');
      expect(result.address?.value, '50667 Köln');
    });

    test('Großgeschriebene "Straße" wird erkannt', () {
      const text = '''
Fahrer (m/w/d)
Muster Logistik GmbH
Lange Straße 12
26122 Oldenburg
''';
      final result = JobPostingExtractor.extract(text);
      expect(result.address?.value, 'Lange Straße 12, 26122 Oldenburg');
    });
  });
}
