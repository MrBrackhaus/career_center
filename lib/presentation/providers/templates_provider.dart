import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/template_entity.dart';
import 'database_provider.dart';

final templatesProvider = StreamProvider.autoDispose.family<List<TemplateEntity>, String?>((ref, type) {
  final repo = ref.watch(templatesRepositoryProvider);
  if (type != null) {
    return repo.watchTemplatesByType(type);
  } else {
    return repo.watchAllTemplates();
  }
});

class TemplatesNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addTemplate(String name, String type, String content, {String? filePath}) async {
    final repo = ref.read(templatesRepositoryProvider);
    await repo.addTemplate(name, type, content, filePath: filePath);
  }

  Future<void> updateTemplate(TemplateEntity template) async {
    final repo = ref.read(templatesRepositoryProvider);
    await repo.updateTemplate(template);
  }

  Future<void> deleteTemplate(int id) async {
    final repo = ref.read(templatesRepositoryProvider);
    await repo.deleteTemplate(id);
  }
}

final templatesNotifierProvider = NotifierProvider.autoDispose<TemplatesNotifier, AsyncValue<void>>(
  () => TemplatesNotifier(),
);
