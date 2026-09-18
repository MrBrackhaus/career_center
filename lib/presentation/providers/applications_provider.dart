import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/application_form_dto.dart';
import '../../domain/entities/application_entity.dart';
import 'database_provider.dart';

final applicationsProvider = StreamProvider.autoDispose<List<ApplicationEntity>>((ref) {
  final repository = ref.watch(applicationsRepositoryProvider);
  return repository.watchAllApplications();
});

final applicationByIdProvider = FutureProvider.autoDispose.family<ApplicationEntity?, int>((
  ref,
  id,
) async {
  final repository = ref.watch(applicationsRepositoryProvider);
  return await repository.getApplicationById(id);
});

class ApplicationNotifier {
  final Ref _ref;

  ApplicationNotifier(this._ref);

  Future<int> addApplication(ApplicationFormDto dto) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    return await repository.addApplication(dto);
  }

  Future<void> updateApplication(ApplicationFormDto dto) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    await repository.updateApplication(dto);
  }

  Future<void> updateApplicationStatus(int id, String status, {String? rejectionReason}) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    await repository.updateApplicationStatus(id, status, rejectionReason: rejectionReason);
  }

  Future<void> updateCoverLetterContent(int id, String content) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    await repository.updateCoverLetterContent(id, content);
  }

  Future<void> updateJobDescription(int id, String text) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    await repository.updateJobDescription(id, text);
  }

  Future<void> deleteApplication(ApplicationEntity app) async {
    final repository = _ref.read(applicationsRepositoryProvider);
    await repository.deleteApplication(app.id);
  }
}

final applicationNotifierProvider = Provider<ApplicationNotifier>((ref) {
  return ApplicationNotifier(ref);
});
