import 'package:drift/drift.dart' as drift;

import '../../data/database/app_database.dart';

Future<void> seedTextbausteine(AppDatabase db) async {
  final templates = [
    TemplatesCompanion.insert(
      name: 'Einleitung Klassisch',
      type: 'textbaustein',
      content: drift.Value(
        '[{"insert":"Sehr geehrte Damen und Herren,\\n\\nhiermit bewerbe ich mich mit großem Interesse auf die ausgeschriebene Position.\\n"}]',
      ),
    ),
    TemplatesCompanion.insert(
      name: 'Einleitung Dynamisch',
      type: 'textbaustein',
      content: drift.Value(
        '[{"insert":"Sehr geehrte Damen und Herren,\\n\\nIhre Unternehmenswerte haben mich sofort begeistert, weshalb ich mich freue, mich Ihnen heute als engagierter Kandidat vorzustellen.\\n"}]',
      ),
    ),
    TemplatesCompanion.insert(
      name: 'Gehaltsvorstellung',
      type: 'textbaustein',
      content: drift.Value(
        '[{"insert":"Meine Gehaltsvorstellungen liegen bei einem Bruttojahresgehalt von XY Euro. Ein Einstieg ist ab dem [Datum] möglich.\\n"}]',
      ),
    ),
    TemplatesCompanion.insert(
      name: 'Teamfähigkeit',
      type: 'textbaustein',
      content: drift.Value(
        '[{"insert":"In meinen bisherigen Projekten konnte ich stets durch eine starke Teamfähigkeit und lösungsorientierte Arbeitsweise überzeugen.\\n"}]',
      ),
    ),
    TemplatesCompanion.insert(
      name: 'Call to Action',
      type: 'textbaustein',
      content: drift.Value(
        '[{"insert":"Ich freue mich sehr auf die Gelegenheit, Sie in einem persönlichen Gespräch von meiner Eignung zu überzeugen.\\n\\nMit freundlichen Grüßen\\n"}]',
      ),
    ),
  ];
  for (final t in templates) {
    await db.templatesDao.insertTemplate(t);
  }
}
