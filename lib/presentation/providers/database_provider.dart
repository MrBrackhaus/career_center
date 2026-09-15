import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/applications_repository.dart';
import '../../data/repositories/contacts_repository.dart';
import '../../data/repositories/documents_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/repositories/templates_repository.dart';
import '../../data/repositories/editor_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/emails_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ApplicationsRepository(db);
});

final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ContactsRepository(db);
});

final documentsRepositoryProvider = Provider<DocumentsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DocumentsRepository(db);
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NotesRepository(db);
});

final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TemplatesRepository(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SettingsRepository(db);
});

final emailsRepositoryProvider = Provider<EmailsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return EmailsRepository(db);
});

final editorRepositoryProvider = Provider<EditorRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return EditorRepository(db);
});
