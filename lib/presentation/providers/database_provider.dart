import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/applications_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ApplicationsRepository(db);
});

