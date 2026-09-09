// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_dao.dart';

// ignore_for_file: type=lint
mixin _$CvDaoMixin on DatabaseAccessor<AppDatabase> {
  $ApplicationsTable get applications => attachedDatabase.applications;
  $CvWorkExperiencesTable get cvWorkExperiences =>
      attachedDatabase.cvWorkExperiences;
  $CvEducationsTable get cvEducations => attachedDatabase.cvEducations;
  $CvSkillsTable get cvSkills => attachedDatabase.cvSkills;
  $CvLanguagesTable get cvLanguages => attachedDatabase.cvLanguages;
  CvDaoManager get managers => CvDaoManager(this);
}

class CvDaoManager {
  final _$CvDaoMixin _db;
  CvDaoManager(this._db);
  $$ApplicationsTableTableManager get applications =>
      $$ApplicationsTableTableManager(_db.attachedDatabase, _db.applications);
  $$CvWorkExperiencesTableTableManager get cvWorkExperiences =>
      $$CvWorkExperiencesTableTableManager(
        _db.attachedDatabase,
        _db.cvWorkExperiences,
      );
  $$CvEducationsTableTableManager get cvEducations =>
      $$CvEducationsTableTableManager(_db.attachedDatabase, _db.cvEducations);
  $$CvSkillsTableTableManager get cvSkills =>
      $$CvSkillsTableTableManager(_db.attachedDatabase, _db.cvSkills);
  $$CvLanguagesTableTableManager get cvLanguages =>
      $$CvLanguagesTableTableManager(_db.attachedDatabase, _db.cvLanguages);
}
