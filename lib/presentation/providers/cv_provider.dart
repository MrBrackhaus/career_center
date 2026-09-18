import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

class CvDataState {
  final List<CvWorkExperience> experiences;
  final List<CvEducation> educations;
  final List<CvSkill> skills;
  final List<CvLanguage> languages;
  final List<CvCustomItem> customItems;

  CvDataState({
    required this.experiences,
    required this.educations,
    required this.skills,
    required this.languages,
    required this.customItems,
  });
}

final cvProvider = FutureProvider.autoDispose.family<CvDataState, int?>((ref, applicationId) async {
  final db = ref.watch(databaseProvider);
  final dao = db.cvDao;

  final experiences = await dao.getWorkExperiences(applicationId);
  final educations = await dao.getEducations(applicationId);
  final skills = await dao.getSkills(applicationId);
  final languages = await dao.getLanguages(applicationId);
  final customItems = await dao.getCustomItems(applicationId);

  return CvDataState(
    experiences: experiences,
    educations: educations,
    skills: skills,
    languages: languages,
    customItems: customItems,
  );
});

final cvNotifierProvider = Provider<CvNotifier>((ref) {
  return CvNotifier(ref);
});

class CvNotifier {
  final Ref ref;

  CvNotifier(this.ref);



  Future<void> addWorkExperience(
    int? applicationId,
    String company,
    String position,
    DateTime? startDate,
    DateTime? endDate,
    bool isCurrent,
    String? description,
  ) async {
    try {
        final db = ref.read(databaseProvider);
        await db.cvDao.insertWorkExperience(
          CvWorkExperiencesCompanion.insert(
            applicationId: applicationId == null ? const Value.absent() : Value(applicationId),
            company: company,
            position: position,
            startDate: startDate == null ? const Value.absent() : Value(startDate),
            endDate: endDate == null ? const Value.absent() : Value(endDate),
            isCurrent: Value(isCurrent),
            description: description == null ? const Value.absent() : Value(description),
          ),
        );
        ref.invalidate(cvProvider(applicationId));
    } catch (e, stack) {
        
        File('error_log.txt').writeAsStringSync('ERROR: $e\n$stack');
        print("ERROR IN ADDWORKEXP: $e");
    }
  }
  Future<void> updateWorkExperience(int? applicationId, CvWorkExperience exp) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.updateWorkExperience(
      CvWorkExperiencesCompanion(
        id: Value(exp.id),
        applicationId: Value(exp.applicationId),
        company: Value(exp.company),
        position: Value(exp.position),
        startDate: Value(exp.startDate),
        endDate: Value(exp.endDate),
        isCurrent: Value(exp.isCurrent),
        description: Value(exp.description),
      )
    );
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> deleteWorkExperience(int? applicationId, int id) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.deleteWorkExperience(id);
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> addEducation(
    int? applicationId,
    String institution,
    String degree,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
  ) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.insertEducation(
      CvEducationsCompanion.insert(
        applicationId: applicationId == null ? const Value.absent() : Value(applicationId),
        institution: institution,
        degree: degree,
        startDate: Value(startDate),
        endDate: Value(endDate),
        description: Value(description),
      ),
    );
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> updateEducation(int? applicationId, CvEducation edu) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.updateEducation(
      CvEducationsCompanion(
        id: Value(edu.id),
        applicationId: Value(edu.applicationId),
        institution: Value(edu.institution),
        degree: Value(edu.degree),
        startDate: Value(edu.startDate),
        endDate: Value(edu.endDate),
        description: Value(edu.description),
      )
    );
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> deleteEducation(int? applicationId, int id) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.deleteEducation(id);
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> addSkill(
    int? applicationId,
    String name,
    int level,
  ) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.insertSkill(
      CvSkillsCompanion.insert(
        applicationId: applicationId == null ? const Value.absent() : Value(applicationId),
        name: name,
        level: Value(level),
      ),
    );
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> updateSkill(int? applicationId, CvSkill skill) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.updateSkill(
      CvSkillsCompanion(
        id: Value(skill.id),
        applicationId: Value(skill.applicationId),
        name: Value(skill.name),
        level: Value(skill.level),
      )
    );
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> deleteSkill(int? applicationId, int id) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.deleteSkill(id);
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> addLanguage(
    int? applicationId,
    String name,
    String level,
  ) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.insertLanguage(
      CvLanguagesCompanion.insert(
        applicationId: applicationId == null ? const Value.absent() : Value(applicationId),
        name: name,
        level: level,
      ),
    );
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> updateLanguage(int? applicationId, CvLanguage language) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.updateLanguage(
      CvLanguagesCompanion(
        id: Value(language.id),
        applicationId: Value(language.applicationId),
        name: Value(language.name),
        level: Value(language.level),
      )
    );
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> deleteLanguage(int? applicationId, int id) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.deleteLanguage(id);
    ref.invalidate(cvProvider(applicationId));
  }


  Future<void> addCustomItem(
    int? applicationId,
    String sectionName,
    String title,
    String? subtitle,
    String? dateRange,
    String? description,
    int sortOrder,
  ) async {
    try {
        final db = ref.read(databaseProvider);
        await db.cvDao.insertCustomItem(
          CvCustomItemsCompanion.insert(
            applicationId: applicationId == null ? const Value.absent() : Value(applicationId),
            sectionName: sectionName,
            title: title,
            subtitle: subtitle == null ? const Value.absent() : Value(subtitle),
            dateRange: dateRange == null ? const Value.absent() : Value(dateRange),
            description: description == null ? const Value.absent() : Value(description),
            sortOrder: Value(sortOrder),
          ),
        );
        ref.invalidate(cvProvider(applicationId));
    } catch (e, stack) {
        File('error_log.txt').writeAsStringSync('ERROR CUSTOM: $e\n$stack', mode: FileMode.append);
    }
  }
  Future<void> deleteCustomItem(int? applicationId, int id) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.deleteCustomItem(id);
    ref.invalidate(cvProvider(applicationId));
  }

  Future<void> updateCustomItem(
    int? applicationId,
    int id,
    String sectionName,
    String title,
    String? subtitle,
    String? dateRange,
    String? description,
    int sortOrder,
  ) async {
    final db = ref.read(databaseProvider);
    await db.cvDao.updateCustomItem(
      CvCustomItemsCompanion(
        id: Value(id),
        applicationId: applicationId == null ? const Value.absent() : Value(applicationId),
        sectionName: Value(sectionName),
        title: Value(title),
        subtitle: subtitle == null ? const Value.absent() : Value(subtitle),
        dateRange: dateRange == null ? const Value.absent() : Value(dateRange),
        description: description == null ? const Value.absent() : Value(description),
        sortOrder: Value(sortOrder),
      ),
    );
    ref.invalidate(cvProvider(applicationId));
  }
}




