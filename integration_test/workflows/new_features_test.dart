import 'package:career_center/data/database/app_database.dart';
import 'package:career_center/data/repositories/interview_repository.dart';
import 'package:career_center/domain/entities/interview_message.dart';
import 'package:career_center/presentation/screens/applications/widgets/application_card.dart';
import 'package:career_center/presentation/screens/applications/widgets/mock_interview_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/test_app.dart';

/// Offline stand-in for the LLM: answers deterministically and records the
/// conversation history it received.
class FakeInterviewRepository extends InterviewRepository {
  final calls = <List<InterviewMessage>>[];

  @override
  Stream<String> getNextRecruiterResponse({
    required String baseUrl,
    required String modelName,
    required String company,
    required String position,
    required String cvContent,
    required String coverLetterContent,
    required String jobDescription,
    required List<InterviewMessage> history,
  }) async* {
    calls.add(List.of(history));
    yield 'Willkommen bei $company! ';
    yield 'Antwort ${calls.length}.';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selecting an application opens the dossier with follow-up '
      'date, .ics export and mock interview', (tester) async {
    final followup = DateTime(2030, 3, 4, 14, 30);
    await pumpTestApp(tester, seed: (db) async {
      await db.into(db.applications).insert(ApplicationsCompanion.insert(
            company: 'Testcorp Inc.',
            position: 'Senior Flutter Dev',
            notes: const Value('Remote möglich'),
            followupDate: Value(followup),
          ));
      await db.into(db.applications).insert(ApplicationsCompanion.insert(
          company: 'Ohne Termin AG', position: 'Dev'));
    });

    await tapVisible(
      tester,
      find.descendant(
          of: find.byType(ApplicationCard),
          matching: find.text('Testcorp Inc.')),
    );

    expect(find.text('Remote möglich'), findsOneWidget);
    expect(find.text('04.03.2030 14:30'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '.ics Export'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Mock-Interview starten'),
        findsOneWidget);

    // Without a follow-up date there is no .ics export.
    await tapVisible(
      tester,
      find.descendant(
          of: find.byType(ApplicationCard),
          matching: find.text('Ohne Termin AG')),
    );
    expect(find.widgetWithText(OutlinedButton, '.ics Export'), findsNothing);
    expect(find.text('Keine Stellenbeschreibung oder Notizen hinterlegt.'),
        findsOneWidget);
  });

  testWidgets('mock interview: greeting is sent automatically, user messages '
      'and AI answers appear in order', (tester) async {
    final fakeAi = FakeInterviewRepository();
    await pumpTestApp(
      tester,
      overrides: [interviewRepositoryProvider.overrideWithValue(fakeAi)],
      seed: (db) async {
        await db.into(db.applications).insert(ApplicationsCompanion.insert(
            company: 'Testcorp Inc.', position: 'Senior Flutter Dev'));
      },
    );

    await tapVisible(
      tester,
      find.descendant(
          of: find.byType(ApplicationCard),
          matching: find.text('Testcorp Inc.')),
    );
    await tapVisible(
        tester, find.widgetWithText(ElevatedButton, 'Mock-Interview starten'));
    expect(find.byType(MockInterviewScreen), findsOneWidget);
    expect(find.text('Interview: Testcorp Inc.'), findsOneWidget);

    // Auto greeting + first AI answer.
    await pumpUntilFound(tester, find.text('Willkommen bei Testcorp Inc.! Antwort 1.'));
    expect(find.text('Hallo, ich bin zu meinem Vorstellungsgespräch hier.'),
        findsOneWidget);

    final input = find.descendant(
        of: find.byType(MockInterviewScreen), matching: find.byType(TextField));
    await tester.enterText(input, 'Guten Tag, danke für die Einladung!');
    await tapVisible(tester, find.byIcon(Icons.send));

    await pumpUntilFound(tester, find.text('Willkommen bei Testcorp Inc.! Antwort 2.'));
    expect(find.text('Guten Tag, danke für die Einladung!'), findsOneWidget);
    // Input is cleared after sending.
    expect(tester.widget<TextField>(input).controller!.text, isEmpty);

    // The AI received the full history (greeting, answer 1, new message).
    expect(fakeAi.calls, hasLength(2));
    expect(fakeAi.calls.last.map((m) => m.content).toList(), [
      'Hallo, ich bin zu meinem Vorstellungsgespräch hier.',
      'Willkommen bei Testcorp Inc.! Antwort 1.',
      'Guten Tag, danke für die Einladung!',
    ]);
  });
}
