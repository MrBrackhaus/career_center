import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/interview_message.dart';

class AiInterviewService {
  Stream<String> generateResponseStream({
    required String baseUrl,
    required String modelName,
    required String company,
    required String position,
    required String cvContent,
    required String coverLetterContent,
    required String jobDescription,
    required List<InterviewMessage> history,
  }) async* {
    final systemPrompt = '''Du bist ein strenger, aber fairer Personalvermittler (Recruiter) der Firma "$company".
Du führst gerade ein Bewerbungsgespräch mit einem Kandidaten für die Position "$position".

Hier ist die Stellenbeschreibung (Job Description), auf die sich der Kandidat bewirbt:
$jobDescription

Hier ist das Anschreiben des Kandidaten:


Hier ist der Lebenslauf (CV) des Kandidaten:
$cvContent

REGELN:
1. Spiele deine Rolle durchgehend! Du bist der Recruiter.
2. Stelle immer nur EINE kurze, präzise Frage auf einmal und warte auf die Antwort.
3. Beginne das Gespräch professionell.
4. Nutze dein umfassendes Hintergrundwissen über die Firma "$company", deren Unternehmenskultur, Branche und aktuelle Herausforderungen, um realistische und tiefgreifende fachliche Fragen zu stellen.
5. Sei kritisch bei Lücken im Lebenslauf oder fehlenden Anforderungen in Bezug auf die Stellenbeschreibung.
6. Antworte auf Deutsch.''';

    // Ollama /api/chat endpoint
    String url = baseUrl;
    if (url.endsWith('/api/generate')) {
      url = url.replaceAll('/api/generate', '/api/chat');
    } else if (!url.endsWith('/api/chat')) {
      url = url.endsWith('/') ? '${url}api/chat' : '$url/api/chat';
    }

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => m.toJson()),
    ];

    final request = http.Request('POST', Uri.parse(url));
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode({
      'model': modelName,
      'messages': messages,
      'stream': true,
    });

    final client = http.Client();
    try {
      final response = await client.send(request);
      if (response.statusCode != 200) {
        yield 'Fehler: Server antwortete mit Statuscode ${response.statusCode}';
        return;
      }

      await for (final chunk in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.isEmpty) continue;
        try {
          final json = jsonDecode(chunk);
          if (json.containsKey('message') && json['message']['content'] != null) {
            yield json['message']['content'];
          }
        } catch (_) {}
      }
    } catch (e) {
      yield 'Fehler bei der Verbindung zum KI-Server: $e';
    } finally {
      client.close();
    }
  }
}
