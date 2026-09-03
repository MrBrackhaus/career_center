import os

with open(r'lib\presentation\screens\applications\application_form_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

start_idx = 0
end_idx = 0
for i, line in enumerate(lines):
    if 'final formWidget = Form(' in line:
        start_idx = i
    if '// === E-MAILS ===' in line:
        end_idx = i
        break

form_code = "".join(lines[start_idx:end_idx])

# Replace some local references with bundle references
import re
bundle_vars = [
    '_formKey', '_companyController', '_positionController', '_notesController',
    '_rejectionReasonController', '_commutCarController', '_salaryWishController',
    '_jobUrlController', '_autoFillUrlController', '_companyUrlController',
    '_customFieldControllers', '_status', '_appliedDate', '_followUpDate',
    '_activeCustomColumns', '_isAutoFilling', '_lastExtractionResult', 'isEditing',
    '_contactNameController', '_contactEmailController', '_contactPhoneController',
    '_addressController'
]
for v in bundle_vars:
    if v.startswith('_'):
        form_code = form_code.replace(v, f"bundle.{v[1:]}")
    else:
        form_code = form_code.replace(v, f"bundle.{v}")

# Also callbacks
callbacks = {
    '_autoFillFromUrl': 'bundle.onAutoFillFromUrl',
    '_pickPdfForExtraction': 'bundle.onPickPdf',
    '_applyExtractionResult': 'bundle.onApplyExtractionResult',
    '_saveApplication': 'bundle.onSave',
}
for k, v in callbacks.items():
    form_code = form_code.replace(k, v)

# Also method calls
form_code = form_code.replace('setState(() {', '')
form_code = form_code.replace('});', '')
form_code = form_code.replace('_status = newValue!;', 'bundle.onStatusChange(newValue!);')
form_code = form_code.replace('_appliedDate = date;', 'bundle.onAppliedDateChange(date);')
form_code = form_code.replace('_followUpDate = date;', 'bundle.onFollowUpDateChange(date);')
form_code = form_code.replace('_buildAIFeedbackCard(context)', 'AIFeedbackCard(bundle: bundle)')
form_code = form_code.replace('_activeMarkerField ==', 'bundle.activeMarkerField ==')
form_code = form_code.replace('_activeMarkerField = fieldName;', 'bundle.onFieldTapWithMarker(fieldName, controller);') # Needs manual fix

tab_code = f"""import 'package:flutter/material.dart';
import '../application_form_state_bundle.dart';
import '../../../../core/models/extraction_result.dart';

class BasicDataTab extends StatelessWidget {{
  final ApplicationFormStateBundle bundle;
  const BasicDataTab({{Key? key, required this.bundle}}) : super(key: key);

  @override
  Widget build(BuildContext context) {{
    {form_code.replace('final formWidget = ', 'return ')}
  }}
}}
"""

with open(r'lib\presentation\screens\applications\widgets\basic_data_tab.dart', 'w', encoding='utf-8') as f:
    f.write(tab_code)
