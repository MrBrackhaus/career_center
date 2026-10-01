import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertApp() => db.applicationsDao.insertApplication(
    ApplicationsCompanion.insert(company: 'Firma', position: 'Dev'),
  );

  test('Berufserfahrung: aktuelle zuerst, danach neuestes Startdatum', () async {
    Future<void> add(String company, DateTime start, {bool current = false}) =>
        db.cvDao.insertWorkExperience(
          CvWorkExperiencesCompanion.insert(
            company: company,
            position: 'P',
            startDate: Value(start),
            isCurrent: Value(current),
          ),
        );
    await add('Alt', DateTime(2010));
    await add('Aktuell', DateTime(2015), current: true);
    await add('Neu', DateTime(2020));

    final list = await db.cvDao.getWorkExperiences(null);
    expect(list.map((e) => e.company), ['Aktuell', 'Neu', 'Alt']);
  });

  test('Ausbildung: neuestes Startdatum zuerst', () async {
    for (final year in [2005, 2012, 2009]) {
      await db.cvDao.insertEducation(
        CvEducationsCompanion.insert(
          institution: 'I$year',
          degree: 'D',
          startDate: Value(DateTime(year)),
          endDate: Value(DateTime(year + 2)),
        ),
      );
    }
    final list = await db.cvDao.getEducations(null);
    expect(list.map((e) => e.institution), ['I2012', 'I2009', 'I2005']);
  });

  test('Eigene Einträge ohne sortOrder bekommen max + 1', () async {
    final appId = await insertApp();
    CvCustomItemsCompanion item(String title) => CvCustomItemsCompanion.insert(
      applicationId: Value(appId),
      sectionName: 'S',
      title: title,
    );
    await db.cvDao.insertCustomItem(item('A'));
    await db.cvDao.insertCustomItem(item('B'));
    await db.cvDao.insertCustomItem(item('C'));

    final list = await db.cvDao.getCustomItems(appId);
    expect(list.map((e) => e.title), ['A', 'B', 'C']);
    expect(list.map((e) => e.sortOrder), [0, 1, 2]);
  });

  test('copyMasterToApplication kopiert alle Master-Einträge', () async {
    final appId = await insertApp();
    await db.cvDao.insertWorkExperience(
      CvWorkExperiencesCompanion.insert(company: 'M', position: 'P'),
    );
    await db.cvDao.insertEducation(
      CvEducationsCompanion.insert(institution: 'Uni', degree: 'BSc'),
    );
    await db.cvDao.insertSkill(CvSkillsCompanion.insert(name: 'Dart'));
    await db.cvDao.insertLanguage(
      CvLanguagesCompanion.insert(name: 'Englisch', level: 'B2'),
    );
    await db.cvDao.insertCustomItem(
      CvCustomItemsCompanion.insert(sectionName: 'Hobbys', title: 'Lesen'),
    );

    final copied = await db.cvDao.copyMasterToApplication(appId);
    expect(copied, 5);

    expect((await db.cvDao.getWorkExperiences(appId)).single.company, 'M');
    expect((await db.cvDao.getEducations(appId)).single.institution, 'Uni');
    expect((await db.cvDao.getSkills(appId)).single.name, 'Dart');
    expect((await db.cvDao.getLanguages(appId)).single.level, 'B2');
    expect((await db.cvDao.getCustomItems(appId)).single.title, 'Lesen');

    // Master-Pool bleibt unverändert.
    expect(await db.cvDao.getWorkExperiences(null), hasLength(1));
    expect(await db.cvDao.getSkills(null), hasLength(1));
  });
}
