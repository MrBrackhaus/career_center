import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../providers/database_provider.dart';

class KiWorkspaceChat extends ConsumerStatefulWidget {
  const KiWorkspaceChat({super.key});

  @override
  ConsumerState<KiWorkspaceChat> createState() => _KiWorkspaceChatState();
}

class _KiWorkspaceChatState extends ConsumerState<KiWorkspaceChat> {
  final List<Map<String, String>> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isLoading = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final dao = ref.read(databaseProvider).settingsDao;
      final aiUrlSetting = await dao.getSettingByKey('aiServerUrl');
      final aiModelSetting = await dao.getSettingByKey('aiModelName');

      String baseUrl =
          aiUrlSetting?.value ?? 'http://localhost:11434/api/generate';
      final modelName = aiModelSetting?.value ?? 'llama3.2';

      // We need to use /api/chat instead of /api/generate
      baseUrl = baseUrl.replaceAll('/api/generate', '/api/chat');
      if (!baseUrl.endsWith('/api/chat')) {
        baseUrl = baseUrl.endsWith('/')
            ? "${baseUrl}api/chat"
            : "$baseUrl/api/chat";
      }

      final uri = Uri.parse(baseUrl);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'model': modelName,
          'messages': _messages,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = jsonResponse['message'];
        if (msg != null && msg['content'] != null) {
          setState(() {
            _messages.add({'role': 'assistant', 'content': msg['content']});
          });
        }
      } else {
        setState(() {
          _messages.add({
            'role': 'system',
            'content': 'Fehler ${response.statusCode}: ${response.body}',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'role': 'system', 'content': 'Verbindungsfehler: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'KI-Workspace',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Chatte mit deinem lokalen LLM.\nStelle Fragen zu Bewerbungen, lass dir Texte formulieren oder bereite dich auf ein Interview vor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    final isSystem = msg['role'] == 'system';

                    return Align(
                      alignment: isSystem
                          ? Alignment.center
                          : (isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isSystem
                              ? colorScheme.errorContainer
                              : (isUser
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: SelectableText(
                          msg['content'] ?? '',
                          style: TextStyle(
                            color: isSystem
                                ? colorScheme.onErrorContainer
                                : (isUser
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Nachricht eingeben...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                onPressed: _isLoading ? null : _sendMessage,
                elevation: 0,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
