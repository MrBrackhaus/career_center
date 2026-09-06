import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_correction_service.dart';
import '../../presentation/providers/database_provider.dart';

final aiCorrectionServiceProvider = Provider<AiCorrectionService>((ref) {
  return AiCorrectionService();
});

class AiCorrectionState {
  final bool isCorrecting;
  final String? error;

  AiCorrectionState({this.isCorrecting = false, this.error});

  AiCorrectionState copyWith({bool? isCorrecting, String? error, bool clearError = false}) {
    return AiCorrectionState(
      isCorrecting: isCorrecting ?? this.isCorrecting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AiCorrectionNotifier extends Notifier<AiCorrectionState> {
  @override
  AiCorrectionState build() {
    return AiCorrectionState();
  }

  Future<String?> correctText(String text, String language) async {
    final service = ref.read(aiCorrectionServiceProvider);
    state = state.copyWith(isCorrecting: true, clearError: true);
    try {
      final db = ref.read(databaseProvider);
      final urlSetting = await db.settingsDao.getSettingByKey('aiServerUrl');
      final modelSetting = await db.settingsDao.getSettingByKey('aiModelName');
      final baseUrl = urlSetting?.value ?? 'http://localhost:11434/api/generate';
      final modelName = modelSetting?.value ?? 'llama3.2';
      
      final corrected = await service.correctText(text, language, baseUrl, modelName);
      state = state.copyWith(isCorrecting: false);
      return corrected;
    } catch (e) {
      state = state.copyWith(isCorrecting: false, error: e.toString());
      return null;
    }
  }
}

final aiCorrectionProvider = NotifierProvider<AiCorrectionNotifier, AiCorrectionState>(AiCorrectionNotifier.new);
