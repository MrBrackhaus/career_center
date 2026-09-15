import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'database_provider.dart';
import '../../domain/entities/template_entity.dart';

class EditorState {
  final bool isSaving;
  final String? errorMessage;

  final List<String> missingKeywords;
  final List<String> foundKeywords;

  const EditorState({
    this.isSaving = false,
    this.errorMessage,
    this.missingKeywords = const [],
    this.foundKeywords = const [],
  });

  EditorState copyWith({
    bool? isSaving,
    String? errorMessage,
    List<String>? missingKeywords,
    List<String>? foundKeywords,
  }) {
    return EditorState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      missingKeywords: missingKeywords ?? this.missingKeywords,
      foundKeywords: foundKeywords ?? this.foundKeywords,
    );
  }
}

class TemplateEditorNotifier extends Notifier<EditorState> {
  @override
  EditorState build() => const EditorState();

  Future<void> saveTemplate({
    required int? existingId,
    required String name,
    required String type,
    required List<dynamic> deltaJson,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final repo = ref.read(templatesRepositoryProvider);
      final content = jsonEncode(deltaJson);
      final finalName = name.trim().isNotEmpty ? name.trim() : 'Neue Vorlage';

      if (existingId == null) {
        await repo.addTemplate(
          finalName,
          type,
          content,
        );
      } else {
        final template = TemplateEntity(
          id: existingId,
          name: finalName,
          type: type,
          content: content,
          createdAt: DateTime.now(), // Will not update created_at anyway, it's just to satisfy entity
        );
        await repo.updateTemplate(template);
      }
      state = state.copyWith(isSaving: false);
    } on Exception catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  void analyzeText(String plainText, String jobDescription) {
    // TODO: Implement TF-IDF offline analysis here
  }
}

final templateEditorProvider =
    NotifierProvider.autoDispose<TemplateEditorNotifier, EditorState>(
      TemplateEditorNotifier.new,
    );
