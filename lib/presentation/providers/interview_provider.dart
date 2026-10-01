import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/interview_message.dart';
import '../../data/repositories/interview_repository.dart';
import '../providers/database_provider.dart';

class InterviewState {
  final List<InterviewMessage> messages;
  final bool isRecruiterTyping;
  final String? currentStreamedChunk;

  InterviewState({
    this.messages = const [],
    this.isRecruiterTyping = false,
    this.currentStreamedChunk,
  });

  InterviewState copyWith({
    List<InterviewMessage>? messages,
    bool? isRecruiterTyping,
    String? currentStreamedChunk,
  }) {
    return InterviewState(
      messages: messages ?? this.messages,
      isRecruiterTyping: isRecruiterTyping ?? this.isRecruiterTyping,
      currentStreamedChunk: currentStreamedChunk,
    );
  }
}

/// Interview-Chat pro Bewerbung. Jede Bewerbung hat ihren eigenen Verlauf;
/// beim Verlassen des Bildschirms wird der Zustand verworfen.
final interviewProvider = NotifierProvider.autoDispose
    .family<InterviewNotifier, InterviewState, int>(
      (applicationId) => InterviewNotifier(applicationId),
    );

class InterviewNotifier extends Notifier<InterviewState> {
  final int applicationId;
  InterviewNotifier(this.applicationId);

  @override
  InterviewState build() => InterviewState();

  Future<void> addApplicantMessage(String text, {
    required String company,
    required String position,
    required String cvContent,
    required String coverLetterContent,
    required String jobDescription,
  }) async {
    if (text.trim().isEmpty) return;
    if (state.isRecruiterTyping) return;

    final newMessage = InterviewMessage(role: InterviewRole.applicant, content: text.trim());
    state = state.copyWith(
      messages: [...state.messages, newMessage],
      isRecruiterTyping: true,
      currentStreamedChunk: '',
    );

    String fullResponse = '';
    try {
      final repository = ref.read(interviewRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final urlSetting = await settingsRepo.getSettingByKey('aiServerUrl');
      if (!ref.mounted) return;
      final modelSetting = await settingsRepo.getSettingByKey('aiModelName');
      if (!ref.mounted) return;

      final baseUrl = urlSetting?.value ?? 'http://localhost:11434';
      final modelName = modelSetting?.value ?? 'llama3.1';

      final stream = repository.getNextRecruiterResponse(
        baseUrl: baseUrl,
        modelName: modelName,
        company: company,
        position: position,
        cvContent: cvContent,
        coverLetterContent: coverLetterContent,
        jobDescription: jobDescription,
        history: state.messages,
      );

      await for (final chunk in stream) {
        if (!ref.mounted) return;
        fullResponse += chunk;
        state = state.copyWith(currentStreamedChunk: fullResponse, isRecruiterTyping: true);
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        messages: [
          ...state.messages,
          InterviewMessage(
            role: InterviewRole.recruiter,
            content: '⚠️ Die KI konnte nicht antworten: $e',
          ),
        ],
        isRecruiterTyping: false,
        currentStreamedChunk: null,
      );
      return;
    }

    if (!ref.mounted) return;

    final recruiterMessage = InterviewMessage(role: InterviewRole.recruiter, content: fullResponse);
    state = state.copyWith(
      messages: [...state.messages, recruiterMessage],
      isRecruiterTyping: false,
      currentStreamedChunk: null, // intentionally null
    );
  }

  void startInterview({
    required String company,
    required String position,
    required String cvContent,
    required String coverLetterContent,
    required String jobDescription,
  }) {
    if (state.messages.isEmpty && !state.isRecruiterTyping) {
      addApplicantMessage('Hallo, ich bin zu meinem Vorstellungsgespräch hier.', 
        company: company, position: position, cvContent: cvContent, coverLetterContent: coverLetterContent, jobDescription: jobDescription);
    }
  }
}
