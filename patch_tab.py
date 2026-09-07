import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/widgets/basic_data_tab.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = """            const SizedBox(height: 12),
            _buildField('Position', bundle.positionController, 'Position', isRequired: true),
            const SizedBox(height: 12),"""

replacement = """            const SizedBox(height: 12),
            _buildField('Position', bundle.positionController, 'Position', isRequired: true),
            const SizedBox(height: 12),
            TextFormField(
              controller: bundle.jobDescriptionTextController,
              decoration: InputDecoration(
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
                onPressed: () {
                  // TODO: trigger AI cover letter generation dialog
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('✨ KI-Anschreiben generieren', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),"""

text = text.replace(target, replacement)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("BasicDataTab patched!")
