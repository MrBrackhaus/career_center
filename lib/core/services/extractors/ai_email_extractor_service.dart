import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/providers/database_provider.dart';

class AiEmailExtractionResult {
  final bool isApplicationRelated;
  final String? companyName;
  final String? positionTitle;
  final String? status; // 'versendet', 'absage', 'interview', 'angebot', etc.
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
    String baseUrl = 'http://localhost:11434';
    if (urlSetting != null && urlSetting.value.isNotEmpty) {
      baseUrl = urlSetting.value;
      // Entferne /api/generate falls es schon dran hängt, wir fügen es selbst hinzu
      baseUrl = baseUrl.replaceAll('/api/generate', '').replaceAll(RegExp(r'/+$'), '');
    }
    
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
      final apiKeySetting = await settings.getSettingByKey('aiApiKey');
      final apiKey = apiKeySetting?.value ?? '';
      
      final isOpenAI = baseUrl.contains('openai.com') || apiKey.startsWith('sk-');
      
      http.Response response;
      
      if (isOpenAI) {
        final openAiUrl = baseUrl.contains('openai.com') 
            ? '$baseUrl/v1/chat/completions'
            : 'https://api.openai.com/v1/chat/completions';
            
        response = await http.post(
          Uri.parse(openAiUrl),
          headers: {
            'Content-Type': 'application/json',
            if (apiKey.isNotEmpty) 'Authorization': 'Bearer $apiKey',
          },
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
          Uri.parse('$baseUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
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
        if (parsed['status'] == 'unbekannt') parsed['status'] = null;
        
        // Verhindere, dass der eigene Name als Firmenname genommen wird
        final contactNameLower = (parsed['contact_name']?.toString() ?? '').toLowerCase();
        if (company != null && company.toLowerCase() == 'michael kurz') company = null;
        
        return AiEmailExtractionResult(
          isApplicationRelated: parsed['is_application_related'] == true,
          companyName: company,
          positionTitle: position,
          status: parsed['status']?.toString().toLowerCase(),
          rejectionReason: parsed['rejection_reason']?.toString(),
        );
      }
    } catch (e) {
      print('AiEmailExtractorService error: $e');
    }
    return null;
  }
}

final aiEmailExtractorProvider = Provider<AiEmailExtractorService>((ref) {
  return AiEmailExtractorService(ref);
});
