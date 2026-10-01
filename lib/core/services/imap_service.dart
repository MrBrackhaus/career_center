/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'extractors/ai_email_extractor_service.dart';
import 'dart:developer' show log;
import 'package:drift/drift.dart' as drift;

import '../../data/database/app_database.dart';
import '../../domain/enums/application_status.dart';
import 'extractors/email_response_extractor.dart';

// ── ScannableEmail model ──────────────────────────────────────────────────────

class ScannableEmail {
  final String uid;
  final String subject;
  final String fromTo;
  final DateTime date;
  final String bodySnippet;
  final String? detectedStatus;
  final bool isAlreadyImported;
  final String folder;
  final String company; // extracted, shown in list

  const ScannableEmail({
    required this.uid,
    required this.subject,
    required this.fromTo,
    required this.date,
    required this.bodySnippet,
    required this.detectedStatus,
    required this.isAlreadyImported,
    required this.folder,
    this.company = '',
  });
}

// ── ImapService ───────────────────────────────────────────────────────────────

class ImapService {
  static const _storage = FlutterSecureStorage();

  static Future<void> savePassword(String plainText) async {
    if (plainText.isEmpty) return;
    await _storage.write(key: 'imapPassword', value: plainText);
  }

  static Future<String> getPassword() async {
    return await _storage.read(key: 'imapPassword') ?? '';
  }

  // ── Parsing helpers (delegiert an EmailResponseExtractor) ──────────────────

  static final _companyPattern = RegExp(
    r'bei\s+(?:der\s+|dem\s+|Ihrem\s+Unternehmen\s+|Ihnen\s+als\s+)?([A-Za-zÄÖÜäöüß\s\-&.,]{1,40}(?:GmbH|AG|KG|SE|mbH|e\.V\.|GbR|OHG))',
  );

  static final _contactPattern = RegExp(
    r'Sehr\s+geehrte[r]?\s+(Frau|Herr)\s+([A-ZÄÖÜ][a-zäöüß]+(?:\s+[A-ZÄÖÜ][a-zäöüß]+){0,3})',
  );

  static final _positionPattern1 = RegExp(
    r'[Bb]ewerbung\s+als\s+(.+?)(?:\s*[-\u2013\u2014]|\s*\(m|$)',
    caseSensitive: false,
  );

  static final _positionPattern2 = RegExp(
    r'[Bb]ewerbung\s*[-\u2013\u2014]\s*(.+?)(?:\s*\(m|$)',
    caseSensitive: false,
  );

  static String _extractPosition(String subject) {
    final cleanSubject = EmailResponseExtractor.stripReplyPrefix(subject);
    final match = _positionPattern1.firstMatch(cleanSubject) ?? _positionPattern2.firstMatch(cleanSubject);
    if (match != null) {
      return match.group(1)?.trim() ?? cleanSubject.trim();
    }
    return cleanSubject.trim();
  }

  static String _extractCompanyFromBody(String body) {
    // Suche nach GmbH/AG in der Fußzeile (nimmt den letzten Treffer im Text). MUST BE case-sensitive for suffixes!
    final entityRegex = RegExp(
      r'([A-ZÄÖÜ][A-Za-zÄÖÜäöüß0-9\s\-&.]{2,50}(?:GmbH(?:\s*&\s*Co\.\s*KG)?|AG|KG|SE|mbH|e\.V\.|GbR|OHG))\b',
    );
    final matches = entityRegex.allMatches(body);
    if (matches.isNotEmpty) {
      final name = matches.last.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
      if (name.isNotEmpty && name.length < 60) return name;
    }

    // Fallback auf altes Muster
    final m = _companyPattern.firstMatch(body);
    if (m != null) {
      final name = m.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
      if (name.isNotEmpty && name.length < 60) return name;
    }
    return '';
  }

  static String _extractCompanyFromDomain(String recipientEmail) =>
      EmailResponseExtractor.extractCompanyFromDomain(recipientEmail);

  static String _extractContact(String body) {
    final m = _contactPattern.firstMatch(body);
    if (m != null) return '${m.group(1)} ${m.group(2)}'.trim();
    return '';
  }

  static String _stripReplyPrefix(String subject) =>
      EmailResponseExtractor.stripReplyPrefix(subject);

  static String? _detectApplicationStatus(String subject, String body) =>
      EmailResponseExtractor.detectStatus(subject, body);

