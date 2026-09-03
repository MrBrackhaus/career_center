import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/smtp_service.dart';

final smtpServiceProvider = Provider((ref) => SmtpService());
