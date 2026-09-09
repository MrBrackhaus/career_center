import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import 'dart:convert';

import '../../data/database/app_database.dart';
import 'database_provider.dart';

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
      final db = ref.read(databaseProvider);
      final content = jsonEncode(deltaJson);
      final finalName = name.trim().isNotEmpty ? name.trim() : 'Neue Vorlage';

      if (existingId == null) {
        final newTemplate = TemplatesCompanion(
          name: drift.Value(finalName),
          type: drift.Value(type),
          content: drift.Value(content),
          createdAt: drift.Value(DateTime.now()),
        );
        await db.templatesDao.insertTemplate(newTemplate);
      } else {
        final template = TemplatesCompanion(
          id: drift.Value(existingId),
          name: drift.Value(finalName),
          type: drift.Value(type),
          content: drift.Value(content),
        );
        await db.templatesDao.updateTemplate(template);
      }
      state = state.copyWith(isSaving: false);
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  void analyzeText(String plainText, String jobDescription) {
    // TODO: Implement TF-IDF offline analysis here
  }
}

final templateEditorProvider =
    NotifierProvider<TemplateEditorNotifier, EditorState>(
      TemplateEditorNotifier.new,
    );
