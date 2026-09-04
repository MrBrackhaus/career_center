/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
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

