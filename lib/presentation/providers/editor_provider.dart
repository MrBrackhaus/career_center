import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
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

  /// Speichert eine Vorlage und liefert ihre ID zurück.
  ///
  /// Ist [existingId] null, wird eine neue Vorlage angelegt; der Aufrufer
  /// sollte die zurückgegebene ID bei späteren Speichervorgängen wieder
  /// übergeben, damit nicht bei jedem Autosave eine neue Vorlage entsteht.
  /// Fehler werden im State vermerkt und anschließend weitergeworfen.
  Future<int> saveTemplate({
    required int? existingId,
    required String name,
    required String type,
    required List<dynamic> deltaJson,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final repo = ref.read(editorRepositoryProvider);
      final content = jsonEncode(deltaJson);
      final finalName = name.trim().isNotEmpty ? name.trim() : 'Neue Vorlage';

      final id = await repo.saveTemplate(existingId, finalName, type, content);
      if (ref.mounted) state = state.copyWith(isSaving: false);
      return id;
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isSaving: false, errorMessage: e.toString());
      }
      rethrow;
    }
  }
}

// Bewusst nicht autoDispose: Der Editor liest den Notifier nur per
// `ref.read`; ein autoDispose-Provider würde während des `await` entsorgt.
final templateEditorProvider =
    NotifierProvider<TemplateEditorNotifier, EditorState>(
      TemplateEditorNotifier.new,
    );
