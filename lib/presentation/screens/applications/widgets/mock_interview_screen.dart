import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:career_center/domain/entities/application_entity.dart';
import '../../../providers/interview_provider.dart';
import '../../../../domain/entities/interview_message.dart';

class MockInterviewScreen extends ConsumerStatefulWidget {
  final ApplicationEntity application;

  const MockInterviewScreen({super.key, required this.application});

  @override
  ConsumerState<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start interview on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interviewProvider.notifier).startInterview(
        company: widget.application.company,
        position: widget.application.position,
        cvContent: widget.application.cvContent ?? '',
        coverLetterContent: widget.application.coverLetterContent ?? '',
        jobDescription: widget.application.jobDescriptionText ?? '',
      );
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200, // Extra for safety
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    
    _controller.clear();
    ref.read(interviewProvider.notifier).addApplicantMessage(
      text,
      company: widget.application.company,
      position: widget.application.position,
      cvContent: widget.application.cvContent ?? '',
        coverLetterContent: widget.application.coverLetterContent ?? '',
      jobDescription: widget.application.jobDescriptionText ?? '',
    );
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interviewProvider);

    // Scroll to bottom when streaming updates
    if (state.isRecruiterTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Interview: ${widget.application.company}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length + (state.isRecruiterTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.messages.length && state.isRecruiterTyping) {
                  return _buildChatBubble(
                    role: InterviewRole.recruiter,
                    content: state.currentStreamedChunk ?? '...',
                    isTyping: true,
                  );
                }
                
                final msg = state.messages[index];
                // Hide the initial hidden trigger message if we want, but since we used "Hallo..." it's fine to show it.
                return _buildChatBubble(
                  role: msg.role,
                  content: msg.content,
                  isTyping: false,
                );
              },
            ),
          ),
          _buildInputArea(state.isRecruiterTyping),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required InterviewRole role, required String content, required bool isTyping}) {
    final isApplicant = role == InterviewRole.applicant;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isApplicant ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isApplicant ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomLeft: isApplicant ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isApplicant ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApplicant ? 'Du' : 'Recruiter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isApplicant ? colorScheme.onPrimary.withValues(alpha: 0.7) : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              content,
              style: TextStyle(
                color: isApplicant ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isTyping) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isTyping,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: isTyping ? 'Recruiter tippt...' : 'Antworte auf die Frage...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: isTyping ? null : _sendMessage,
            mini: true,
            child: isTyping 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
