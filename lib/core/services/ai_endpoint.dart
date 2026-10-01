/// Art der KI-Schnittstelle, die hinter einer konfigurierten Server-URL steckt.
enum AiApiType {
  /// OpenAI-kompatible Chat-Completions-API (OpenAI, OpenRouter, LM Studio, ...).
  openAiCompatible,

  /// Ollama-API (`/api/generate` bzw. `/api/chat`).
  ollama,
}

/// Welcher Ollama-Endpunkt verwendet werden soll.
enum OllamaEndpoint { generate, chat }

/// Ermittelt aus der vom Nutzer konfigurierten Server-URL den tatsächlichen
/// Endpunkt.
///
/// Die Entscheidung erfolgt ausschließlich anhand der URL – niemals anhand
/// des API-Keys. So werden Daten und Key nie an einen anderen Anbieter
/// geschickt als den, den der Nutzer konfiguriert hat.
class AiEndpoint {
  static const String defaultServerUrl = 'http://localhost:11434';

  final Uri uri;
  final AiApiType type;

  const AiEndpoint._(this.uri, this.type);

  bool get isOpenAiCompatible => type == AiApiType.openAiCompatible;

  /// Löst die konfigurierte URL auf.
  ///
  /// * Enthält der Pfad bereits `/chat/completions`, wird die URL unverändert
  ///   als OpenAI-kompatibler Endpunkt verwendet.
  /// * Enthält der Pfad ein `/v1`-Segment oder ist der Host `api.openai.com`,
  ///   wird `<Origin + Pfad bis einschließlich /v1>/chat/completions` gebildet
  ///   (ohne `/v1` zu verdoppeln).
  /// * Sonst wird Ollama angenommen: ein abschließendes `/api/generate`,
  ///   `/api/chat` oder `/api` wird entfernt und der passende Endpunkt
  ///   angehängt.
  static AiEndpoint resolve(
    String? configuredUrl, {
    OllamaEndpoint ollamaEndpoint = OllamaEndpoint.generate,
  }) {
    var raw = (configuredUrl ?? '').trim();
    if (raw.isEmpty) raw = defaultServerUrl;
    if (!raw.contains('://')) raw = 'http://$raw';

    final parsed = Uri.parse(raw);
    final segments =
        parsed.pathSegments.where((s) => s.isNotEmpty).toList(growable: true);
    final path = '/${segments.join('/')}';

    // 1. Vollständiger Chat-Completions-Endpunkt -> unverändert übernehmen.
    if (path.contains('/chat/completions')) {
      return AiEndpoint._(parsed, AiApiType.openAiCompatible);
    }

    // 2. OpenAI-kompatibel (Pfad enthält /v1 oder Host ist api.openai.com).
    final v1Index = segments.indexOf('v1');
    final isOpenAiHost = parsed.host.toLowerCase() == 'api.openai.com';
    if (v1Index >= 0 || isOpenAiHost) {
      final baseSegments =
          v1Index >= 0 ? segments.sublist(0, v1Index + 1) : <String>['v1'];
      final uri = parsed.replace(
        pathSegments: [...baseSegments, 'chat', 'completions'],
      );
      return AiEndpoint._(_stripFragment(uri), AiApiType.openAiCompatible);
    }

    // 3. Ollama.
    if (segments.length >= 2 &&
        segments[segments.length - 2] == 'api' &&
        (segments.last == 'generate' || segments.last == 'chat')) {
      segments.removeRange(segments.length - 2, segments.length);
    } else if (segments.isNotEmpty && segments.last == 'api') {
      segments.removeLast();
    }
    final endpoint =
        ollamaEndpoint == OllamaEndpoint.chat ? 'chat' : 'generate';
    final uri = parsed.replace(
      pathSegments: [...segments, 'api', endpoint],
    );
    return AiEndpoint._(_stripFragment(uri), AiApiType.ollama);
  }

  /// HTTP-Header für eine Anfrage an diesen Endpunkt.
  ///
  /// Der API-Key wird nur an OpenAI-kompatible Endpunkte gesendet.
  Map<String, String> headers(String apiKey) {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (isOpenAiCompatible && apiKey.isNotEmpty)
        'Authorization': 'Bearer $apiKey',
    };
  }

  static Uri _stripFragment(Uri uri) =>
      uri.hasFragment ? uri.removeFragment() : uri;

  @override
  String toString() => uri.toString();
}
