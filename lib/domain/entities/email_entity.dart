class EmailEntity {
  final int id;
  final int applicationId;
  final String messageId;
  final String subject;
  final String sender;
  final String bodySnippet;
  final DateTime receivedAt;
  final bool isRead;
  final bool isSentByMe;

  const EmailEntity({
    required this.id,
    required this.applicationId,
    required this.messageId,
    required this.subject,
    required this.sender,
    required this.bodySnippet,
    required this.receivedAt,
    required this.isRead,
    required this.isSentByMe,
  });
}