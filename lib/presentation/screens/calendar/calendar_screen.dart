/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:table_calendar/table_calendar.dart';

import '../../providers/applications_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../domain/entities/application_entity.dart';
import '../../../core/utils/ics_exporter.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

/// Art eines Kalendereintrags.
enum _CalEventKind {
  /// Bewerbung im Status "interview", angezeigt am Bewerbungsdatum.
  /// Es gibt kein eigenes Feld für den Interview-Termin.
  interviewApplication,

  /// Nachfass-Erinnerung (followupDate).
  followUp,
}

class _CalEvent {
  final ApplicationEntity app;
  final _CalEventKind kind;
  const _CalEvent(this.app, this.kind);

  bool get isInterview => kind == _CalEventKind.interviewApplication;

  /// Überfällig, wenn das Erinnerungsdatum vor dem heutigen Tag liegt.
  bool isOverdue(DateTime startOfToday) =>
      kind == _CalEventKind.followUp &&
      app.followupDate != null &&
      DateTime(app.followupDate!.year, app.followupDate!.month,
              app.followupDate!.day)
          .isBefore(startOfToday);
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  // Dynamische Grenzen statt fester Jahreszahlen (z.B. DateTime(2027)),
  // damit der Kalender nicht an einem Jahreswechsel bricht.
  static final DateTime _firstDay = DateTime(2000, 1, 1);
  static final DateTime _lastDay = DateTime(DateTime.now().year + 10, 12, 31);

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  DateTime _clampDay(DateTime day) {
    if (day.isBefore(_firstDay)) return _firstDay;
    if (day.isAfter(_lastDay)) return _lastDay;
    return day;
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationsProvider);

    return Scaffold(
      body: applicationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fehler: $err')),
        data: (apps) {
          final Map<DateTime, List<_CalEvent>> events = {};
          final Set<String> seen = {};
          final now = DateTime.now();
          final startOfToday = DateTime(now.year, now.month, now.day);

          void addEvent(DateTime? date, ApplicationEntity app, _CalEventKind kind) {
            if (date == null) return;
            final key = DateTime(date.year, date.month, date.day);
            // Pro Tag, Bewerbung und Art nur einen Eintrag anzeigen.
            final dedupeKey = '${key.toIso8601String()}|${app.id}|${kind.name}';
            if (!seen.add(dedupeKey)) return;
            events.putIfAbsent(key, () => []).add(_CalEvent(app, kind));
          }

          for (final app in apps) {
            if (app.status == 'interview') {
              addEvent(app.appliedDate, app, _CalEventKind.interviewApplication);
            }
            if (app.followupDate != null) {
              addEvent(app.followupDate, app, _CalEventKind.followUp);
            }
          }

          List<_CalEvent> getEventsForDay(DateTime day) =>
              events[DateTime(day.year, day.month, day.day)] ?? const [];

          final selectedEvents = _selectedDay != null
              ? getEventsForDay(_selectedDay!)
              : const <_CalEvent>[];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.calendarTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const _Legend(
                      color: Colors.purple,
                      label: 'Bewerbung (Interview-Status)',
                    ),
                    _Legend(
                      color: Colors.orange,
                      label: AppLocalizations.of(context)!.calFollowUp,
                    ),
                    _Legend(
                      color: Colors.red,
                      label: AppLocalizations.of(context)!.calOverdue,
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final success = await IcsExporter.exportAll(apps);
                        if (success && context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Kalender exportiert!'))
                           );
                        }
                      },
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('.ics Alle'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TableCalendar<_CalEvent>(
                // Sprache der App und Wochenbeginn Montag (ISO/DIN). Für
                // Sprachen ohne Datumsformat-Daten (z.B. Klingonisch) Deutsch.
                locale: _calendarLocale(context),
                startingDayOfWeek: StartingDayOfWeek.monday,
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _clampDay(_focusedDay),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: getEventsForDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarStyle: const CalendarStyle(markerSize: 7),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, eventsOnDay) {
                    if (eventsOnDay.isEmpty) return null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: eventsOnDay.take(3).map((event) {
                        Color color;
                        if (event.isInterview) {
                          color = Colors.purple;
                        } else if (event.isOverdue(startOfToday)) {
                          color = Colors.red;
                        } else {
                          color = Colors.orange;
                        }
                        return Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(
                            bottom: 2,
                            left: 1,
                            right: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = _clampDay(focused);
                  });
                },
                onPageChanged: (focused) =>
                    setState(() => _focusedDay = _clampDay(focused)),
              ),
              const Divider(height: 1),
              if (selectedEvents.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedEvents.length,
                    itemBuilder: (ctx, i) {
                      final event = selectedEvents[i];
                      final app = event.app;
                      final isInterview = event.isInterview;
                      final isOverdue = event.isOverdue(startOfToday);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isInterview
                                ? Colors.purple
                                : (isOverdue ? Colors.red : Colors.orange),
                            child: Icon(
                              isInterview
                                  ? Icons.handshake
                                  : Icons.notifications_active,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          title: Text('${app.company} - ${app.position}'),
                          subtitle: Text(
                            isInterview
                                ? 'Bewerbung (Interview-Status)'
                                : (isOverdue
                                      ? 'Nachhaken – überfällig!'
                                      : AppLocalizations.of(context)!
                                            .calFollowUp),
                          ),
                          onTap: () =>
                              context.push('/applications/edit/${app.id}'),
                        ),
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedDay != null
                              ? Icons.event_available
                              : Icons.touch_app,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedDay != null
                              ? AppLocalizations.of(context)!.calendarNoEvents
                              : AppLocalizations.of(context)!.calClickDetails,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/applications/add');
        },
        icon: const Icon(Icons.add),
        label: const Text('Bewerbung'),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

String _calendarLocale(BuildContext context) {
  final tag = Localizations.localeOf(context).toLanguageTag().replaceAll('-', '_');
  final lang = Localizations.localeOf(context).languageCode;
  if (DateFormat.localeExists(tag)) return tag;
  if (DateFormat.localeExists(lang)) return lang;
  return 'de';
}
