class ApplicationFormDto {
  final int? id;
  final String company;
  final String position;
  final String status;
  final String? notes;
  final String? rejectionReason;
  final DateTime? appliedDate;
  final DateTime? followupDate;
  final int? commuteCar;
  final int? salaryWish;
  final String? jobUrl;
  final String? companyUrl;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? address;
  final String? customFields;
  final String? jobDescriptionText;
  
  ApplicationFormDto({
    this.id,
    required this.company,
    required this.position,
    required this.status,
    this.notes,
    this.rejectionReason,
    this.appliedDate,
    this.followupDate,
    this.commuteCar,
    this.salaryWish,
    this.jobUrl,
    this.companyUrl,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.customFields,
    this.jobDescriptionText,
  });
}
