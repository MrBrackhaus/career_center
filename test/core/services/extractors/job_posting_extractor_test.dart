import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/extractors/job_posting_extractor.dart';

void main() {
  group('JobPostingExtractor - Externe Bewerbungslinks', () {
    test('Findet bekannte Bewerbungsportale in hrefs', () {
      const html = '''
        <html>
          <body>
            <p>Bitte bewerben Sie sich hier:</p>
            <a href="https://mycompany.personio.de/job/12345">Bewerben</a>
            <a href="https://jobs.lever.co/company/67890">Hier gehts weiter</a>
            <a href="https://google.com">Einfacher Link</a>
          </body>
        </html>
      ''';

      final links = JobPostingExtractor.findExternalApplicationLinks(html);
      
      expect(links.length, 2);
      expect(links, contains('https://mycompany.personio.de/job/12345'));
      expect(links, contains('https://jobs.lever.co/company/67890'));
      expect(links, isNot(contains('https://google.com')));
    });

    test('Findet generische URLs durch Bewerbungs-Keywords im Link-Text', () {
      const html = '''
        <html>
          <body>
            <a href="https://firmenwebsite.de/karriere/formular?id=99">Jetzt online bewerben!</a>
            <a href="https://firmenwebsite.de/impressum">Impressum</a>
            <a href="https://firmenwebsite.de/apply/job1" title="Apply now">Link ohne passenden Text</a>
          </body>
        </html>
      ''';

      final links = JobPostingExtractor.findExternalApplicationLinks(html);
      
      expect(links.length, 2);
      expect(links, contains('https://firmenwebsite.de/karriere/formular?id=99'));
      expect(links, contains('https://firmenwebsite.de/apply/job1'));
    });

    test('Ignoriert relative URLs, Anker und Javascript', () {
      const html = '''
        <html>
          <body>
            <a href="/jobs/123">Jetzt bewerben</a>
            <a href="#formular">Online bewerben</a>
            <a href="javascript:void(0)" title="Jetzt bewerben">Button</a>
          </body>
        </html>
      ''';

      final links = JobPostingExtractor.findExternalApplicationLinks(html);
      
      expect(links, isEmpty);
    });
  });

  group('JobPostingExtractor - Erweiterte Kontaktdaten-Erkennung', () {
    test('Erkennt informelle deutsche Formulierungen', () {
      const text = '''
        Wir freuen uns auf deine Bewerbung!
        Dein Ansprechpartner: Max Mustermann
        Melde dich gerne.
      ''';

      final result = JobPostingExtractor.extract(text);
      expect(result.contactName?.value, 'Max Mustermann');
      expect(result.contactName?.source, 'contact_informal_pattern');
    });

    test('Erkennt englische Formulierungen', () {
      const text = '''
        Looking forward to your application.
        Hiring Manager: Mrs. Jane Doe
        Contact us!
      ''';

      final result = JobPostingExtractor.extract(text);
      expect(result.contactName?.value, 'Jane Doe');
      expect(result.contactName?.source, 'contact_english_pattern');
    });

    test('Erkennt tabellarische Formate (mit Tabs/Leerzeichen)', () {
      const text = '''
        Position: Software Entwickler
        Ansprechperson:   Dr. Anna Schmidt
        Gehalt: 60.000 EUR
      ''';

      final result = JobPostingExtractor.extract(text);
      expect(result.contactName?.value, 'Anna Schmidt');
      expect(result.contactName?.source, 'contact_tabular_pattern');
    });

    test('Erkennt HR-Rollen in Kombination mit Kontakt-Keywords nicht falsch', () {
      const text = '''
        HR Manager
        Bitte nehmen Sie Kontakt auf.
        Frau Sabine Müller
      ''';

      final result = JobPostingExtractor.extract(text);
      expect(result.contactName?.value, 'Frau Sabine Müller');
    });
  });
}
