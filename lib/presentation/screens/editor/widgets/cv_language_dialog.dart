import 'package:flutter/material.dart';

class CvLanguageDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CvLanguageDialog({Key? key, this.initialData}) : super(key: key);

  @override
  State<CvLanguageDialog> createState() => _CvLanguageDialogState();
}

class _CvLanguageDialogState extends State<CvLanguageDialog> {
  late TextEditingController _nameController;
  String _selectedLevel = 'Grundkenntnisse';

  final List<String> _levels = [
    'Grundkenntnisse',
    'Gut',
    'Fließend',
    'Verhandlungssicher',
    'Muttersprache',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    if (widget.initialData != null && widget.initialData!['level'] != null) {
      if (_levels.contains(widget.initialData!['level'])) {
        _selectedLevel = widget.initialData!['level'];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sprache hinzufügen/bearbeiten'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Sprache',
                hintText: 'z.B. Englisch',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Niveau',
              ),
              items: _levels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLevel = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            Navigator.of(context).pop({
              'name': _nameController.text.trim(),
              'level': _selectedLevel,
            });
          },
          child: const Text('Speichern'),
        ),
      ],
    );
  }
}
