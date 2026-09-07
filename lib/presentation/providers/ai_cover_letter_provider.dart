import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_cover_letter_service.dart';
import 'database_provider.dart';

final aiCoverLetterServiceProvider = Provider<AiCoverLetterService>((ref) {
  return AiCoverLetterService();
});

class AiCoverLetterState {
  final bool isLoading;
  final String? error;

  AiCoverLetterState({this.isLoading = false, this.error});

  AiCoverLetterState copyWith({bool? isLoading, String? error}) {
    return AiCoverLetterState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AiCoverLetterNotifier extends Notifier<AiCoverLetterState> {
  @override
  AiCoverLetterState build() {
    return AiCoverLetterState();
  }

  Future<String?> generateCoverLetter({
    required String userProfile,
    required String company,
    required String position,
    required String jobDescription,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dao = ref.read(databaseProvider).settingsDao;
      final aiUrlSetting = await dao.getSettingByKey('aiServerUrl');
      final aiModelSetting = await dao.getSettingByKey('aiModelName');
      
      final baseUrl = aiUrlSetting?.value ?? 'http://localhost:11434/api/generate';
      final modelName = aiModelSetting?.value ?? 'llama3.2';

      final service = ref.read(aiCoverLetterServiceProvider);
      final result = await service.generateCoverLetter(
        baseUrl: baseUrl,
        modelName: modelName,
        userProfile: userProfile,
        company: company,
        position: position,
        jobDescription: jobDescription,
      );

      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final aiCoverLetterProvider = NotifierProvider<AiCoverLetterNotifier, AiCoverLetterState>(AiCoverLetterNotifier.new);
