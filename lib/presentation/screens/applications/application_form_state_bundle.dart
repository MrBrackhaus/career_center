import 'package:flutter/material.dart';
import 'package:career_center/domain/models/extraction_result.dart';
import 'package:career_center/domain/enums/document_type.dart';

class ApplicationFormStateBundle {
  final GlobalKey<FormState> formKey;
  
  final TextEditingController companyController;
  final TextEditingController positionController;
  final TextEditingController notesController;
  final TextEditingController rejectionReasonController;
  final TextEditingController commutCarController;
  final TextEditingController salaryWishController;
  final TextEditingController jobUrlController;
  final TextEditingController autoFillUrlController;
  final TextEditingController companyUrlController;
  final TextEditingController contactNameController;
  final TextEditingController contactEmailController;
  final TextEditingController contactPhoneController;
  final TextEditingController addressController;
  final Map<String, TextEditingController> customFieldControllers;

  final String status;
  final DateTime? appliedDate;
  final DateTime? followUpDate;
  final List<String> activeCustomColumns;
  final bool isAutoFilling;
  
  final ExtractionResult? lastExtractionResult;
  final bool isEditing;
  final String? activeMarkerField;
  final Function(String?) onMarkerToggled;

  final VoidCallback onSave;
  final VoidCallback onAutoFillFromUrl;
  final VoidCallback onAutoFillFromPdf;
  final Function(String) onStatusChange;
  final Function(DateTime?) onAppliedDateChange;
  final Function(DateTime?) onFollowUpDateChange;
  final Function(ExtractionResult, DocumentType) onAiFeedbackCorrection;
  final VoidCallback? onDelete;

  ApplicationFormStateBundle({
    required this.formKey,
    required this.companyController,
    required this.positionController,
    required this.notesController,
    required this.rejectionReasonController,
    required this.commutCarController,
    required this.salaryWishController,
    required this.jobUrlController,
    required this.autoFillUrlController,
    required this.companyUrlController,
    required this.contactNameController,
    required this.contactEmailController,
    required this.contactPhoneController,
    required this.addressController,
    required this.customFieldControllers,
    required this.status,
    required this.appliedDate,
    required this.followUpDate,
    required this.activeCustomColumns,
    required this.isAutoFilling,
    this.lastExtractionResult,
    required this.isEditing,
    this.activeMarkerField,
    required this.onMarkerToggled,
    required this.onSave,
    required this.onAutoFillFromUrl,
    required this.onAutoFillFromPdf,
    required this.onStatusChange,
    required this.onAppliedDateChange,
    required this.onFollowUpDateChange,
    required this.onAiFeedbackCorrection,
    this.onDelete,
  });
}

