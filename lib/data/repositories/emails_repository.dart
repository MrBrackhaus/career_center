import '../database/app_database.dart';
import '../../domain/entities/email_entity.dart';
import 'package:drift/drift.dart' as drift;

class EmailsRepository {
  final AppDatabase _db;

  EmailsRepository(this._db);

  EmailEntity _map(Email e) => EmailEntity(
    id: e.id,
    applicationId: e.applicationId,
    messageId: e.messageId,
    subject: e.subject,
    sender: e.sender,
    bodySnippet: e.bodySnippet,
    receivedAt: e.receivedAt,
    isRead: e.isRead,
    isSentByMe: e.isSentByMe,
  );

  Future<List<EmailEntity>> getEmailsForApplication(int appId) async {
    final list = await _db.emailsDao.getEmailsForApplication(appId);
    return list.map(_map).toList();
  }

  Stream<List<EmailEntity>> watchEmailsForApplication(int appId) {
    return _db.emailsDao.watchEmailsForApplication(appId).map((list) => list.map(_map).toList());
  }

  Future<void> insertEmail({required int applicationId, required String messageId, required String subject, required String sender, required String bodySnippet, required DateTime receivedAt, required bool isRead, required bool isSentByMe}) async {
    await _db.emailsDao.insertEmail(EmailsCompanion.insert(
      applicationId: applicationId,
      messageId: messageId,
      subject: subject,
      sender: sender,
      bodySnippet: bodySnippet,
      receivedAt: receivedAt,
      isRead: drift.Value(isRead),
      isSentByMe: drift.Value(isSentByMe),
    ));
  }

  Future<EmailEntity?> getEmailByMessageId(String messageId) async {
    final e = await _db.emailsDao.getEmailByMessageId(messageId);
    return e == null ? null : _map(e);
  }

  Future<List<EmailEntity>> getAllEmails() async {
    final list = await _db.emailsDao.getAllEmails();
    return list.map(_map).toList();
  }

  Stream<List<EmailEntity>> watchAllEmails() {
    return _db.emailsDao.watchAllEmails().map((list) => list.map(_map).toList());
  }
}