  // ── IMAP connection ───────────────────────────────────────────────────────

  /// Verbindet sich mit dem IMAP-Server und meldet sich an.
  ///
  /// [useSsl] erzwingt (true) bzw. verbietet (false) implizites TLS. Ohne
  /// Angabe wird für Port 143 STARTTLS verwendet, sonst implizites TLS.
  /// Liefert null bei Fehlern; die Verbindung wird dann wieder geschlossen.
  Future<ImapClient?> connect(
    String server,
    int port,
    String email,
    String password, {
    bool? useSsl,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await _connectAndLogin(
        client,
        server,
        port,
        email,
        password,
        isSecure: useSsl,
      );
      return client;
    } catch (e) {
      log('IMAP-Verbindung fehlgeschlagen: $e', name: 'ImapService');
      try {
        await client.disconnect();
      } catch (_) {}
      return null;
    }
  }

  /// Port 143 ist der Klartext-Port: dort wird per STARTTLS auf TLS
  /// umgeschaltet, bevor das Passwort gesendet wird. Alle anderen Ports
  /// (typisch 993) verwenden implizites TLS.
  static Future<void> _connectAndLogin(
    ImapClient client,
    String host,
    int port,
    String userName,
    String password, {
    bool? isSecure,
  }) async {
    final secure = isSecure ?? port != 143;
    await client.connectToServer(host, port, isSecure: secure);
    if (!secure) {
      // Kein Fallback auf Klartext-Login: schlägt STARTTLS fehl, wird
      // abgebrochen, damit das Passwort nie unverschlüsselt übertragen wird.
      await client.startTls();
    }
    await client.login(userName, password);
  }

  static const _sentFolderNames = {
    'sent',
    'sent items',
    'sent mail',
    'sent messages',
    'gesendet',
    'gesendete objekte',
    'gesendete elemente',
    'gesendete nachrichten',
  };

  /// Findet den Gesendet-Ordner: zuerst über das IMAP-Flag `\Sent`, danach
  /// über bekannte Ordnernamen (exakter Vergleich des letzten Pfadsegments).
  static Mailbox? findSentMailbox(List<Mailbox> mailboxes) {
    for (final b in mailboxes) {
      if (b.isSent) return b;
    }
    for (final b in mailboxes) {
      final name = b.name.trim().toLowerCase();
      if (_sentFolderNames.contains(name)) return b;
      final path = b.path.trim().toLowerCase();
      final sep = b.pathSeparator.toLowerCase();
      if (sep.isNotEmpty &&
          _sentFolderNames.any((n) => path.endsWith('$sep$n'))) {
        return b;
      }
    }
    return null;
  }

  static String _messageId(MimeMessage msg) =>
      msg.decodeHeaderValue('Message-ID') ??
      (msg.uid?.toString() ??
          'fallback_${DateTime.now().microsecondsSinceEpoch}_${msg.hashCode}');

  static Map<int, RegExp> _buildCompanyRegexes(List<Application> apps) {
    final regexes = <int, RegExp>{};
    for (final app in apps) {
      final appCompany = app.company.toLowerCase();
      if (appCompany.isNotEmpty && appCompany.length > 2) {
        regexes[app.id] = RegExp(r'\b' + RegExp.escape(appCompany) + r'\b');
      }
    }
    return regexes;
  }

  // ── Auto-sync (background) ────────────────────────────────────────────────

