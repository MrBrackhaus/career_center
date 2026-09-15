import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';
import '../../core/services/document_template_service.dart';

final documentTemplateServiceProvider = Provider<DocumentTemplateService>((
  ref,
) {
  return DocumentTemplateService(ref.read(settingsRepositoryProvider));
});
