import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/data/repositories/applications_repository.dart';
import 'package:career_center/domain/models/application_form_dto.dart';

void main() {
  late AppDatabase db;
  late ApplicationsRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ApplicationsRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('updateApplication lässt Spalten außerhalb des DTO unverändert', () async {
    final id = await db.applicationsDao.insertApplication(
      ApplicationsCompanion.insert(
        company: 'Alt GmbH',
        position: 'Dev',
        status: const Value('versendet'),
        priority: const Value(5),
        coverLetterContent: const Value('Anschreiben'),
      ),
    );

    await repo.updateApplication(
      ApplicationFormDto(
        id: id,
        company: 'Neu GmbH',
        position: 'Senior Dev',
        status: 'interview',
      ),
    );

    final app = await db.applicationsDao.getApplicationById(id);
    expect(app, isNotNull);
    expect(app!.company, 'Neu GmbH');
    expect(app.position, 'Senior Dev');
    expect(app.status, 'interview');
    expect(app.priority, 5);
    expect(app.coverLetterContent, 'Anschreiben');
  });

  test('Status wird beim Schreiben normalisiert', () async {
    final id = await repo.addApplication(
      ApplicationFormDto(company: 'A', position: 'P', status: 'Absage'),
    );
    expect((await db.applicationsDao.getApplicationById(id))!.status, 'absage');

    await repo.updateApplicationStatus(id, 'bestaetigung');
    expect(
      (await db.applicationsDao.getApplicationById(id))!.status,
      'versendet',
    );

    await repo.updateApplicationStatus(id, 'angebot');
    expect((await db.applicationsDao.getApplicationById(id))!.status, 'zusage');
  });
}
