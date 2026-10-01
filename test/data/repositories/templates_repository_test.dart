import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/data/repositories/editor_repository.dart';
import 'package:career_center/data/repositories/templates_repository.dart';
import 'package:career_center/domain/entities/template_entity.dart';

void main() {
  late AppDatabase db;
  late TemplatesRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TemplatesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> insertLinkedTemplate() async {
    final appId = await db.applicationsDao.insertApplication(
      ApplicationsCompanion.insert(company: 'Firma', position: 'Dev'),
    );
    return repo.addTemplate(
      'Original',
      'anschreiben',
      'Inhalt',
      filePath: '/tmp/original.pdf',
      applicationId: appId,
    );
  }

  test('Mapper übernimmt applicationId', () async {
    final id = await insertLinkedTemplate();
    final entity = (await repo.getAllTemplates()).singleWhere((t) => t.id == id);
    expect(entity.applicationId, isNotNull);
    expect(entity.filePath, '/tmp/original.pdf');
  });

  test('updateTemplate behält applicationId, filePath und createdAt', () async {
    final id = await insertLinkedTemplate();
    final before = await db.templatesDao.getTemplateById(id);

    await repo.updateTemplate(
      TemplateEntity(
        id: id,
        name: 'Neu',
        type: 'anschreiben',
        content: 'Neuer Inhalt',
        createdAt: DateTime(2000),
      ),
    );

    final after = await db.templatesDao.getTemplateById(id);
    expect(after!.name, 'Neu');
    expect(after.content, 'Neuer Inhalt');
    expect(after.applicationId, before!.applicationId);
    expect(after.filePath, '/tmp/original.pdf');
    expect(after.createdAt, before.createdAt);
  });

  test('EditorRepository.saveTemplate legt einmal an und aktualisiert dann', () async {
    final editorRepo = EditorRepository(db);
    final id = await editorRepo.saveTemplate(null, 'Doc', 'anschreiben', '[]');
    final sameId = await editorRepo.saveTemplate(id, 'Doc 2', 'anschreiben', '[]');

    expect(sameId, id);
    final all = await repo.getAllTemplates();
    expect(all, hasLength(1));
    expect(all.single.name, 'Doc 2');
  });
}
