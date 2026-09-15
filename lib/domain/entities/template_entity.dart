class TemplateEntity {
  final int id;
  final String name;
  final String type;
  final String content;
  final String? filePath;
  final int? applicationId;
  final DateTime createdAt;

  const TemplateEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.content,
    this.filePath,
    this.applicationId,
    required this.createdAt,
  });
}
