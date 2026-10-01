/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'dart:developer' show log;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/application_status.dart';
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
  final appsAsync = ref.watch(applicationsProvider);
  if (appsAsync.hasError) {
    log('Error in statsProvider: ${appsAsync.error}', error: appsAsync.error, stackTrace: appsAsync.stackTrace);
  }
  final applications = appsAsync.value ?? [];

  int open = 0;
  int rejected = 0;
  int accepted = 0;
  int interview = 0;

  for (var app in applications) {
    switch (normalizeApplicationStatus(app.status, fallback: ApplicationStatus.offen)) {
      case ApplicationStatus.absage:
        rejected++;
        break;
      case ApplicationStatus.zusage:
        accepted++;
        break;
      case ApplicationStatus.interview:
        interview++;
        break;
      default:
        open++; // 'offen', 'versendet' und unbekannte Werte
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
