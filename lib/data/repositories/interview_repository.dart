import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_interview_service.dart';
import '../../domain/entities/interview_message.dart';

final interviewRepositoryProvider = Provider((ref) => InterviewRepository());

class InterviewRepository {
  final _service = AiInterviewService();

  Stream<String> getNextRecruiterResponse({
    required String baseUrl,
    required String modelName,
    required String company,
    required String position,
    required String cvContent,
    required String coverLetterContent,
    required String jobDescription,
    required List<InterviewMessage> history,
  }) {
    return _service.generateResponseStream(
      baseUrl: baseUrl,
      modelName: modelName,
      company: company,
      position: position,
      cvContent: cvContent,
      coverLetterContent: coverLetterContent,
      jobDescription: jobDescription,
      history: history,
    );
  }
}
