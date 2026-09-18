enum InterviewRole { recruiter, applicant }

class InterviewMessage {
  final InterviewRole role;
  final String content;

  InterviewMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role == InterviewRole.recruiter ? 'assistant' : 'user',
      'content': content,
    };
  }
}
