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

final interviewProvider = NotifierProvider<InterviewNotifier, InterviewState>(InterviewNotifier.new);

class InterviewNotifier extends Notifier<InterviewState> {
  late final InterviewRepository _repository;
  bool _isDisposed = false;

  @override
  InterviewState build() {
    _repository = ref.watch(interviewRepositoryProvider);
    ref.onDispose(() {
      _isDisposed = true;
    });
    return InterviewState();
  }

  void addApplicantMessage(String text, {
    required String company,
    required String position,
    required String cvContent,
    required String coverLetterContent,
    required String jobDescription,
  }) async {
    if (text.trim().isEmpty) return;

    final newMessage = InterviewMessage(role: InterviewRole.applicant, content: text.trim());
    state = state.copyWith(
      messages: [...state.messages, newMessage],
      isRecruiterTyping: true,
      currentStreamedChunk: '',
    );

    final _settingsRepo = ref.read(settingsRepositoryProvider);
    final urlSetting = await _settingsRepo.getSettingByKey('aiServerUrl');
    final modelSetting = await _settingsRepo.getSettingByKey('aiModelName');
    
    final baseUrl = urlSetting?.value ?? 'http://localhost:11434';
    final modelName = modelSetting?.value ?? 'llama3.1';

    final stream = _repository.getNextRecruiterResponse(
      baseUrl: baseUrl,
      modelName: modelName,
      company: company,
      position: position,
      cvContent: cvContent,
      coverLetterContent: coverLetterContent,
      jobDescription: jobDescription,
      history: state.messages,
    );

    String fullResponse = '';

    await for (final chunk in stream) {
      if (_isDisposed) return;
      fullResponse += chunk;
      state = state.copyWith(currentStreamedChunk: fullResponse, isRecruiterTyping: true);
    }

    if (_isDisposed) return;
    
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
    if (state.messages.isEmpty) {
      addApplicantMessage('Hallo, ich bin zu meinem Vorstellungsgespräch hier.', 
        company: company, position: position, cvContent: cvContent, coverLetterContent: coverLetterContent, jobDescription: jobDescription);
    }
  }
}
