class NoteEntity {
  final int id;
  final int applicationId;
  
  final String content;
  final DateTime createdAt;

  const NoteEntity({
    required this.id,
    required this.applicationId,
    
    required this.content,
    required this.createdAt,
  });
}
