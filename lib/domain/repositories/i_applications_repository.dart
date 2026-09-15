import '../entities/application_entity.dart';
import '../models/application_form_dto.dart';

abstract class IApplicationsRepository {
  Stream<List<ApplicationEntity>> watchAllApplications();
  Future<ApplicationEntity?> getApplicationById(int id);
  Future<int> addApplication(ApplicationFormDto application);
  Future<void> updateApplication(ApplicationFormDto application);
  Future<void> deleteApplication(ApplicationEntity application);
}
