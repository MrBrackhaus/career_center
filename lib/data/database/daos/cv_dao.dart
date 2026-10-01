import 'package:drift/drift.dart';

import '../app_database.dart';

part 'cv_dao.g.dart';

@DriftAccessor(tables: [CvWorkExperiences, CvEducations, CvSkills, CvLanguages, CvCustomItems])
class CvDao extends DatabaseAccessor<AppDatabase> with _$CvDaoMixin {
  CvDao(super.db);

  // === Work Experiences ===
  /// Sortierung: aktuelle Stationen zuerst, danach neueste Startdaten zuerst.
  Future<List<CvWorkExperience>> getWorkExperiences(int? applicationId) {
    final query = select(cvWorkExperiences)
      ..where(
        (t) => applicationId == null
            ? t.applicationId.isNull()
            : t.applicationId.equals(applicationId),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.isCurrent),
        (t) => OrderingTerm.desc(t.startDate),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.get();
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
  /// Sortierung: laufende Ausbildungen (ohne Enddatum) zuerst, danach
  /// neueste Startdaten zuerst. (Die Tabelle hat keine isCurrent-Spalte.)
  Future<List<CvEducation>> getEducations(int? applicationId) {
    final query = select(cvEducations)
      ..where(
        (t) => applicationId == null
            ? t.applicationId.isNull()
            : t.applicationId.equals(applicationId),
      )
      ..orderBy([
        (t) => OrderingTerm.desc(t.endDate.isNull()),
        (t) => OrderingTerm.desc(t.startDate),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.get();
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

  // === Custom Items ===
  Future<List<CvCustomItem>> getCustomItems(int? applicationId) {
    final query = select(cvCustomItems)
      ..where(
        (t) => applicationId == null
            ? t.applicationId.isNull()
            : t.applicationId.equals(applicationId),
      )
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.id),
      ]);
    return query.get();
  }

  /// Nächster freier sortOrder-Wert (max + 1) für die Bewerbung bzw. den
  /// Master-Pool (applicationId == null).
  Future<int> nextCustomItemSortOrder(int? applicationId) async {
    final maxExpr = cvCustomItems.sortOrder.max();
    final query = selectOnly(cvCustomItems)
      ..addColumns([maxExpr])
      ..where(
        applicationId == null
            ? cvCustomItems.applicationId.isNull()
            : cvCustomItems.applicationId.equals(applicationId),
      );
    final max = await query.map((row) => row.read(maxExpr)).getSingle();
    return max == null ? 0 : max + 1;
  }

  /// Fügt einen Eintrag ein. Ist kein sortOrder gesetzt, wird er ans Ende
  /// (max + 1) einsortiert.
  Future<int> insertCustomItem(CvCustomItemsCompanion entry) async {
    var toInsert = entry;
    if (!entry.sortOrder.present) {
      final appId = entry.applicationId.present ? entry.applicationId.value : null;
      toInsert = entry.copyWith(
        sortOrder: Value(await nextCustomItemSortOrder(appId)),
      );
    }
    return into(cvCustomItems).insert(toInsert);
  }

  Future<bool> updateCustomItem(CvCustomItemsCompanion entry) {
    return update(cvCustomItems).replace(entry);
  }

  Future<int> deleteCustomItem(int id) {
    return (delete(cvCustomItems)..where((t) => t.id.equals(id))).go();
  }

  // === Master-Pool ===

  /// Kopiert alle Einträge des Master-Lebenslaufs (applicationId IS NULL)
  /// in die angegebene Bewerbung. Liefert die Anzahl kopierter Einträge.
  Future<int> copyMasterToApplication(int applicationId) {
    return transaction(() async {
      var copied = 0;
      final appId = Value<int?>(applicationId);

      for (final e in await getWorkExperiences(null)) {
        await into(cvWorkExperiences).insert(
          e.toCompanion(false).copyWith(id: const Value.absent(), applicationId: appId),
        );
        copied++;
      }
      for (final e in await getEducations(null)) {
        await into(cvEducations).insert(
          e.toCompanion(false).copyWith(id: const Value.absent(), applicationId: appId),
        );
        copied++;
      }
      for (final e in await getSkills(null)) {
        await into(cvSkills).insert(
          e.toCompanion(false).copyWith(id: const Value.absent(), applicationId: appId),
        );
        copied++;
      }
      for (final e in await getLanguages(null)) {
        await into(cvLanguages).insert(
          e.toCompanion(false).copyWith(id: const Value.absent(), applicationId: appId),
        );
        copied++;
      }
      for (final e in await getCustomItems(null)) {
        await into(cvCustomItems).insert(
          e.toCompanion(false).copyWith(id: const Value.absent(), applicationId: appId),
        );
        copied++;
      }
      return copied;
    });
  }
}
