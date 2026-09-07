import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/widgets/basic_data_tab.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Add import
import_stmt = "import 'package:career_center/domain/enums/document_type.dart';\nimport 'ai_cover_letter_dialog.dart';"
text = text.replace("import 'package:career_center/domain/enums/document_type.dart';", import_stmt)

# Update onPressed
target = """                onPressed: () {
                  // TODO: trigger AI cover letter generation dialog
                },"""

replacement = """                onPressed: () async {
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
                },"""

text = text.replace(target, replacement)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("BasicDataTab logic patched!")
