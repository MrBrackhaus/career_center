import 'package:drift/drift.dart' as drift;
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/contact_entity.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/entities/template_entity.dart';
import '../database/app_database.dart';
import '../../domain/models/application_form_dto.dart';
import '../../domain/enums/application_status.dart';

extension ApplicationMapper on Application {
  ApplicationEntity toEntity() {
    return ApplicationEntity(
      id: id,
      company: company,
      position: position,
      address: address,
      industry: industry,
      contactName: contactName,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      // Unbekannte Altwerte (z. B. 'bestaetigung') würden sonst in keiner
      // Kanban-Spalte und keinem Filter auftauchen.
      status: normalizeApplicationStatus(status, fallback: 'offen'),
      priority: priority,
      appliedDate: appliedDate,
      responseDate: responseDate,
      followupDate: followupDate,
      commuteCar: commuteCar,
      commuteTransit: commuteTransit,
      salaryWish: salaryWish,
      salaryOffered: salaryOffered,
      nextStep: nextStep,
      notes: notes,
      rejectionReason: rejectionReason,
      jobUrl: jobUrl,
      companyUrl: companyUrl,
      customFields: customFields,
      coverLetterContent: coverLetterContent,
      cvContent: cvContent,
      jobDescriptionText: jobDescriptionText,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

extension ContactMapper on Contact {
  ContactEntity toEntity() {
    return ContactEntity(
      id: id,
      applicationId: applicationId,
      name: name,
      email: email,
      phone: phone,
      role: role,
    );
  }
}

extension ContactEntityMapper on ContactEntity {
  ContactsCompanion toCompanion(bool update) {
    return ContactsCompanion(
      id: update ? drift.Value(id) : const drift.Value.absent(),
      applicationId: drift.Value(applicationId),
      name: drift.Value(name),
      email: drift.Value(email),
      phone: drift.Value(phone),
      role: drift.Value(role),
    );
  }
}

extension DocumentMapper on Document {
  DocumentEntity toEntity() {
    return DocumentEntity(
      id: id,
      applicationId: applicationId,
      fileName: fileName,
      filePath: filePath,
      fileType: fileType,
      uploadedAt: uploadedAt ?? DateTime.now(),
    );
  }
}

extension DocumentEntityMapper on DocumentEntity {
  DocumentsCompanion toCompanion(bool update) {
    return DocumentsCompanion(
      id: update ? drift.Value(id) : const drift.Value.absent(),
      applicationId: drift.Value(applicationId),
      fileName: drift.Value(fileName),
      filePath: drift.Value(filePath),
      fileType: drift.Value(fileType),
      uploadedAt: drift.Value(uploadedAt),
    );
  }
}

extension NoteMapper on Note {
  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      applicationId: applicationId,
      
      content: content,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension NoteEntityMapper on NoteEntity {
  NotesCompanion toCompanion(bool update) {
    return NotesCompanion(
      id: update ? drift.Value(id) : const drift.Value.absent(),
      applicationId: drift.Value(applicationId),
      
      content: drift.Value(content),
      createdAt: drift.Value(createdAt),
    );
  }
}

extension TemplateMapper on Template {
  TemplateEntity toEntity() {
    return TemplateEntity(
      id: id,
      name: name,
      type: type,
      content: content ?? '',
      filePath: filePath,
      applicationId: applicationId,
      // Entity verlangt non-null; der Fallback wird bei Updates nie
      // zurückgeschrieben (siehe TemplateEntityMapper.toCompanion).
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}

extension TemplateEntityMapper on TemplateEntity {
  /// Bei [update] == true entsteht ein Teil-Update: `createdAt` wird nie
  /// geschrieben, `filePath`/`applicationId` nur, wenn sie gesetzt sind –
  /// so gehen Verknüpfung und Originaldatei bei Updates nicht verloren.
  TemplatesCompanion toCompanion(bool update) {
    if (update) {
      return TemplatesCompanion(
        id: drift.Value(id),
        name: drift.Value(name),
        type: drift.Value(type),
        content: drift.Value(content),
        filePath: drift.Value.absentIfNull(filePath),
        applicationId: drift.Value.absentIfNull(applicationId),
      );
    }
    return TemplatesCompanion(
      name: drift.Value(name),
      type: drift.Value(type),
      content: drift.Value(content),
      filePath: drift.Value(filePath),
      applicationId: drift.Value(applicationId),
      createdAt: drift.Value(createdAt),
    );
  }
}

extension ApplicationFormDtoMapper on ApplicationFormDto {
  ApplicationsCompanion toCompanion({bool isUpdate = false}) {
    return ApplicationsCompanion(
      id: (isUpdate && id != null) ? drift.Value(id!) : const drift.Value.absent(),
      company: drift.Value(company),
      position: drift.Value(position),
      status: drift.Value(status),
      notes: drift.Value(notes),
      rejectionReason: drift.Value(rejectionReason),
      appliedDate: drift.Value(appliedDate),
      followupDate: drift.Value(followupDate),
      commuteCar: drift.Value(commuteCar),
      salaryWish: drift.Value(salaryWish),
      jobUrl: drift.Value(jobUrl),
      companyUrl: drift.Value(companyUrl),
      contactName: drift.Value(contactName),
      contactEmail: drift.Value(contactEmail),
      contactPhone: drift.Value(contactPhone),
      address: drift.Value(address),
      customFields: drift.Value(customFields),
      jobDescriptionText: drift.Value(jobDescriptionText),
    );
  }
}