  /// Returns the number of newly auto-imported applications
  Future<int> syncEmails(
    AppDatabase db,
    String host,
    int port,
    String userName,
    String password, {
    AiEmailExtractorService? aiExtractor,
    void Function(String)? onProgress,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    int newlyImported = 0;
    try {
      onProgress?.call('Verbinde mit $host...');
      await _connectAndLogin(client, host, port, userName, password);

      onProgress?.call('Lade Bewerbungen aus der Datenbank...');
      // Veränderbare Kopie: neu importierte Bewerbungen werden ergänzt, damit
      // eine zweite Mail an denselben Empfänger im selben Lauf kein Duplikat
      // erzeugt.
      final applications = List<Application>.of(
        await db.applicationsDao.getAllApplications(),
      );
      // Check if this is the first sync
      final lastSyncSetting = await db.settingsDao.getSettingByKey(
        'last_imap_sync',
      );
      final isFirstSync = lastSyncSetting == null;
      final fetchCount = isFirstSync ? 500 : 50;

      // Lese maximal 90 Tage in die Vergangenheit, um 5 Jahre alten Spam zu vermeiden
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));

      // ── 1. SENT FOLDER ──────────────────────────────────────────────────────────
      final mailboxes = await client.listMailboxes(recursive: true);
      final sentBox = findSentMailbox(mailboxes);

      if (sentBox != null) {
        await client.selectMailbox(sentBox);
        final fetchResult = await client.fetchRecentMessages(
          messageCount: fetchCount,
          criteria: 'BODY.PEEK[]',
        );
        final sentMessages = fetchResult.messages;
        
        onProgress?.call('Durchsuche Postausgang (${sentMessages.length} Mails)...');

        final companyRegexes = _buildCompanyRegexes(applications);

        for (final msg in sentMessages) {
          final sentDate = msg.decodeDate() ?? DateTime.now();
          if (sentDate.isBefore(cutoffDate)) continue;

          final rawToAddresses =
              msg.to?.map((e) => e.email.toLowerCase()).toList() ?? [];
          final toAddresses = rawToAddresses
              .where((e) => e != userName.toLowerCase())
              .toList();
          final subject = msg.decodeSubject() ?? '';
          final body = msg.decodeTextPlainPart() ?? '';
          final subjectLower = subject.toLowerCase();
          final bodyLower = body.toLowerCase();
          final msgId = _messageId(msg);

          // a) Update existing "offen" → "versendet"
          for (var i = 0; i < applications.length; i++) {
            final app = applications[i];
            if (app.status == ApplicationStatus.offen) {
              final appEmail = app.contactEmail?.toLowerCase() ?? '';
              final appCompany = app.company.toLowerCase();
              bool matched = false;

              if (appEmail.isNotEmpty && toAddresses.contains(appEmail)) {
                matched = true;
              } else if (appCompany.isNotEmpty && appCompany.length > 2) {
                final companyRegex = companyRegexes[app.id];
                if (companyRegex != null) {
                  if (companyRegex.hasMatch(subjectLower)) {
                    matched = true;
                  } else if (appCompany.length > 4 && companyRegex.hasMatch(bodyLower)) {
                    matched = true;
                  }
                }
              }
              if (matched) {
                final updated = app.copyWith(
                  status: ApplicationStatus.versendet,
                  appliedDate: drift.Value(sentDate),
                );
                await db.applicationsDao.updateApplication(updated);
                applications[i] = updated;
                final existingEmail = await db.emailsDao.getEmailByMessageId(
                  msgId,
                );
                if (existingEmail == null) {
                  await db.emailsDao.insertEmail(
                    EmailsCompanion.insert(
                      applicationId: app.id,
                      messageId: msgId,
                      subject: subject.isNotEmpty ? subject : 'Kein Betreff',
                      sender: toAddresses.isNotEmpty
                          ? 'An: ${toAddresses.first}'
                          : 'Gesendet',
                      bodySnippet: body,
                      receivedAt: sentDate,
                      isRead: drift.Value(true),
                    ),
                  );
                }
              }
            }
          }

          // Bereits gespeicherte Mails (früherer Lauf oder Schritt a) nicht
          // erneut importieren.
          if (await db.emailsDao.getEmailByMessageId(msgId) != null) continue;

          // b) Auto-import new applications
          if (aiExtractor != null) {
            final isRelevant = subjectLower.contains('bewerbung') || bodyLower.contains('bewerbung') || subjectLower.contains('application');
            if (isRelevant) {
              onProgress?.call('KI analysiert gesendete Mail...');
              final aiResult = await aiExtractor.analyzeEmail(subject, body);
              if (aiResult != null && aiResult.isApplicationRelated) {
                final recipientEmail = toAddresses.isNotEmpty ? toAddresses.first : '';
                String finalCompany = (aiResult.companyName != null && aiResult.companyName!.isNotEmpty)
                    ? aiResult.companyName!
                    : _extractCompanyFromDomain(recipientEmail);
                if (finalCompany.isEmpty) finalCompany = 'Unbekannte Firma';

                final finalPosition = (aiResult.positionTitle != null && aiResult.positionTitle!.isNotEmpty) 
                    ? aiResult.positionTitle! 
                    : 'Unbekannte Position';

                final alreadyExists = applications.any((app) {
                  return app.company.toLowerCase() == finalCompany.toLowerCase();
                });
                if (!alreadyExists) {
                  final appId = await db.applicationsDao.insertApplication(
                    ApplicationsCompanion.insert(
                      company: finalCompany,
                      position: finalPosition,
                      status: drift.Value(normalizeApplicationStatus(aiResult.status)),
                      appliedDate: drift.Value(sentDate),
                      contactEmail: drift.Value(recipientEmail),
                      createdAt: drift.Value(DateTime.now()),
                      updatedAt: drift.Value(DateTime.now()),
                    ),
                  );

                  await db.emailsDao.insertEmail(
                    EmailsCompanion.insert(
                      applicationId: appId,
                      messageId: msgId,
                      subject: subject.isNotEmpty ? subject : 'Kein Betreff',
                      sender: recipientEmail.isNotEmpty ? 'An: $recipientEmail' : 'Gesendet',
                      bodySnippet: body.trim(),
                      receivedAt: sentDate,
                      isRead: drift.Value(true),
                    ),
                  );
                  await _rememberApplication(db, appId, applications);
                  newlyImported++;
                  continue; // Skip the regex fallback
                }
              }
            }
          }

          // Fallback zu Regex (ohne KI)
          final detectedStatus = _detectApplicationStatus(subject, body);
          if (detectedStatus == null) continue;

          final cleanSubject = _stripReplyPrefix(subject);
          final recipientEmail = toAddresses.isNotEmpty
              ? toAddresses.first
              : '';
          if (recipientEmail.isNotEmpty) {
            final emailAlreadyLinked = applications.any(
              (app) => app.contactEmail?.toLowerCase() == recipientEmail,
            );
            if (emailAlreadyLinked) continue;
          }

          final position = _extractPosition(cleanSubject);
          final alreadyExists = applications.any((app) {
            final samePos =
                app.position.toLowerCase() == position.toLowerCase();
            final sameDate =
                app.appliedDate != null &&
                sentDate.difference(app.appliedDate!).abs().inHours < 12;
            return samePos && sameDate;
          });
          if (alreadyExists) continue;

          String company = _extractCompanyFromBody(body);
          if (company.isEmpty && recipientEmail.isNotEmpty) {
            company = _extractCompanyFromDomain(recipientEmail);
          }
          if (company.isEmpty) company = 'Unbekannte Firma';

          final contactName = _extractContact(body);

          final appId = await db.applicationsDao.insertApplication(
            ApplicationsCompanion.insert(
              company: company,
              position: position,
              status: drift.Value(normalizeApplicationStatus(detectedStatus)),
              appliedDate: drift.Value(sentDate),
              contactName: drift.Value(
                contactName.isNotEmpty ? contactName : null,
              ),
              contactEmail: drift.Value(
                recipientEmail.isNotEmpty ? recipientEmail : null,
              ),
              notes: drift.Value(
                'Automatisch importiert am ${sentDate.day}.${sentDate.month}.${sentDate.year}',
              ),
              createdAt: drift.Value(DateTime.now()),
              updatedAt: drift.Value(DateTime.now()),
            ),
          );

          await db.emailsDao.insertEmail(
            EmailsCompanion.insert(
              applicationId: appId,
              messageId: msgId,
              subject: subject.isNotEmpty ? subject : 'Kein Betreff',
              sender: recipientEmail.isNotEmpty
                  ? 'An: $recipientEmail'
                  : 'Gesendet',
              bodySnippet: body,
              receivedAt: sentDate,
              isRead: drift.Value(true),
            ),
          );
          await _rememberApplication(db, appId, applications);

          newlyImported++;
        }
      }

      // ── 2. INBOX ──────────────────────────────────────────────────────────
      final updatedApps = List<Application>.of(
        await db.applicationsDao.getAllApplications(),
      );
      await client.selectInbox();
      final inboxResult = await client.fetchRecentMessages(
        messageCount: fetchCount,
        criteria: 'BODY.PEEK[]',
      );
      
      onProgress?.call('Durchsuche Posteingang (${inboxResult.messages.length} Mails)...');

      final companyRegexes = _buildCompanyRegexes(updatedApps);

      for (final msg in inboxResult.messages) {
        final rDate = msg.decodeDate() ?? DateTime.now();
        if (rDate.isBefore(cutoffDate)) continue;

        final fromAddress = msg.from?.firstOrNull?.email.toLowerCase() ?? '';
        final subjectRaw = msg.decodeSubject() ?? '';
        final bodyRaw = msg.decodeTextPlainPart() ?? '';
        // Kleingeschriebene Kopien nur für das Matching.
        final subject = subjectRaw.toLowerCase();
        final body = bodyRaw.toLowerCase();
        final msgId = _messageId(msg);

        final existing = await db.emailsDao.getEmailByMessageId(msgId);
        if (existing != null) continue;

        bool foundMatch = false;
        for (final app in updatedApps) {
          final appEmail = app.contactEmail?.toLowerCase() ?? '';
          final appCompany = app.company.toLowerCase();
          bool matched = false;

          if (appEmail.isNotEmpty && fromAddress.contains(appEmail)) {
            matched = true;
          } else if (appCompany.isNotEmpty && appCompany.length > 2) {
            final companyNoSpaces = appCompany.replaceAll(' ', '');
            if (fromAddress.contains(companyNoSpaces)) {
              matched = true;
            } else {
              // Word boundary check to prevent "it" matching "mit"
              final companyRegex = companyRegexes[app.id];
              if (companyRegex != null) {
                // Suche Firmenname im Betreff (immer sicher)
                if (companyRegex.hasMatch(subject)) {
                  matched = true;
                } 
                // Suche im Body NUR, wenn der Firmenname etwas länger/spezifischer ist (verhindert 'IT' Spam-Matches)
                else if (appCompany.length > 4 && companyRegex.hasMatch(body)) {
                  matched = true;
                }
              }
            }
          }

          if (matched) {
            foundMatch = true;
            await db.emailsDao.insertEmail(
              EmailsCompanion.insert(
                applicationId: app.id,
                messageId: msgId,
                subject: subjectRaw.isNotEmpty ? subjectRaw : 'Kein Betreff',
                sender: msg.from?.firstOrNull?.toString() ?? 'Unbekannt',
                bodySnippet: bodyRaw,
                receivedAt: rDate,
              ),
            );

            String newStatus = app.status;
            final extracted = EmailResponseExtractor.detectStatus(
              subjectRaw,
              bodyRaw,
            );

            if (extracted == 'absage' || extracted == 'interview') {
              newStatus = extracted!;
            } else if (extracted == 'bestaetigung' &&
                app.status == ApplicationStatus.offen) {
              newStatus = ApplicationStatus.versendet;
            }
            newStatus = normalizeApplicationStatus(newStatus);

            if (newStatus != app.status) {
              await db.applicationsDao.updateApplication(
                app.copyWith(
                  status: newStatus,
                  responseDate: drift.Value(msg.decodeDate()),
                  rejectionReason: newStatus == ApplicationStatus.absage
                      ? drift.Value('Automatisch aus E-Mail erkannt')
                      : const drift.Value.absent(),
                ),
              );
            }
            break;
          }
        }
        // Eingangs-Mails: Nur BESTÄTIGUNGSMAILS importieren (Portal-Bewerbungen),
        // KEIN Recruiter-Spam oder Job-Alerts.
        if (!foundMatch && aiExtractor != null) {
          final combined = '$subject $body';
          final isConfirmation = 
              combined.contains('bewerbung eingegangen') ||
              combined.contains('bewerbung erhalten') ||
              combined.contains('eingangsbestätigung') ||
              combined.contains('bewerbungseingang') ||
              combined.contains('haben wir erhalten') ||
              combined.contains('ist bei uns eingegangen') ||
              combined.contains('bestätigen den eingang') ||
              combined.contains('bestätigen den erhalt') ||
              combined.contains('dank für ihre bewerbung') ||
              combined.contains('dank für deine bewerbung') ||
              combined.contains('danke für deine bewerbung') ||
              combined.contains('erfolgreich an') ||
              combined.contains('übermittlung') ||
              combined.contains('we have received your application') ||
              combined.contains('ihre bewerbung') ||
              combined.contains('bewerbung als') ||
              combined.contains('bewerbung auf');
          
          if (isConfirmation) {
            onProgress?.call('KI analysiert Bestätigungsmail...');
            final aiResult = await aiExtractor.analyzeEmail(
              subjectRaw,
              bodyRaw,
            );
            if (aiResult != null && aiResult.isApplicationRelated) {
              String finalCompany = (aiResult.companyName != null && aiResult.companyName!.isNotEmpty)
                  ? aiResult.companyName!
                  : _extractCompanyFromDomain(msg.from?.firstOrNull?.email ?? '');
              if (finalCompany.isEmpty) finalCompany = 'Unbekannte Firma';

              final finalPosition = (aiResult.positionTitle != null && aiResult.positionTitle!.isNotEmpty) 
                  ? aiResult.positionTitle! 
                  : 'Unbekannte Position';
              
              // Prüfe ob nicht schon vorhanden
              final alreadyExists = updatedApps.any((app) =>
                app.company.toLowerCase() == finalCompany.toLowerCase());
              
              if (!alreadyExists) {
                final newAppId = await db.applicationsDao.insertApplication(
                  ApplicationsCompanion.insert(
                    company: finalCompany,
                    position: finalPosition,
                    status: drift.Value(normalizeApplicationStatus(aiResult.status)),
                    appliedDate: drift.Value(rDate),
                    contactEmail: drift.Value(msg.from?.firstOrNull?.email ?? ''),
                    createdAt: drift.Value(DateTime.now()),
                    updatedAt: drift.Value(DateTime.now()),
                  ),
                );
                await db.emailsDao.insertEmail(
                  EmailsCompanion.insert(
                    applicationId: newAppId,
                    messageId: msgId,
                    subject: subjectRaw.isNotEmpty ? subjectRaw : 'Kein Betreff',
                    sender: msg.from?.firstOrNull?.toString() ?? 'Unbekannt',
                    bodySnippet: bodyRaw.trim(),
                    receivedAt: rDate,
                  ),
                );
                await _rememberApplication(db, newAppId, updatedApps);
                newlyImported++;
              }
            }
          }
        }
      }

      await db.settingsDao.insertOrUpdateSetting(
        Setting(key: 'last_imap_sync', value: DateTime.now().toIso8601String()),
      );
    } catch (e) {
      log('IMAP Sync Error: $e', name: 'ImapService');
    } finally {
      await client.disconnect();
    }
    return newlyImported;
  }

  // ── Manual scanner (fetch only, no import) ────────────────────────────────

  Future<List<ScannableEmail>> fetchEmailsForScanner(
    AppDatabase db,
    String server,
    int port,
    String email,
    String password,
  ) async {
    final client = await connect(server, port, email, password);
    if (client == null) {
      throw Exception(
        'Verbindung zum IMAP-Server fehlgeschlagen. Bitte Zugangsdaten prüfen.',
      );
    }

    final result = <ScannableEmail>[];
    final existingApps = await db.applicationsDao.getAllApplications();
    final existingEmails = await db.emailsDao.getAllEmails();
    final existingContactEmails = existingApps
        .map((a) => a.contactEmail?.toLowerCase())
        .whereType<String>()
        .toSet();

    try {
      // ── Sent folder ──────────────────────────────────────────────────────
      final mailboxes = await client.listMailboxes(recursive: true);
      final sentBox = findSentMailbox(mailboxes);

      if (sentBox != null) {
        await client.selectMailbox(sentBox);
        final sentFetch = await client.fetchRecentMessages(
          messageCount: 50,
          criteria: 'BODY.PEEK[]',
        );

        for (final msg in sentFetch.messages) {
          final rawTo =
              msg.to?.map((e) => e.email.toLowerCase()).toList() ?? [];
          final toAddresses = rawTo
              .where((e) => e != email.toLowerCase())
              .toList();
          final subject = msg.decodeSubject() ?? '';
          final body = msg.decodeTextPlainPart() ?? '';
          final date = msg.decodeDate() ?? DateTime.now();
          final uid = _messageId(msg);
          final recipientEmail = toAddresses.isNotEmpty
              ? toAddresses.first
              : '';

          final detectedStatus = _detectApplicationStatus(subject, body);

          // Try to resolve company name
          String company = _extractCompanyFromBody(body);
          if (company.isEmpty && recipientEmail.isNotEmpty) {
            company = _extractCompanyFromDomain(recipientEmail);
          }

          final alreadyImported =
              existingContactEmails.contains(recipientEmail) ||
              existingEmails.any((e) => e.messageId == uid);
          final cleanSubject = _stripReplyPrefix(subject);

          result.add(
            ScannableEmail(
              uid: uid,
              subject: cleanSubject.isNotEmpty ? cleanSubject : subject,
              fromTo: recipientEmail.isNotEmpty
                  ? 'An: $recipientEmail'
                  : 'Gesendet',
              date: date,
              bodySnippet: body,
              detectedStatus: detectedStatus,
              isAlreadyImported: alreadyImported,
              folder: 'sent',
              company: company,
            ),
          );
        }
      }

      // ── Inbox ────────────────────────────────────────────────────────────
      await client.selectInbox();
      final inboxFetch = await client.fetchRecentMessages(
        messageCount: 50,
        criteria: 'BODY.PEEK[]',
      );

      for (final msg in inboxFetch.messages) {
        final from = msg.from?.firstOrNull?.email.toLowerCase() ?? '';
        final subject = msg.decodeSubject() ?? '';
        final body = msg.decodeTextPlainPart() ?? '';
        final date = msg.decodeDate() ?? DateTime.now();
        final uid = _messageId(msg);

        final detectedStatus = _detectApplicationStatus(subject, body);

        String company = _extractCompanyFromDomain(from);
        if (company.isEmpty) company = _extractCompanyFromBody(body);

        final alreadyImported = existingEmails.any((e) => e.messageId == uid);
        final cleanSubject = _stripReplyPrefix(subject);

        result.add(
          ScannableEmail(
            uid: uid,
            subject: cleanSubject.isNotEmpty ? cleanSubject : subject,
            fromTo: 'Von: $from',
            date: date,
            bodySnippet: body,
            detectedStatus: detectedStatus,
            isAlreadyImported: alreadyImported,
            folder: 'inbox',
            company: company,
          ),
        );
      }
    } finally {
      await client.disconnect();
    }

    // Sort strictly by date descending
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  // ── Import selected emails (from scanner) ────────────────────────────────

  Future<int> importSelectedEmails(
    AppDatabase db,
    List<ScannableEmail> emails,
  ) async {
    final applications = List<Application>.of(
      await db.applicationsDao.getAllApplications(),
    );
    int count = 0;
    for (final scanMail in emails) {
      final status = normalizeApplicationStatus(scanMail.detectedStatus);

      if (await db.emailsDao.getEmailByMessageId(scanMail.uid) != null) {
        continue;
      }

      final recipientEmail = scanMail.folder == 'sent'
          ? (scanMail.fromTo.startsWith('An: ')
                ? scanMail.fromTo.substring(4)
                : '')
          : '';

      final alreadyExists =
          recipientEmail.isNotEmpty &&
          applications.any(
            (app) => app.contactEmail?.toLowerCase() == recipientEmail,
          );
      if (alreadyExists) continue;

      String company = _extractCompanyFromBody(scanMail.bodySnippet);
      if (company.isEmpty && recipientEmail.isNotEmpty) {
        company = _extractCompanyFromDomain(recipientEmail);
      }
      if (company.isEmpty) company = 'Unbekannte Firma';

      final contact = _extractContact(scanMail.bodySnippet);

      final appId = await db.applicationsDao.insertApplication(
        ApplicationsCompanion.insert(
          company: company,
          position: _extractPosition(scanMail.subject),
          status: drift.Value(status),
          appliedDate: drift.Value(scanMail.date),
          contactName: drift.Value(contact.isNotEmpty ? contact : null),
          contactEmail: drift.Value(
            recipientEmail.isNotEmpty ? recipientEmail : null,
          ),
          notes: drift.Value('Manuell importiert per E-Mail-Scanner.'),
          createdAt: drift.Value(DateTime.now()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );

      await db.emailsDao.insertEmail(
        EmailsCompanion.insert(
          applicationId: appId,
          messageId: scanMail.uid,
          subject: scanMail.subject,
          sender: scanMail.fromTo,
          bodySnippet: scanMail.bodySnippet,
          receivedAt: scanMail.date,
          isRead: drift.Value(true),
        ),
      );
      await _rememberApplication(db, appId, applications);
      count++;
    }
    return count;
  }

  /// Lädt eine frisch eingefügte Bewerbung und ergänzt sie in [apps], damit
  /// spätere Duplikat-Prüfungen im selben Lauf sie berücksichtigen.
  static Future<void> _rememberApplication(
    AppDatabase db,
    int id,
    List<Application> apps,
  ) async {
    final inserted = await db.applicationsDao.getApplicationById(id);
    if (inserted != null) apps.add(inserted);
  }
}