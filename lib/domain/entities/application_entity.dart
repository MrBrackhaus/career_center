class ApplicationEntity {
  final int id;
  final String company;
  final String position;
  final String? address;
  final String? industry;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String status;
  final int priority;
  final DateTime? appliedDate;
  final DateTime? responseDate;
  final DateTime? followupDate;
  final int? commuteCar;
  final int? commuteTransit;
  final int? salaryWish;
  final int? salaryOffered;
  final String? nextStep;
  final String? notes;
  final String? rejectionReason;
  final String? jobUrl;
  final String? companyUrl;
  final String? customFields;
  final String? coverLetterContent;
  final String? cvContent;
  final String? jobDescriptionText;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ApplicationEntity({
    required this.id,
    required this.company,
    required this.position,
    this.address,
    this.industry,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    required this.status,
    required this.priority,
    this.appliedDate,
    this.responseDate,
    this.followupDate,
    this.commuteCar,
    this.commuteTransit,
    this.salaryWish,
    this.salaryOffered,
    this.nextStep,
    this.notes,
    this.rejectionReason,
    this.jobUrl,
    this.companyUrl,
    this.customFields,
    this.coverLetterContent,
    this.cvContent,
    this.jobDescriptionText,
    required this.createdAt,
    required this.updatedAt,
  });
}
