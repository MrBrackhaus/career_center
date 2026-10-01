import 'package:flutter_test/flutter_test.dart';
import 'package:career_center/core/services/ai_endpoint.dart';

void main() {
  group('AiEndpoint.resolve', () {
    test('leer/null -> lokales Ollama /api/generate', () {
      final e = AiEndpoint.resolve(null);
      expect(e.type, AiApiType.ollama);
      expect(e.uri.toString(), 'http://localhost:11434/api/generate');
      expect(AiEndpoint.resolve('  ').uri.toString(),
          'http://localhost:11434/api/generate');
    });

    test('Ollama-URLs werden nicht verdoppelt', () {
      expect(AiEndpoint.resolve('http://localhost:11434').uri.toString(),
          'http://localhost:11434/api/generate');
      expect(AiEndpoint.resolve('http://localhost:11434/').uri.toString(),
          'http://localhost:11434/api/generate');
      expect(
          AiEndpoint.resolve('http://localhost:11434/api/generate')
              .uri
              .toString(),
          'http://localhost:11434/api/generate');
      expect(AiEndpoint.resolve('http://host:11434/api/chat').uri.toString(),
          'http://host:11434/api/generate');
      expect(AiEndpoint.resolve('http://host:11434/api').uri.toString(),
          'http://host:11434/api/generate');
      expect(AiEndpoint.resolve('localhost:11434').uri.toString(),
          'http://localhost:11434/api/generate');
    });

    test('Ollama chat-Endpunkt', () {
      expect(
          AiEndpoint.resolve('http://localhost:11434/api/generate',
                  ollamaEndpoint: OllamaEndpoint.chat)
              .uri
              .toString(),
          'http://localhost:11434/api/chat');
    });

    test('OpenAI ohne /v1 -> /v1/chat/completions', () {
      final e = AiEndpoint.resolve('https://api.openai.com');
      expect(e.type, AiApiType.openAiCompatible);
      expect(e.uri.toString(), 'https://api.openai.com/v1/chat/completions');
    });

    test('/v1 wird nicht verdoppelt', () {
      expect(AiEndpoint.resolve('https://api.openai.com/v1').uri.toString(),
          'https://api.openai.com/v1/chat/completions');
      expect(AiEndpoint.resolve('https://api.openai.com/v1/').uri.toString(),
          'https://api.openai.com/v1/chat/completions');
      expect(AiEndpoint.resolve('https://openrouter.ai/api/v1').uri.toString(),
          'https://openrouter.ai/api/v1/chat/completions');
      expect(AiEndpoint.resolve('http://localhost:1234/v1').uri.toString(),
          'http://localhost:1234/v1/chat/completions');
      expect(
          AiEndpoint.resolve('http://localhost:1234/v1/models').uri.toString(),
          'http://localhost:1234/v1/chat/completions');
    });

    test('vollständiger /chat/completions-Pfad bleibt unverändert', () {
      const url = 'https://example.com/openai/deployments/x/chat/completions';
      final e = AiEndpoint.resolve(url);
      expect(e.type, AiApiType.openAiCompatible);
      expect(e.uri.toString(), url);
    });

    test('Host wird nie anhand des Keys gewechselt', () {
      // Ein lokaler Server bleibt lokal – unabhängig vom Key-Format.
      final e = AiEndpoint.resolve('http://localhost:11434');
      expect(e.uri.host, 'localhost');
      expect(e.headers('sk-ant-123').containsKey('Authorization'), isFalse);
    });

    test('Authorization-Header nur für OpenAI-kompatible Endpunkte', () {
      final e = AiEndpoint.resolve('https://openrouter.ai/api/v1');
      expect(e.headers('sk-or-abc')['Authorization'], 'Bearer sk-or-abc');
      expect(e.headers('').containsKey('Authorization'), isFalse);
    });
  });
}
