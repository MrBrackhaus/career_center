import 'dart:convert';
import 'dart:developer' show log;
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/enums/application_status.dart';
import '../../../presentation/providers/database_provider.dart';
import '../ai_endpoint.dart';
import '../secure_settings_service.dart';

class AiEmailExtractionResult {
  final bool isApplicationRelated;
  final String? companyName;
  final String? positionTitle;
  /// Bereits normalisierter Status (siehe [normalizeApplicationStatus]) oder
  /// null, wenn die KI keinen Status erkannt hat.
  final String? status;
  final String? rejectionReason;

  AiEmailExtractionResult({
    required this.isApplicationRelated,
    this.companyName,
    this.positionTitle,
    this.status,
    this.rejectionReason,
  });
}

class AiEmailExtractorService {
  final Ref ref;

  AiEmailExtractorService(this.ref);

  Future<AiEmailExtractionResult?> analyzeEmail(String subject, String body) async {
    final settings = ref.read(databaseProvider).settingsDao;
    
    // Prüfe ob KI aktiviert ist (cloudAiEnabled oder aiCvAssistantEnabled)
    final cloudAi = await settings.getSettingByKey('cloudAiEnabled');
    final cvAi = await settings.getSettingByKey('aiCvAssistantEnabled');
    final isAiEnabled = (cloudAi?.value == 'true') || (cvAi?.value == 'true');
    if (!isAiEnabled) return null;

    // Lade Server-URL und Modellname aus den korrekten Settings
    final urlSetting = await settings.getSettingByKey('aiServerUrl');
    // Endpunkt wird ausschließlich aus der konfigurierten URL abgeleitet.
    final endpoint = AiEndpoint.resolve(urlSetting?.value);
    
    final modelSetting = await settings.getSettingByKey('aiModelName');
    final modelName = (modelSetting != null && modelSetting.value.isNotEmpty) 
        ? modelSetting.value 
        : 'llama3.2';

    // Begrenze den Body auf sinnvolle Länge, um Kontextfenster nicht zu sprengen
    final truncatedBody = body.length > 3000 ? body.substring(0, 3000) : body;

    final prompt = '''
Du bist ein Datenextraktions-Bot für eine Bewerbungs-Tracking-App.
Deine einzige Aufgabe ist es, aus E-Mails die Kerninformationen zu extrahieren.
Antworte AUSSCHLIESSLICH mit gültigem JSON. Kein Begrüßungstext, keine Erklärungen.

REGELN:
1. "is_application_related": true, wenn es sich um eine Bewerbung, Eingangsbestätigung, Absage, Einladung zum Vorstellungsgespräch oder ein Jobangebot handelt. Sonst false.
2. "company_name": Der Name des Unternehmens. Wenn der Name nicht eindeutig im Text oder Betreff steht, MUSS der Wert "UNBEKANNT" sein. Wörter wie "Keine", "Unbekannt", "Firma", Städtenamen (z.B. "Viersen") oder "IT-Systemhaus" sind KEINE Firmennamen!
3. "position_title": Die Berufsbezeichnung (z.B. "Softwareentwickler"). Wenn nicht erkennbar, MUSS der Wert "UNBEKANNT" sein.
4. "status": Nur diese Werte sind erlaubt: "versendet", "absage", "interview", "angebot". Wenn unklar, "unbekannt".
5. "rejection_reason": Falls es eine Absage ist, der Grund (sonst "UNBEKANNT").

BEISPIEL 1:
Betreff: "Ihre Bewerbung als IT-Administrator bei der Meier GmbH"
Text: "Sehr geehrte(r) Bewerber(in), wir bestätigen den Eingang..."
Antwort:
{"is_application_related": true, "company_name": "Meier GmbH", "position_title": "IT-Administrator", "status": "versendet", "rejection_reason": "UNBEKANNT"}

BEISPIEL 2:
Betreff: "Re: Bewerbung Systemadministrator"
Text: "Leider müssen wir Ihnen mitteilen, dass wir uns für einen anderen Kandidaten entschieden haben, da uns die Erfahrung fehlt."
Antwort:
{"is_application_related": true, "company_name": "UNBEKANNT", "position_title": "Systemadministrator", "status": "absage", "rejection_reason": "Für einen anderen Kandidaten entschieden (fehlende Erfahrung)"}

BEISPIEL 3:
Betreff: "Newsletter der Woche"
Text: "Hier sind die Top-Nachrichten..."
Antwort:
{"is_application_related": false, "company_name": "UNBEKANNT", "position_title": "UNBEKANNT", "status": "unbekannt", "rejection_reason": "UNBEKANNT"}

JETZT ZUR AKTUELLEN E-MAIL:
Betreff: "$subject"
Text:
"$truncatedBody"
''';

    final jsonSchema = {
      "type": "object",
      "properties": {
        "is_application_related": {
          "type": "boolean",
          "description": "true, wenn es eine Bewerbung, Eingangsbestätigung, Absage oder Jobangebot ist."
        },
        "company_name": {
          "type": "string",
          "description": "Name des Unternehmens. Falls nicht im Text genannt, gib exakt das Wort 'UNBEKANNT' aus."
        },
        "position_title": {
          "type": "string",
          "description": "Berufsbezeichnung. Falls nicht genannt, gib 'UNBEKANNT' aus."
        },
        "status": {
          "type": "string",
          "enum": ["versendet", "absage", "interview", "angebot", "unbekannt"],
          "description": "Status der Bewerbung."
        },
        "rejection_reason": {
          "type": "string",
          "description": "Falls Absage, der Grund. Sonst 'UNBEKANNT'."
        }
      },
      "required": ["is_application_related", "company_name", "position_title", "status", "rejection_reason"]
    };

    try {
      final apiKey = await SecureSettingsService.getAiApiKey();
      final isOpenAI = endpoint.isOpenAiCompatible;

      http.Response response;

      if (isOpenAI) {
        response = await http.post(
          endpoint.uri,
          headers: endpoint.headers(apiKey),
          body: jsonEncode({
            'model': modelName.isEmpty ? 'gpt-4o-mini' : modelName,
            'messages': [
              {'role': 'system', 'content': 'Du antwortest ausschließlich in gültigem JSON.'},
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.1,
            'response_format': {'type': 'json_object'},
          }),
        ).timeout(const Duration(seconds: 30));
      } else {
        response = await http.post(
          endpoint.uri,
          headers: endpoint.headers(apiKey),
          body: jsonEncode({
            'model': modelName,
            'prompt': prompt,
            'stream': false,
            'format': jsonSchema,
          }),
        ).timeout(const Duration(seconds: 30));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        String responseText = '';
        
        if (isOpenAI) {
          responseText = data['choices'][0]['message']['content'] as String;
        } else {
          responseText = data['response'] as String;
        }
        
        // Strip markdown JSON blocks if the model hallucinates them
        responseText = responseText.trim();
        if (responseText.startsWith('```json')) {
          responseText = responseText.substring(7);
        } else if (responseText.startsWith('```')) {
          responseText = responseText.substring(3);
        }
        if (responseText.endsWith('```')) {
          responseText = responseText.substring(0, responseText.length - 3);
        }
        
        final parsed = jsonDecode(responseText);
        
        String? company = parsed['company_name']?.toString().trim();
        String? position = parsed['position_title']?.toString().trim();
        
        // Filter für kleine LLMs, die gerne Platzhalter halluzinieren
        final badWords = [
          'keine', 'unbekannt', 'firma', 'fehleranalyse', 'n/a', 'nicht', 'null'
        ];
        
        if (company != null && badWords.any((w) => company!.toLowerCase().contains(w))) company = null;
        if (position != null && badWords.any((w) => position!.toLowerCase().contains(w))) position = null;
        final rawStatus = parsed['status']?.toString().trim().toLowerCase();
        final status = (rawStatus == null || rawStatus.isEmpty || rawStatus == 'unbekannt')
            ? null
            : normalizeApplicationStatus(rawStatus);
        
        // Verhindere, dass der eigene Name (aus dem Profil) als Firmenname genommen wird
        final ownName = (await settings.getSettingByKey('userName'))?.value.trim().toLowerCase() ?? '';
        if (company != null && ownName.isNotEmpty && company.toLowerCase() == ownName) company = null;
        
        return AiEmailExtractionResult(
          isApplicationRelated: parsed['is_application_related'] == true,
          companyName: company,
          positionTitle: position,
          status: status,
          rejectionReason: parsed['rejection_reason']?.toString(),
        );
      }
    } catch (e) {
      log('AiEmailExtractorService error: $e', name: 'AiEmailExtractorService');
    }
    return null;
  }
}

final aiEmailExtractorProvider = Provider<AiEmailExtractorService>((ref) {
  return AiEmailExtractorService(ref);
});
