import 'package:career_center/core/utils/cv_plain_text.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/presentation/providers/cv_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Profil-JSON und Einträge werden zu lesbarem Text', () {
    const content =
        '{"cvProfile":{"name":"Erika Musterfrau","title":"Fachinformatikerin","intro":"Erfahren in Linux."},'
        '"letterHeader":{"companyName":"Beispiel GmbH"}}';
    final data = CvDataState(
      experiences: [
        CvWorkExperience(
          id: 1,
          company: 'Muster AG',
          position: 'Admin',
          startDate: DateTime(2020, 3),
          isCurrent: true,
        ),
      ],
      educations: const [],
      skills: const [CvSkill(id: 1, name: 'Linux', level: 4)],
      languages: const [CvLanguage(id: 1, name: 'Englisch', level: 'B2')],
      customItems: const [],
    );

    final text = buildCvPlainText(content, data);

    expect(text, contains('Name: Erika Musterfrau'));
    expect(text, contains('Berufsbezeichnung: Fachinformatikerin'));
    expect(text, contains('- Admin bei Muster AG (03/2020 – heute)'));
    expect(text, contains('Kenntnisse: Linux (4/5)'));
    expect(text, contains('Sprachen: Englisch (B2)'));
    // Briefkopf-Daten gehören nicht in den Lebenslauf und kein rohes JSON.
    expect(text, isNot(contains('Beispiel GmbH')));
    expect(text, isNot(contains('{')));
  });

  test('Alter Klartext ohne JSON bleibt erhalten', () {
    expect(buildCvPlainText('Mein Lebenslauf', null), 'Mein Lebenslauf');
    expect(buildCvPlainText(null, null), '');
  });
}
