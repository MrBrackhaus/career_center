import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';

class AiSettings {
  final bool isCvAssistantEnabled;
  final bool isCloudAiEnabled;
  final String url;
  final String model;

  AiSettings({
    required this.isCvAssistantEnabled,
    required this.isCloudAiEnabled,
    required this.url,
    required this.model,
  });

  bool get isAiEnabled {
    return isCvAssistantEnabled || isCloudAiEnabled;
  }
}

final aiSettingsProvider = FutureProvider<AiSettings>((ref) async {
  final dao = ref.watch(settingsRepositoryProvider);
  final cvSetting = await dao.getSettingByKey('aiCvAssistantEnabled');
  final cloudSetting = await dao.getSettingByKey('cloudAiEnabled');
  final urlSetting = await dao.getSettingByKey('aiServerUrl');
  final modelSetting = await dao.getSettingByKey('aiModelName');

  return AiSettings(
    isCvAssistantEnabled: cvSetting?.value == 'true',
    isCloudAiEnabled: cloudSetting?.value == 'true',
    url: urlSetting?.value ?? '',
    model: modelSetting?.value ?? '',
  );
});
