class ContactEntity {
  final int id;
  final int applicationId;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;

  const ContactEntity({
    required this.id,
    required this.applicationId,
    this.name,
    this.email,
    this.phone,
    this.role,
  });
}
