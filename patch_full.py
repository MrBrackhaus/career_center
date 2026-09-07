import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/widgets/basic_data_tab.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = "_buildField('Position', bundle.positionController, 'Position', isRequired: true),"
replacement = """_buildField('Position', bundle.positionController, 'Position', isRequired: true),
            const SizedBox(height: 12),
            TextFormField(
              controller: bundle.jobDescriptionTextController,
              decoration: const InputDecoration(
                labelText: 'Volltext der Stellenanzeige (für KI-Anschreiben)', 
                border: OutlineInputBorder()
              ),
              maxLines: 6,
              minLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (bundle.jobDescriptionTextController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte füge zuerst eine Stellenanzeige ein.')));
                    return;
                  }
                  final success = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AiCoverLetterDialog(
                      application: bundle.application,
                      company: bundle.companyController.text,
                      position: bundle.positionController.text,
                      jobDescription: bundle.jobDescriptionTextController.text,
                    ),
                  );
                  if (success == true) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Anschreiben generiert! Du findest es unter dem Reiter "Dokumente".'), backgroundColor: Colors.green));
                  }
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('✨ KI-Anschreiben generieren', style: TextStyle(fontSize: 16)),
              ),
            ),"""

if target in text:
    text = text.replace(target, replacement)
else:
    print("TARGET NOT FOUND!")

# Also add import if missing
import_stmt = "import 'ai_cover_letter_dialog.dart';"
if import_stmt not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_stmt)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Patch applied successfully.")
