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
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/app_database.dart';
import 'extractors/email_response_extractor.dart';
import 'document_intelligence_service.dart';
import '../../domain/models/extraction_result.dart';

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

  static String _extractPosition(String subject) {
    final cleanSubject = EmailResponseExtractor.stripReplyPrefix(subject);
    final patterns = [
      RegExp(r'[Bb]ewerbung\s+als\s+(.+?)(?:\s*[-\u2013\u2014]|\s*\(m|$)', caseSensitive: false),
      RegExp(r'[Bb]ewerbung\s*[-\u2013\u2014]\s*(.+?)(?:\s*\(m|$)', caseSensitive: false),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(cleanSubject);
      if (m != null) {
        final pos = m.group(1)?.trim() ?? '';
        if (pos.isNotEmpty) return pos;
      }
    }
    return cleanSubject.trim();
  }

  static String _extractCompanyFromBody(String body) {
    final companyPatterns = [
      RegExp(
        r'bei\s+(?:der\s+|dem\s+|Ihrem\s+Unternehmen\s+|Ihnen\s+als\s+)?'
        r'([\w\s\-\&.,\u00c4\u00d6\u00dc\u00e4\u00f6\u00fc\u00df]+?(?:GmbH(?:\s*\&\s*Co\.\s*KG)?|AG|KG|SE|mbH|e\.V\.|GbR|OHG))',
        caseSensitive: false,
      ),
    ];
    for (final p in companyPatterns) {
      final m = p.firstMatch(body);
      if (m != null) {
        final name = m.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
        if (name.isNotEmpty && name.length < 60) return name;
      }
    }
    return '';
  }

  static String _extractCompanyFromDomain(String recipientEmail) =>
      EmailResponseExtractor.extractCompanyFromDomain(recipientEmail);

  static String _extractContact(String body) {
    final p = RegExp(
      r'Sehr\s+geehrte[r]?\s+(Frau|Herr)\s+([A-Z\u00c4\u00d6\u00dc][a-z\u00e4\u00f6\u00fc\u00df]+(?:\s+[A-Z\u00c4\u00d6\u00dc][a-z\u00e4\u00f6\u00fc\u00df]+)*)',
    );
    final m = p.firstMatch(body);
    if (m != null) return '${m.group(1)} ${m.group(2)}'.trim();
    return '';
  }

  static String _stripReplyPrefix(String subject) =>
      EmailResponseExtractor.stripReplyPrefix(subject);

  static bool _isReply(String subject) =>
      EmailResponseExtractor.isReply(subject);

  static String? _detectApplicationStatus(String subject, String body) =>
      EmailResponseExtractor.detectStatus(subject, body);

  // ── IMAP connection ───────────────────────────────────────────────────────

  Future<ImapClient?> connect(String server, int port, String email, String password, {bool useSsl = true}) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await client.connectToServer(server, port, isSecure: useSsl);
      await client.login(email, password);
      return client;
    } catch (e) {
      return null;
    }
  }

  // ── Auto-sync (background) ────────────────────────────────────────────────

  /// Returns the number of newly auto-imported applications
  Future<int> syncEmails(AppDatabase db, String server, int port, String email, String password) async {
    final client = await connect(server, port, email, password);
    if (client == null) return 0;

    int newlyImported = 0;

    try {
      final applications = await db.applicationsDao.getAllApplications();

      // ── 1. SENT FOLDER ────────────────────────────────────────────────────
      final mailboxes = await client.listMailboxes(recursive: true);
      Mailbox? sentBox;
      try {
        sentBox = mailboxes.firstWhere(
          (b) => b.isSent || b.name.toLowerCase().contains('sent') || b.name.toLowerCase().contains('gesendet') || b.name.toLowerCase().contains('postausgang') || b.name.toLowerCase().contains('outbox')
        );
      } catch (_) {}

      if (sentBox != null) {
        await client.selectMailbox(sentBox);
        final fetchResult = await client.fetchRecentMessages(messageCount: 200, criteria: 'BODY.PEEK[]');
        final sentMessages = fetchResult.messages;

        for (final msg in sentMessages) {
          final rawToAddresses = msg.to?.map((e) => e.email.toLowerCase()).toList() ?? [];
          final toAddresses = rawToAddresses.where((e) => e != email.toLowerCase()).toList();
          final subject = msg.decodeSubject() ?? '';
          final body = msg.decodeTextPlainPart() ?? '';
          final sentDate = msg.decodeDate() ?? DateTime.now();
          final subjectLower = subject.toLowerCase();
          final bodyLower = body.toLowerCase();

          // a) Update existing "offen" → "versendet"
          for (final app in applications) {
            if (app.status == 'offen') {
              final appEmail = app.contactEmail?.toLowerCase() ?? '';
              final appCompany = app.company.toLowerCase();
              bool matched = false;
              
              if (appEmail.isNotEmpty && toAddresses.contains(appEmail)) {
                matched = true;
              } else if (appCompany.isNotEmpty && appCompany.length > 2) {
                final companyRegex = RegExp(r'\b' + RegExp.escape(appCompany) + r'\b');
                if (companyRegex.hasMatch(subjectLower) || companyRegex.hasMatch(bodyLower)) {
                  matched = true;
                }
              }
              if (matched) {
                await db.applicationsDao.updateApplication(app.copyWith(
                  status: 'versendet',
                  appliedDate: drift.Value(sentDate),
                ));
                final msgId = msg.decodeHeaderValue('Message-ID') ?? msg.uid.toString();
                final existingEmail = await db.emailsDao.getEmailByMessageId(msgId);
                if (existingEmail == null) {
                  await db.emailsDao.insertEmail(EmailsCompanion.insert(
                    applicationId: app.id,
                    messageId: msgId,
                    subject: subject.isNotEmpty ? subject : 'Kein Betreff',
                    sender: toAddresses.isNotEmpty ? 'An: ${toAddresses.first}' : 'Gesendet',
                    bodySnippet: body.length > 200 ? '${body.substring(0, 200)}...' : body,
                    receivedAt: sentDate,
                    isRead: drift.Value(true),
                  ));
                }
              }
            }
          }

          // b) Auto-import new applications
          final detectedStatus = _detectApplicationStatus(subject, body);
          if (detectedStatus == null) continue;

          final cleanSubject = _stripReplyPrefix(subject);
          final recipientEmail = toAddresses.isNotEmpty ? toAddresses.first : '';
          if (recipientEmail.isNotEmpty) {
            final emailAlreadyLinked = applications.any(
              (app) => app.contactEmail?.toLowerCase() == recipientEmail,
            );
            if (emailAlreadyLinked) continue;
          }

          final position = _extractPosition(cleanSubject);
          final alreadyExists = applications.any((app) {
            final samePos = app.position.toLowerCase() == position.toLowerCase();
            final sameDate = app.appliedDate != null &&
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

          final appId = await db.applicationsDao.insertApplication(ApplicationsCompanion.insert(
            company: company,
            position: position,
            status: drift.Value(detectedStatus),
            appliedDate: drift.Value(sentDate),
            contactName: drift.Value(contactName.isNotEmpty ? contactName : null),
            contactEmail: drift.Value(recipientEmail.isNotEmpty ? recipientEmail : null),
            notes: drift.Value('Automatisch importiert am ${sentDate.day}.${sentDate.month}.${sentDate.year}'),
            createdAt: drift.Value(DateTime.now()),
            updatedAt: drift.Value(DateTime.now()),
          ));

          await db.emailsDao.insertEmail(EmailsCompanion.insert(
            applicationId: appId,
            messageId: msg.decodeHeaderValue('Message-ID') ?? msg.uid.toString(),
            subject: subject.isNotEmpty ? subject : 'Kein Betreff',
            sender: recipientEmail.isNotEmpty ? 'An: $recipientEmail' : 'Gesendet',
            bodySnippet: body.length > 200 ? '${body.substring(0, 200)}...' : body,
            receivedAt: sentDate,
            isRead: drift.Value(true),
          ));

          newlyImported++;
        }
      }

      // ── 2. INBOX ──────────────────────────────────────────────────────────
      final updatedApps = await db.applicationsDao.getAllApplications();
      await client.selectInbox();
      final inboxResult = await client.fetchRecentMessages(messageCount: 50, criteria: 'BODY.PEEK[]');

      for (final msg in inboxResult.messages) {
        final fromAddress = msg.from?.first.email.toLowerCase() ?? '';
        final subject = msg.decodeSubject()?.toLowerCase() ?? '';
        final body = msg.decodeTextPlainPart()?.toLowerCase() ?? '';
        final msgId = msg.decodeHeaderValue('Message-ID') ?? msg.uid.toString();

        final existing = await db.emailsDao.getEmailByMessageId(msgId);
        if (existing != null) continue;

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
              final companyRegex = RegExp(r'\b' + RegExp.escape(appCompany) + r'\b');
              if (companyRegex.hasMatch(subject) || companyRegex.hasMatch(body)) {
                matched = true;
              }
            }
          }

          if (matched) {
            await db.emailsDao.insertEmail(EmailsCompanion.insert(
              applicationId: app.id,
              messageId: msgId,
              subject: msg.decodeSubject() ?? 'Kein Betreff',
              sender: msg.from?.first.toString() ?? 'Unbekannt',
              bodySnippet: body.length > 200 ? '${body.substring(0, 200)}...' : body,
              receivedAt: msg.decodeDate() ?? DateTime.now(),
            ));

            String newStatus = app.status;
            final extracted = EmailResponseExtractor.detectStatus(msg.decodeSubject() ?? '', msg.decodeTextPlainPart() ?? '');
            
            if (extracted == 'absage' || extracted == 'interview') {
               newStatus = extracted!;
            } else if (extracted == 'bestaetigung' && app.status == 'offen') {
               newStatus = 'versendet';
            }

            if (newStatus != app.status) {
              await db.applicationsDao.updateApplication(app.copyWith(
                status: newStatus,
                responseDate: drift.Value(msg.decodeDate()),
                rejectionReason: newStatus == 'absage'
                    ? drift.Value('Automatisch aus E-Mail erkannt')
                    : const drift.Value.absent(),
              ));
            }
            break;
          }
        }
      }
    } catch (e) {
      print('IMAP Sync Error: $e');
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
    if (client == null) return [];

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
      Mailbox? sentBox;
      try {
        sentBox = mailboxes.firstWhere(
          (b) => b.isSent || b.name.toLowerCase().contains('sent') || b.name.toLowerCase().contains('gesendet') || b.name.toLowerCase().contains('postausgang') || b.name.toLowerCase().contains('outbox')
        );
      } catch (_) {}

      if (sentBox != null) {
        await client.selectMailbox(sentBox);
        final sentFetch = await client.fetchRecentMessages(messageCount: 50, criteria: 'BODY.PEEK[]');

        for (final msg in sentFetch.messages) {
          final rawTo = msg.to?.map((e) => e.email.toLowerCase()).toList() ?? [];
          final toAddresses = rawTo.where((e) => e != email.toLowerCase()).toList();
          final subject = msg.decodeSubject() ?? '';
          final body = msg.decodeTextPlainPart() ?? '';
          final date = msg.decodeDate() ?? DateTime.now();
          final uid = msg.decodeHeaderValue('Message-ID') ?? msg.uid.toString();
          final recipientEmail = toAddresses.isNotEmpty ? toAddresses.first : '';

          final detectedStatus = _detectApplicationStatus(subject, body);

          // Try to resolve company name
          String company = _extractCompanyFromBody(body);
          if (company.isEmpty && recipientEmail.isNotEmpty) {
            company = _extractCompanyFromDomain(recipientEmail);
          }

          final alreadyImported = existingContactEmails.contains(recipientEmail) ||
              existingEmails.any((e) => e.messageId == uid);
          final cleanSubject = _stripReplyPrefix(subject);

          result.add(ScannableEmail(
            uid: uid,
            subject: cleanSubject.isNotEmpty ? cleanSubject : subject,
            fromTo: recipientEmail.isNotEmpty ? 'An: $recipientEmail' : 'Gesendet',
            date: date,
            bodySnippet: body.length > 180 ? '${body.substring(0, 180)}...' : body,
            detectedStatus: detectedStatus,
            isAlreadyImported: alreadyImported,
            folder: 'sent',
            company: company,
          ));
        }
      }

      // ── Inbox ────────────────────────────────────────────────────────────
      await client.selectInbox();
      final inboxFetch = await client.fetchRecentMessages(messageCount: 50, criteria: 'BODY.PEEK[]');

      for (final msg in inboxFetch.messages) {
        final from = msg.from?.first.email.toLowerCase() ?? '';
        final subject = msg.decodeSubject() ?? '';
        final body = msg.decodeTextPlainPart() ?? '';
        final date = msg.decodeDate() ?? DateTime.now();
        final uid = msg.decodeHeaderValue('Message-ID') ?? msg.uid.toString();

        final detectedStatus = _detectApplicationStatus(subject, body);

        String company = _extractCompanyFromDomain(from);
        if (company.isEmpty) company = _extractCompanyFromBody(body);

        final alreadyImported = existingEmails.any((e) => e.messageId == uid);
        final cleanSubject = _stripReplyPrefix(subject);

        result.add(ScannableEmail(
          uid: uid,
          subject: cleanSubject.isNotEmpty ? cleanSubject : subject,
          fromTo: 'Von: $from',
          date: date,
          bodySnippet: body.length > 180 ? '${body.substring(0, 180)}...' : body,
          detectedStatus: detectedStatus,
          isAlreadyImported: alreadyImported,
          folder: 'inbox',
          company: company,
        ));
      }
    } finally {
      await client.disconnect();
    }

    // Sort strictly by date descending
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  // ── Import selected emails (from scanner) ────────────────────────────────

  Future<int> importSelectedEmails(AppDatabase db, List<ScannableEmail> emails) async {
    final applications = await db.applicationsDao.getAllApplications();
    int count = 0;
    for (final scanMail in emails) {
      final status = scanMail.detectedStatus ?? 'versendet';

      final recipientEmail = scanMail.folder == 'sent'
          ? (scanMail.fromTo.startsWith('An: ') ? scanMail.fromTo.substring(4) : '')
          : '';

      final alreadyExists = recipientEmail.isNotEmpty &&
          applications.any((app) => app.contactEmail?.toLowerCase() == recipientEmail);
      if (alreadyExists) continue;

      String company = _extractCompanyFromBody(scanMail.bodySnippet);
      if (company.isEmpty && recipientEmail.isNotEmpty) {
        company = _extractCompanyFromDomain(recipientEmail);
      }
      if (company.isEmpty) company = 'Unbekannte Firma';

      final contact = _extractContact(scanMail.bodySnippet);

      final appId = await db.applicationsDao.insertApplication(ApplicationsCompanion.insert(
        company: company,
        position: _extractPosition(scanMail.subject),
        status: drift.Value(status),
        appliedDate: drift.Value(scanMail.date),
        contactName: drift.Value(contact.isNotEmpty ? contact : null),
        contactEmail: drift.Value(recipientEmail.isNotEmpty ? recipientEmail : null),
        notes: drift.Value('Manuell importiert per E-Mail-Scanner.'),
        createdAt: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ));

      await db.emailsDao.insertEmail(EmailsCompanion.insert(
        applicationId: appId,
        messageId: scanMail.uid,
        subject: scanMail.subject,
        sender: scanMail.fromTo,
        bodySnippet: scanMail.bodySnippet.length > 200
            ? '${scanMail.bodySnippet.substring(0, 200)}...'
            : scanMail.bodySnippet,
        receivedAt: scanMail.date,
        isRead: drift.Value(true),
      ));
      count++;
    }
    return count;
  }
}

