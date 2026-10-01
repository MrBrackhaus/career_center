import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../domain/enums/application_status.dart';
import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';

/// Ergebnis von [datesForStatusChange]: welche Datumsfelder beim
/// Statuswechsel gesetzt werden sollen (null = unverändert lassen).
class StatusChangeDates {
  final DateTime? appliedDate;
  final DateTime? responseDate;

  const StatusChangeDates({this.appliedDate, this.responseDate});

  bool get isEmpty => appliedDate == null && responseDate == null;
}

/// Bestimmt, welche Datumsfelder bei einem Wechsel auf [newStatus]
/// automatisch gesetzt werden sollen. Bereits gesetzte Daten werden nie
/// überschrieben.
///
/// - `versendet`: Bewerbungsdatum, falls noch leer.
/// - `interview`, `zusage`, `absage`: Antwortdatum, falls noch leer.
StatusChangeDates datesForStatusChange(
  String newStatus, {
  DateTime? currentAppliedDate,
  DateTime? currentResponseDate,
  DateTime? now,
}) {
  final status = normalizeApplicationStatus(newStatus,
      fallback: ApplicationStatus.offen);
  final today = now ?? DateTime.now();
  DateTime? applied;
  DateTime? response;
  if (status == ApplicationStatus.versendet && currentAppliedDate == null) {
    applied = today;
  }
  if ((status == ApplicationStatus.interview ||
          status == ApplicationStatus.zusage ||
          status == ApplicationStatus.absage) &&
      currentResponseDate == null) {
    response = today;
  }
  return StatusChangeDates(appliedDate: applied, responseDate: response);
}

/// Setzt den Status einer Bewerbung per Teil-Update (keine anderen Felder
/// werden überschrieben) und ergänzt ggf. Bewerbungs-/Antwortdatum.
Future<void> changeApplicationStatus(
  WidgetRef ref, {
  required int id,
  required String newStatus,
  DateTime? currentAppliedDate,
  DateTime? currentResponseDate,
  String? rejectionReason,
}) async {
  final db = ref.read(databaseProvider);
  final notifier = ref.read(applicationNotifierProvider);
  await notifier.updateApplicationStatus(
    id,
    newStatus,
    rejectionReason: rejectionReason,
  );
  final dates = datesForStatusChange(
    newStatus,
    currentAppliedDate: currentAppliedDate,
    currentResponseDate: currentResponseDate,
  );
  if (!dates.isEmpty) {
    await db.applicationsDao.partialUpdate(
      id,
      ApplicationsCompanion(
        appliedDate: dates.appliedDate != null
            ? drift.Value(dates.appliedDate)
            : const drift.Value.absent(),
        responseDate: dates.responseDate != null
            ? drift.Value(dates.responseDate)
            : const drift.Value.absent(),
      ),
    );
  }
}

/// Setzt nur das Bewerbungsdatum (Teil-Update).
Future<void> setApplicationAppliedDate(
  WidgetRef ref,
  int id,
  DateTime date,
) async {
  final db = ref.read(databaseProvider);
  await db.applicationsDao.partialUpdate(
    id,
    ApplicationsCompanion(appliedDate: drift.Value(date)),
  );
}
