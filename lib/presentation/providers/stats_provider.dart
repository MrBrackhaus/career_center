import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import 'applications_provider.dart';

class ApplicationStats {
  final int total;
  final int open;
  final int rejected;
  final int accepted;
  final int interview;

  ApplicationStats({
    required this.total,
    required this.open,
    required this.rejected,
    required this.accepted,
    required this.interview,
  });
}

final statsProvider = Provider<ApplicationStats>((ref) {
  final applications = ref.watch(applicationsProvider).value ?? [];
  
  int open = 0;
  int rejected = 0;
  int accepted = 0;
  int interview = 0;

  for (var app in applications) {
    switch (app.status.toLowerCase()) {
      case 'absage':
        rejected++;
        break;
      case 'zusage':
        accepted++;
        break;
      case 'interview':
        interview++;
        break;
      default:
        open++; // 'offen', 'versendet', 'in prüfung'
    }
  }

  return ApplicationStats(
    total: applications.length,
    open: open,
    rejected: rejected,
    accepted: accepted,
    interview: interview,
  );
});

