import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/applications_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/database/app_database.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final applicationsAsync = ref.watch(applicationsProvider);

    return Scaffold(
      body: applicationsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fehler: $err')),
        data: (apps) {
          final Map<DateTime, List<Application>> events = {};

          void addEvent(DateTime? date, Application app) {
            if (date == null) return;
            final key = DateTime(date.year, date.month, date.day);
            events.putIfAbsent(key, () => []).add(app);
          }

          for (final app in apps) {
            if (app.status == 'interview') addEvent(app.appliedDate, app);
            if (app.followupDate != null) addEvent(app.followupDate, app);
          }

          List<Application> getEventsForDay(DateTime day) =>
              events[DateTime(day.year, day.month, day.day)] ?? [];

          final selectedEvents = _selectedDay != null ? getEventsForDay(_selectedDay!) : <Application>[];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.calendarTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    _Legend(color: Colors.purple, label: AppLocalizations.of(context)!.formBasicInterview),
                    const SizedBox(width: 12),
                    _Legend(color: Colors.orange, label: AppLocalizations.of(context)!.calFollowUp),
                    const SizedBox(width: 12),
                    _Legend(color: Colors.red, label: AppLocalizations.of(context)!.calOverdue),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TableCalendar<Application>(
                firstDay: DateTime(2024),
                lastDay: DateTime(2027),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: getEventsForDay,
                calendarFormat: CalendarFormat.month,
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                calendarStyle: const CalendarStyle(markerSize: 7),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, appsOnDay) {
                    if (appsOnDay.isEmpty) return null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: appsOnDay.take(3).map((app) {
                        final now = DateTime.now();
                        Color color;
                        if (app.status == 'interview') {
                          color = Colors.purple;
                        } else if (app.followupDate != null && app.followupDate!.isBefore(now)) {
                          color = Colors.red;
                        } else {
                          color = Colors.orange;
                        }
                        return Container(
                          width: 7, height: 7,
                          margin: const EdgeInsets.only(bottom: 2, left: 1, right: 1),
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        );
                      }).toList(),
                    );
                  },
                ),
                onDaySelected: (selected, focused) {
                  setState(() { _selectedDay = selected; _focusedDay = focused; });
                },
                onPageChanged: (focused) => setState(() => _focusedDay = focused),
              ),
              const Divider(height: 1),
              if (selectedEvents.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedEvents.length,
                    itemBuilder: (ctx, i) {
                      final app = selectedEvents[i];
                      final isInterview = app.status == 'interview';
                      final isOverdue = app.followupDate != null && app.followupDate!.isBefore(DateTime.now());
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isInterview ? Colors.purple : (isOverdue ? Colors.red : Colors.orange),
                            child: Icon(isInterview ? Icons.handshake : Icons.notifications_active, color: Colors.white, size: 18),
                          ),
                          title: Text('${app.company} - ${app.position}'),
                          subtitle: Text(isInterview ? 'Interview-Termin' : (isOverdue ? 'Nachhaken - ueberfaellig!' : AppLocalizations.of(context)!.calFollowUp)),
                          onTap: () => context.push('/applications/edit/${app.id}'),
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
                        Icon(_selectedDay != null ? Icons.event_available : Icons.touch_app, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(_selectedDay != null ? AppLocalizations.of(context)!.calendarNoEvents : AppLocalizations.of(context)!.calClickDetails, style: const TextStyle(color: Colors.grey)),
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
    final loc = AppLocalizations.of(context)!;
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

