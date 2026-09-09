import 'package:drift/drift.dart';

import '../app_database.dart';

part 'cv_dao.g.dart';

@DriftAccessor(tables: [CvWorkExperiences, CvEducations, CvSkills, CvLanguages])
class CvDao extends DatabaseAccessor<AppDatabase> with _$CvDaoMixin {
  CvDao(super.db);

  // === Work Experiences ===
  Future<List<CvWorkExperience>> getWorkExperiences(int? applicationId) {
    if (applicationId == null) {
      return (select(
        cvWorkExperiences,
      )..where((t) => t.applicationId.isNull())).get();
    }
    return (select(
      cvWorkExperiences,
    )..where((t) => t.applicationId.equals(applicationId))).get();
  }

  Future<int> insertWorkExperience(CvWorkExperiencesCompanion entry) {
    return into(cvWorkExperiences).insert(entry);
  }

  Future<bool> updateWorkExperience(CvWorkExperiencesCompanion entry) {
    return update(cvWorkExperiences).replace(entry);
  }

  Future<int> deleteWorkExperience(int id) {
    return (delete(cvWorkExperiences)..where((t) => t.id.equals(id))).go();
  }

  // === Educations ===
  Future<List<CvEducation>> getEducations(int? applicationId) {
    if (applicationId == null) {
      return (select(
        cvEducations,
      )..where((t) => t.applicationId.isNull())).get();
    }
    return (select(
      cvEducations,
    )..where((t) => t.applicationId.equals(applicationId))).get();
  }

  Future<int> insertEducation(CvEducationsCompanion entry) {
    return into(cvEducations).insert(entry);
  }

  Future<bool> updateEducation(CvEducationsCompanion entry) {
    return update(cvEducations).replace(entry);
  }

  Future<int> deleteEducation(int id) {
    return (delete(cvEducations)..where((t) => t.id.equals(id))).go();
  }

  // === Skills ===
  Future<List<CvSkill>> getSkills(int? applicationId) {
    if (applicationId == null) {
      return (select(cvSkills)..where((t) => t.applicationId.isNull())).get();
    }
    return (select(
      cvSkills,
    )..where((t) => t.applicationId.equals(applicationId))).get();
  }

  Future<int> insertSkill(CvSkillsCompanion entry) {
    return into(cvSkills).insert(entry);
  }

  Future<bool> updateSkill(CvSkillsCompanion entry) {
    return update(cvSkills).replace(entry);
  }

  Future<int> deleteSkill(int id) {
    return (delete(cvSkills)..where((t) => t.id.equals(id))).go();
  }

  // === Languages ===
  Future<List<CvLanguage>> getLanguages(int? applicationId) {
    if (applicationId == null) {
      return (select(
        cvLanguages,
      )..where((t) => t.applicationId.isNull())).get();
    }
    return (select(
      cvLanguages,
    )..where((t) => t.applicationId.equals(applicationId))).get();
  }

  Future<int> insertLanguage(CvLanguagesCompanion entry) {
    return into(cvLanguages).insert(entry);
  }

  Future<bool> updateLanguage(CvLanguagesCompanion entry) {
    return update(cvLanguages).replace(entry);
  }

  Future<int> deleteLanguage(int id) {
    return (delete(cvLanguages)..where((t) => t.id.equals(id))).go();
  }
}
