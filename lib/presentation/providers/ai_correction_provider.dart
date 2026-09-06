import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_correction_service.dart';

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

class AiCorrectionNotifier extends StateNotifier<AiCorrectionState> {
  final AiCorrectionService _service;

  AiCorrectionNotifier(this._service) : super(AiCorrectionState());

  Future<String?> correctText(String text, String language) async {
    state = state.copyWith(isCorrecting: true, clearError: true);
    try {
      final corrected = await _service.correctText(text, language);
      state = state.copyWith(isCorrecting: false);
      return corrected;
    } catch (e) {
      state = state.copyWith(isCorrecting: false, error: e.toString());
      return null;
    }
  }
}

final aiCorrectionProvider = StateNotifierProvider<AiCorrectionNotifier, AiCorrectionState>((ref) {
  final service = ref.watch(aiCorrectionServiceProvider);
  return AiCorrectionNotifier(service);
});
