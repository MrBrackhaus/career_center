import '../../../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:career_center/domain/enums/document_type.dart';

import '../application_form_state_bundle.dart';

class BasicDataTab extends StatelessWidget {
  Widget _buildField(
    String label,
    TextEditingController controller,
    String markerKey, {
    bool isRequired = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final isActive = bundle.activeMarkerField == markerKey;
    final colorScheme = ThemeData.light().colorScheme; // fallback
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? "$label *" : label,
        border: OutlineInputBorder(
          borderSide: isActive
              ? const BorderSide(color: Colors.blue, width: 2)
              : const BorderSide(),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: isActive
              ? const BorderSide(color: Colors.blue, width: 2)
              : const BorderSide(color: Colors.grey),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.colorize,
            color: isActive ? Colors.blue : Colors.grey,
          ),
          onPressed: () => bundle.onMarkerToggled(markerKey),
          tooltip: "Aus Dokument markieren",
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: isRequired
          ? (val) => val == null || val.isEmpty ? 'Pflichtfeld' : null
          : null,
    );
  }

  final ApplicationFormStateBundle bundle;

  const BasicDataTab({super.key, required this.bundle});

  Widget _buildAIFeedbackCard(BuildContext context) {
    final result = bundle.lastExtractionResult!;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: colorScheme.secondary.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: colorScheme.onSecondaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'KI-Erkennung: ${result.documentType.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Falsch erkannt? Hilf der KI zu lernen, indem du den korrekten Typ auswählst:',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<DocumentType>(
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              initialValue: result.documentType,
              items: DocumentType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
              onChanged: (newType) {
                if (newType != null && newType != result.documentType) {
                  bundle.onAiFeedbackCorrection(result, newType);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: bundle.formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bundle.lastExtractionResult != null)
              _buildAIFeedbackCard(context),
            if (bundle.lastExtractionResult != null) const SizedBox(height: 16),
            // === MAGIC AUTO-FILL ===
            Card(
              color: Theme.of(context).colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✨ Magic Auto-Fill',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.formBasicJobLinkHint,
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: bundle.autoFillUrlController,
                            decoration: const InputDecoration(
                              hintText: 'https://...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              prefixIcon: Icon(Icons.link),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: bundle.isAutoFilling
                              ? null
                              : bundle.onAutoFillFromUrl,
                          icon: bundle.isAutoFilling
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.auto_fix_high),
                          label: Text(
                            AppLocalizations.of(context)!.formBasicAutofill,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: bundle.isAutoFilling
                            ? null
                            : bundle.onAutoFillFromPdf,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          AppLocalizations.of(context)!.formBasicUploadPdf,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // === PFLICHTFELDER ===
            _buildField(
              AppLocalizations.of(context)!.promptCompany,
              bundle.companyController,
              AppLocalizations.of(context)!.promptCompany,
              isRequired: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: bundle.companyUrlController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.formBasicCompanyWeb,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: bundle.jobUrlController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.formBasicJobLink,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _buildField(
              'Position',
              bundle.positionController,
              'Position',
              isRequired: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: bundle.jobDescriptionTextController,
              decoration: const InputDecoration(
                labelText: 'Volltext der Stellenanzeige (für KI-Anschreiben)',
                border: OutlineInputBorder(),
              ),
              maxLines: 6,
              minLines: 3,
            ),

            DropdownButtonFormField<String>(
              initialValue: bundle.status,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.formBasicStatus,
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'offen',
                  child: Text(AppLocalizations.of(context)!.formBasicOpen),
                ),
                DropdownMenuItem(
                  value: 'versendet',
                  child: Text(AppLocalizations.of(context)!.formBasicSent),
                ),
                DropdownMenuItem(
                  value: 'interview',
                  child: Text(AppLocalizations.of(context)!.formBasicInterview),
                ),
                DropdownMenuItem(
                  value: 'absage',
                  child: Text(AppLocalizations.of(context)!.formBasicRejected),
                ),
                DropdownMenuItem(
                  value: 'zusage',
                  child: Text(AppLocalizations.of(context)!.formBasicAccepted),
                ),
              ],
              onChanged: (val) {
                if (val != null) bundle.onStatusChange(val);
              },
            ),
            if (bundle.status == 'absage') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: bundle.rejectionReasonController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                      .formBasicRejectionReason,
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 16),
            // Datum
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: bundle.appliedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) bundle.onAppliedDateChange(date);
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      bundle.appliedDate == null
                          ? 'Bewerbungsdatum wählen'
                          : 'Beworben: ${bundle.appliedDate!.day.toString().padLeft(2, '0')}.${bundle.appliedDate!.month.toString().padLeft(2, '0')}.${bundle.appliedDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          bundle.followUpDate != null &&
                              bundle.followUpDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : null,
                      side:
                          bundle.followUpDate != null &&
                              bundle.followUpDate!.isBefore(DateTime.now())
                          ? const BorderSide(color: Colors.red)
                          : null,
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            bundle.followUpDate ??
                            DateTime.now().add(const Duration(days: 14)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) bundle.onFollowUpDateChange(date);
                    },
                    icon: Icon(
                      bundle.followUpDate != null &&
                              bundle.followUpDate!.isBefore(DateTime.now())
                          ? Icons.warning_amber
                          : Icons.notifications_none,
                    ),
                    label: Text(
                      bundle.followUpDate == null
                          ? 'Nachhaken am... (optional)'
                          : 'Nachhaken: ${bundle.followUpDate!.day.toString().padLeft(2, '0')}.${bundle.followUpDate!.month.toString().padLeft(2, '0')}.${bundle.followUpDate!.year}',
                    ),
                  ),
                ),
                if (bundle.followUpDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: 'Erinnerung entfernen',
                    onPressed: () => bundle.onFollowUpDateChange(null),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: bundle.commutCarController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.formBasicCommute,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: bundle.salaryWishController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.formBasicSalary,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            // === KONTAKT-DATEN ===
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.formBasicContact,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            _buildField(
              'Ansprechperson',
              bundle.contactNameController,
              'Ansprechpartner',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    'E-Mail',
                    bundle.contactEmailController,
                    'E-Mail',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    'Telefon',
                    bundle.contactPhoneController,
                    'Telefon',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              'Adresse',
              bundle.addressController,
              'Adresse',
              maxLines: 2,
            ),

            // === DYNAMISCHE CUSTOM FIELDS ===
            if (bundle.activeCustomColumns.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Zusätzliche Felder (${bundle.activeCustomColumns.join(", ")})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              ...bundle.activeCustomColumns.map(
                (col) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: bundle.customFieldControllers[col],
                    decoration: InputDecoration(
                      labelText: col,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            TextFormField(
              controller: bundle.notesController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.formTabNotes,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // === SPEICHERN ===
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: bundle.onSave,
                icon: const Icon(Icons.save),
                label: Text(
                  AppLocalizations.of(context)!.formBasicSave,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            if (bundle.isEditing && bundle.onDelete != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: bundle.onDelete,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    AppLocalizations.of(context)!.formBasicDelete,
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
