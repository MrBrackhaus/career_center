class DocumentEntity {
  final int id;
  final int applicationId;
  final String fileName;
  final String filePath;
  final String fileType;
  final DateTime uploadedAt;

  const DocumentEntity({
    required this.id,
    required this.applicationId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.uploadedAt,
  });
}
