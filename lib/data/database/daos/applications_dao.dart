import 'package:drift/drift.dart';
import '../app_database.dart';

part 'applications_dao.g.dart';

@DriftAccessor(tables: [Applications])
class ApplicationsDao extends DatabaseAccessor<AppDatabase> with _$ApplicationsDaoMixin {
  ApplicationsDao(AppDatabase db) : super(db);

  Future<List<Application>> getAllApplications() => select(applications).get();
  
  Stream<List<Application>> watchAllApplications() => select(applications).watch();

  Future<Application> getApplicationById(int id) {
    return (select(applications)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<int> insertApplication(Insertable<Application> application) {
    return into(applications).insert(application);
  }

  Future<bool> updateApplication(Insertable<Application> application) {
    return update(applications).replace(application);
  }

  Future<int> deleteApplication(Application application) {
    return delete(applications).delete(application);
  }
}

